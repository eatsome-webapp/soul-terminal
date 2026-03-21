import 'package:mcp_dart/mcp_dart.dart' as mcp;
import '../../../core/utils/logger.dart';
import '../tool_registry.dart';
import 'mcp_config.dart';
import 'mcp_tool_adapter.dart';

/// Connection state for an MCP server.
enum McpConnectionState { disconnected, connecting, connected, error }

/// Status of a connected MCP server.
class McpServerStatus {
  final McpServerConfig config;
  final McpConnectionState state;
  final int toolCount;
  final String? errorMessage;

  const McpServerStatus({
    required this.config,
    this.state = McpConnectionState.disconnected,
    this.toolCount = 0,
    this.errorMessage,
  });
}

/// Manages MCP server connections and tool discovery.
///
/// Handles connect/disconnect lifecycle, discovers tools from connected
/// servers, and registers them in the ToolRegistry.
class McpManager {
  final McpConfigStore _configStore;
  final Map<String, mcp.McpClient> _clients = {};
  final Map<String, McpServerStatus> _statuses = {};
  final Map<String, mcp.Transport> _transports = {};

  McpManager({McpConfigStore? configStore})
      : _configStore = configStore ?? McpConfigStore();

  /// Current status of all known servers.
  List<McpServerStatus> get serverStatuses => _statuses.values.toList();

  /// Connect to an MCP server and discover its tools.
  /// Returns the discovered tool count.
  Future<int> connect(McpServerConfig config) async {
    _statuses[config.id] = McpServerStatus(
      config: config,
      state: McpConnectionState.connecting,
    );

    try {
      final client = mcp.McpClient(
        mcp.Implementation(name: 'SOUL', version: '1.0.0'),
      );

      final transport = _createTransport(config);
      await client.connect(transport);

      // Discover tools
      final toolsResult = await client.listTools();
      final toolCount = toolsResult.tools.length;

      _clients[config.id] = client;
      _transports[config.id] = transport;
      _statuses[config.id] = McpServerStatus(
        config: config,
        state: McpConnectionState.connected,
        toolCount: toolCount,
      );

      log.i('Connected to MCP server "${config.name}": $toolCount tools');
      return toolCount;
    } catch (e) {
      _statuses[config.id] = McpServerStatus(
        config: config,
        state: McpConnectionState.error,
        errorMessage: e.toString(),
      );
      log.e('Failed to connect to MCP server "${config.name}": $e');
      return 0;
    }
  }

  /// Disconnect from an MCP server.
  Future<void> disconnect(String serverId) async {
    final client = _clients.remove(serverId);
    _transports.remove(serverId);

    if (client != null) {
      try {
        await client.close();
      } catch (e) {
        log.w('Error closing MCP client "$serverId": $e');
      }
    }

    final config = _statuses[serverId]?.config;
    if (config != null) {
      _statuses[serverId] = McpServerStatus(
        config: config,
        state: McpConnectionState.disconnected,
      );
    }

    log.i('Disconnected from MCP server "$serverId"');
  }

  /// Register all tools from connected MCP servers into a ToolRegistry.
  Future<void> registerTools(ToolRegistry registry) async {
    for (final entry in _clients.entries) {
      final serverId = entry.key;
      final client = entry.value;
      final config = _statuses[serverId]?.config;
      if (config == null) continue;

      await _registerServerTools(config, client, registry);
    }
  }

  Future<void> _registerServerTools(
    McpServerConfig config,
    mcp.McpClient client,
    ToolRegistry registry,
  ) async {
    try {
      final toolsResult = await client.listTools();
      for (final tool in toolsResult.tools) {
        registry.register(McpToolAdapter(
          serverName: config.name,
          mcpTool: tool,
          mcpClient: client,
        ));
      }
    } catch (e) {
      log.e('Failed to register tools from "${config.name}": $e');
    }
  }

  /// Connect to all saved MCP servers.
  Future<void> connectAll() async {
    final configs = await _configStore.loadConfigs();
    for (final config in configs) {
      await connect(config);
    }
  }

  /// Disconnect all servers and clean up.
  Future<void> disconnectAll() async {
    final serverIds = _clients.keys.toList();
    for (final id in serverIds) {
      await disconnect(id);
    }
  }

  mcp.Transport _createTransport(McpServerConfig config) {
    switch (config.transport) {
      case McpTransportType.stdio:
        return mcp.StdioClientTransport(
          mcp.StdioServerParameters(
            command: config.command!,
            args: config.args ?? [],
            environment: config.env,
          ),
        );
      case McpTransportType.sse:
        return mcp.StreamableHttpClientTransport(
          Uri.parse(config.url!),
        );
    }
  }

  /// Dispose all connections.
  Future<void> dispose() async {
    await disconnectAll();
  }
}
