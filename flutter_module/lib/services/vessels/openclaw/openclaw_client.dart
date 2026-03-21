import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../vessel_interface.dart';
import '../models/vessel_connection.dart';
import '../models/vessel_result.dart';
import 'openclaw_config.dart';
import 'openclaw_sse_parser.dart';

class VesselException implements Exception {
  final String message;
  final int? statusCode;
  const VesselException(this.message, {this.statusCode});
  @override
  String toString() => 'VesselException: $message (status: $statusCode)';
}

class OpenClawClient implements VesselInterface {
  final OpenClawConfig config;
  final http.Client _httpClient;
  final Logger _log = Logger();
  final _connectionController = StreamController<VesselConnection>.broadcast();
  VesselConnection _currentConnection;
  WebSocketChannel? _wsChannel;
  final _outputController = StreamController<String>.broadcast();
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 10;

  OpenClawClient({
    required this.config,
    http.Client? httpClient,
  })  : _httpClient = httpClient ?? http.Client(),
        _currentConnection = VesselConnection(
          vesselId: 'openclaw',
          vesselName: 'OpenClaw',
          status: ConnectionStatus.disconnected,
        );

  @override
  String get vesselId => 'openclaw';

  @override
  String get vesselName => 'OpenClaw';

  @override
  Stream<VesselConnection> get connectionStatus => _connectionController.stream;

  @override
  Stream<String> get outputStream => _outputController.stream;

  /// Connect WebSocket for real-time terminal streaming (VES-12).
  /// Uses exponential backoff for reconnection (1s, 2s, 4s... max 30s).
  Future<void> connectWebSocket({String sessionKey = 'main'}) async {
    _reconnectAttempts = 0;
    await _establishWebSocket(sessionKey);
  }

  Future<void> _establishWebSocket(String sessionKey) async {
    try {
      final wsUri = config.wsUrl(sessionKey: sessionKey);
      _wsChannel = WebSocketChannel.connect(wsUri);

      // Authenticate via first message
      _wsChannel!.sink.add(jsonEncode({'token': config.token}));

      _wsChannel!.stream.listen(
        (data) {
          _reconnectAttempts = 0;
          final text = data is String ? data : String.fromCharCodes(data as List<int>);
          _outputController.add(text);
        },
        onError: (error) {
          _log.e('WebSocket error: $error');
          _scheduleReconnect(sessionKey);
        },
        onDone: () {
          _log.w('WebSocket closed');
          _scheduleReconnect(sessionKey);
        },
      );

      _startHeartbeat();
    } catch (e) {
      _log.e('WebSocket connect failed: $e');
      _scheduleReconnect(sessionKey);
    }
  }

