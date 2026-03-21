import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../vessel_interface.dart';
import '../models/vessel_connection.dart';
import '../models/vessel_result.dart';
import '../openclaw/openclaw_client.dart' show VesselException;
import 'agent_sdk_config.dart';

/// Agent SDK client for connecting to soul-relay (RELAY-02).
/// Protocol matches soul-relay endpoints exactly:
///   - GET /health → checkHealth()
///   - POST /tasks {prompt, cwd, sessionId} → execute()
///   - DELETE /tasks/:id → cancel()
///   - Auth: Authorization: Bearer <token>
class AgentSdkClient implements VesselInterface {
  final AgentSdkConfig config;
  final http.Client _httpClient;
  final Logger _log = Logger();
  final _connectionController = StreamController<VesselConnection>.broadcast();
  VesselConnection _currentConnection;
  final _outputController = StreamController<String>.broadcast();

  AgentSdkClient({
    required this.config,
    http.Client? httpClient,
  })  : _httpClient = httpClient ?? http.Client(),
        _currentConnection = VesselConnection(
          vesselId: 'agent-sdk',
          vesselName: 'Agent SDK',
          status: ConnectionStatus.disconnected,
        );

  @override
  String get vesselId => 'agent-sdk';

  @override
  String get vesselName => 'Agent SDK';

  @override
  Stream<VesselConnection> get connectionStatus => _connectionController.stream;

  @override
  Stream<String> get outputStream => _outputController.stream;

  @override
  Future<VesselConnection> connect() async {
    _updateConnection(ConnectionStatus.connecting);
    try {
      final error = await checkHealth();
      if (error == null) {
        _updateConnection(ConnectionStatus.connected, connectedAt: DateTime.now());
      } else {
        _updateConnection(
          ConnectionStatus.error,
          errorMessage: error,
        );
      }
    } on TimeoutException {
      _updateConnection(
        ConnectionStatus.error,
        errorMessage: 'Verbinding time-out — relay server reageert niet.',
      );
    } catch (e) {
      _updateConnection(
        ConnectionStatus.error,
        errorMessage: 'Verbinding mislukt: ${_friendlyError(e)}',
      );
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
      final response = await _httpClient
          .get(config.healthUrl, headers: config.authHeaders)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return null;
      if (response.statusCode == 401) return '401 – Ongeldig token';
      return 'Fout ${response.statusCode}';
    } on SocketException {
      return 'Verbinding geweigerd';
    } on TimeoutException {
      return 'Verbinding time-out';
    } catch (e) {
      final msg = e.toString();
      return msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
    }
  }

  @override
  Future<VesselResult> execute({
    required String taskId,
    required String tool,
    required Map<String, dynamic> args,
    String? sessionKey,
  }) async {
    try {
      final response = await _httpClient
          .post(
            config.tasksUrl,
            headers: config.authHeaders,
            body: jsonEncode({
              'prompt': args['prompt'] as String? ?? tool,
              'cwd': args['cwd'] as String?,
              'sessionId': sessionKey ?? 'soul-$taskId',
            }),
          )
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 401) {
        throw VesselException(
          'Relay token is ongeldig — controleer de token in Instellingen.',
          statusCode: 401,
        );
      }

      if (response.statusCode != 200) {
        throw VesselException(
          'Agent SDK taak mislukt (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>? ?? [];
      final lastMessage = messages.isNotEmpty ? messages.last : {};
      final content =
          lastMessage is Map ? lastMessage['content'] as String? : null;

      if (content != null) {
        _outputController.add(content);
      }

      return VesselResult(
        taskId: taskId,
        terminalOutput: content,
        summary: content != null && content.length > 200
            ? '${content.substring(0, 200)}...'
            : content,
        rawResponse: body,
      );
    } on TimeoutException {
      throw VesselException('Taak time-out na 5 minuten');
    }
  }

  @override
  Stream<String> streamCompletion({
    required List<Map<String, String>> messages,
    String? agentId,
    String? sessionKey,
  }) {
    // Agent SDK relay uses request-response, not streaming
    // Convert to a single-event stream
    return Stream.fromFuture(
      execute(
        taskId: sessionKey ?? 'stream',
        tool: 'query',
        args: {'prompt': messages.last['content'] ?? ''},
        sessionKey: sessionKey,
      ).then((result) => result.terminalOutput ?? ''),
    );
  }

  @override
  Future<void> cancel(String taskId) async {
    // Agent SDK relay: attempt to cancel via DELETE
    try {
      await _httpClient.delete(
        config.taskUrl(taskId),
        headers: config.authHeaders,
      );
    } catch (_) {
      _log.w('Failed to cancel Agent SDK task $taskId');
    }
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

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('SocketException')) {
      return 'Netwerk onbereikbaar — zit je op hetzelfde WiFi-netwerk?';
    }
    if (msg.contains('HandshakeException')) {
      return 'SSL-fout — controleer het relay URL protocol (http/https)';
    }
    return msg.length > 100 ? '${msg.substring(0, 100)}...' : msg;
  }

  void dispose() {
    _outputController.close();
    _connectionController.close();
    _httpClient.close();
  }
}
