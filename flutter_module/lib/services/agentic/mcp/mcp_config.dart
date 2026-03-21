import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/logger.dart';

/// Transport type for MCP server connection.
enum McpTransportType { stdio, sse }

/// Configuration for a single MCP server.
class McpServerConfig {
  final String id;
  final String name;
  final McpTransportType transport;

  // For SSE transport
  final String? url;
  final Map<String, String>? headers;

  // For stdio transport
  final String? command;
  final List<String>? args;
  final Map<String, String>? env;

  const McpServerConfig({
    required this.id,
    required this.name,
    required this.transport,
    this.url,
    this.headers,
    this.command,
    this.args,
    this.env,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'transport': transport.name,
        'url': url,
        'headers': headers,
        'command': command,
        'args': args,
        'env': env,
      };

  factory McpServerConfig.fromJson(Map<String, dynamic> json) {
    return McpServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      transport: McpTransportType.values.byName(json['transport'] as String),
      url: json['url'] as String?,
      headers:
          (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
      command: json['command'] as String?,
      args: (json['args'] as List<dynamic>?)?.cast<String>(),
      env: (json['env'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }
}

/// Manages MCP server configuration persistence.
///
/// Stores configs as JSON in app documents directory (mcp_servers.json).
class McpConfigStore {
  static const _fileName = 'mcp_servers.json';

  /// Load all saved MCP server configurations.
  Future<List<McpServerConfig>> loadConfigs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      if (!await file.exists()) return [];

      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final servers = (json['mcpServers'] as Map<String, dynamic>?) ?? {};

      return servers.entries.map((entry) {
        final config = entry.value as Map<String, dynamic>;
        return McpServerConfig.fromJson({...config, 'id': entry.key});
      }).toList();
    } catch (e) {
      log.w('Failed to load MCP configs: $e');
      return [];
    }
  }

  /// Save MCP server configurations.
  Future<void> saveConfigs(List<McpServerConfig> configs) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');

      final servers = <String, dynamic>{};
      for (final config in configs) {
        servers[config.id] = config.toJson()..remove('id');
      }

      final json = jsonEncode({'mcpServers': servers});
      await file.writeAsString(json);
      log.d('Saved ${configs.length} MCP server configs');
    } catch (e) {
      log.e('Failed to save MCP configs: $e');
    }
  }

  /// Add or update a server config.
  Future<void> upsertConfig(McpServerConfig config) async {
    final configs = await loadConfigs();
    final index = configs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      configs[index] = config;
    } else {
      configs.add(config);
    }
    await saveConfigs(configs);
  }

  /// Remove a server config by id.
  Future<void> removeConfig(String id) async {
    final configs = await loadConfigs();
    configs.removeWhere((c) => c.id == id);
    await saveConfigs(configs);
  }
}