  void _scheduleReconnect(String sessionKey) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _log.w('Max reconnect attempts reached');
      _outputController.add('\r\n[Verbinding verloren — max herverbindingen bereikt]\r\n');
      return;
    }
    final delay = Duration(
      seconds: (1 << _reconnectAttempts).clamp(1, 30),
    );
    _reconnectAttempts++;
    _log.i('Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    Future.delayed(delay, () => _establishWebSocket(sessionKey));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        _wsChannel?.sink.add('ping');
      } catch (_) {
        _heartbeatTimer?.cancel();
      }
    });
  }

  /// Send input to the vessel via WebSocket.
  void sendInput(String data) {
    _wsChannel?.sink.add(data);
  }

  /// Disconnect WebSocket.
  void disconnectWebSocket() {
    _heartbeatTimer?.cancel();
    _wsChannel?.sink.close();
    _wsChannel = null;
  }

  @override
  Future<VesselConnection> connect() async {
    _updateConnection(ConnectionStatus.connecting);
    try {
      final error = await checkHealth();
      if (error == null) {
        _updateConnection(ConnectionStatus.connected,
            connectedAt: DateTime.now());
      } else {
        _updateConnection(ConnectionStatus.error,
            errorMessage: error);
      }
    } catch (e) {
      _updateConnection(ConnectionStatus.error,
          errorMessage: e.toString());
    }
    return _currentConnection;
  }

  @override
  Future<void> disconnect() async {
    _updateConnection(ConnectionStatus.disconnected);
  }

  @override
  Future<String?> checkHealth() async {
    try {
      // Try GET /health first
      final healthResponse = await _httpClient.get(
        config.healthUrl,
        headers: config.authHeaders,
      );
      if (healthResponse.statusCode == 200) return null;
      if (healthResponse.statusCode == 401) return '401 – Ongeldig token';

      // Fallback: GET /tools (older OpenClaw without /health)
      if (healthResponse.statusCode == 404) {
        final toolsResponse = await _httpClient.get(
          config.toolsListUrl,
          headers: config.authHeaders,
        );
        if (toolsResponse.statusCode == 200) return null;
        if (toolsResponse.statusCode == 401) return '401 – Ongeldig token';
        return 'Fout ${toolsResponse.statusCode} – controleer URL en prefix';
      }

      return 'Fout ${healthResponse.statusCode} – controleer URL en prefix';
    } on SocketException {
      return 'Verbinding geweigerd – controleer host en poort';
    } catch (e) {
      final msg = e.toString();
      return msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
    }
  }

  /// Invoke a tool via POST /tools/invoke (VES-02).
  Future<Map<String, dynamic>> invokeTool({
    required String tool,
    Map<String, dynamic> args = const {},
    String sessionKey = 'main',
  }) async {
    final response = await _httpClient.post(
      config.toolsInvokeUrl,
      headers: config.authHeaders,
      body: jsonEncode({
        'tool': tool,
        'args': args,
        'sessionKey': sessionKey,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 401) {
      throw VesselException('Authentication failed', statusCode: 401);
    }
    if (response.statusCode == 404) {
      throw VesselException('Tool not found or policy blocked: $tool',
          statusCode: 404);
    }
    if (body['ok'] != true) {
      throw VesselException(
        body['error']?['message'] as String? ?? 'Tool invocation failed',
        statusCode: response.statusCode,
      );
    }
    return body['result'] as Map<String, dynamic>;
  }

  /// Fetch all available tools from the OpenClaw /tools endpoint.
  /// Returns a list of tool definitions with name, description, etc.
  /// Falls back to empty list on failure (non-critical for app startup).
  Future<List<Map<String, dynamic>>> fetchTools() async {
    try {
      final response = await _httpClient.get(
        config.toolsListUrl,
        headers: config.authHeaders,
      );
      if (response.statusCode != 200) {
        _log.w('Failed to fetch tools: status ${response.statusCode}');
        return [];
      }
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['tools'] is List) {
        return (body['tools'] as List).cast<Map<String, dynamic>>();
      }
      if (body is List) {
        return body.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _log.w('Failed to fetch tools: $e');
      return [];
    }
  }

  @override
  Future<VesselResult> execute({
    required String taskId,
    required String tool,
    required Map<String, dynamic> args,
    String? sessionKey,
  }) async {
    final result = await invokeTool(
      tool: tool,
      args: args,
      sessionKey: sessionKey ?? 'soul-$taskId',
    );
    return VesselResult(
      taskId: taskId,
      terminalOutput: result['output'] as String?,
      summary: result['summary'] as String?,
      rawResponse: result,
    );
  }

  @override
  Stream<String> streamCompletion({
    required List<Map<String, String>> messages,
    String? agentId,
    String? sessionKey,
  }) async* {
    final request = http.Request('POST', config.chatCompletionsUrl);
    request.headers.addAll(config.authHeaders);
    if (agentId != null) {
      request.headers['x-openclaw-agent-id'] = agentId;
    }
    if (sessionKey != null) {
      request.headers['x-openclaw-session-key'] = sessionKey;
    }
    request.body = jsonEncode({
      'model': agentId != null ? 'openclaw:$agentId' : 'openclaw',
      'messages': messages,
      'stream': true,
    });

    final response = await _httpClient.send(request);
    if (response.statusCode != 200) {
      throw VesselException(
        'Chat completion failed',
        statusCode: response.statusCode,
      );
    }

    yield* OpenClawSseParser.parse(response.stream);
  }

  @override
  Future<void> cancel(String taskId) async {
    // OpenClaw doesn't have a direct cancel; reset the session
    await invokeTool(
      tool: 'sessions_reset',
      sessionKey: 'soul-$taskId',
    );
  }

  /// Session management methods (VES-04)
  Future<List<Map<String, dynamic>>> listSessions() async {
    final result = await invokeTool(tool: 'sessions_list');
    return (result['sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> getSessionStatus(String sessionKey) async {
    return invokeTool(tool: 'sessions_status', args: {'key': sessionKey});
  }

  Future<void> resetSession(String sessionKey) async {
    await invokeTool(tool: 'sessions_reset', args: {'key': sessionKey});
  }

  Future<void> compactSession(String sessionKey) async {
    await invokeTool(tool: 'sessions_compact', args: {'key': sessionKey});
  }

  void _updateConnection(ConnectionStatus status,
      {String? errorMessage, DateTime? connectedAt}) {
    _currentConnection = VesselConnection(
      vesselId: vesselId,
      vesselName: vesselName,
      status: status,
      errorMessage: errorMessage,
      connectedAt: connectedAt ?? _currentConnection.connectedAt,
      lastHealthCheck: DateTime.now(),
    );
    _connectionController.add(_currentConnection);
  }

  void dispose() {
    disconnectWebSocket();
    _outputController.close();
    _connectionController.close();
    _httpClient.close();
  }
}
