import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/agentic/mcp/mcp_config.dart';
import 'mcp_server_form_sheet.dart';

/// Settings screen for managing MCP server connections.
///
/// Lists configured servers with status, allows add/edit/delete.
class McpServerSettings extends ConsumerStatefulWidget {
  const McpServerSettings({super.key});

  @override
  ConsumerState<McpServerSettings> createState() => _McpServerSettingsState();
}

class _McpServerSettingsState extends ConsumerState<McpServerSettings> {
  final McpConfigStore _configStore = McpConfigStore();
  List<McpServerConfig> _configs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final configs = await _configStore.loadConfigs();
    setState(() {
      _configs = configs;
      _loading = false;
    });
  }

  Future<void> _addServer() async {
    final config = await McpServerFormSheet.show(context);
    if (config != null) {
      await _configStore.upsertConfig(config);
      await _loadConfigs();
    }
  }

  Future<void> _editServer(McpServerConfig config) async {
    final updated = await McpServerFormSheet.show(context, existing: config);
    if (updated != null) {
      await _configStore.upsertConfig(updated);
      await _loadConfigs();
    }
  }

  Future<void> _deleteServer(McpServerConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove server'),
        content: Text('Remove "${config.name}" from MCP servers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _configStore.removeConfig(config.id);
      await _loadConfigs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_configs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.extension,
                  size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              const Text(
                'No MCP servers configured',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a server to extend SOUL with custom tools.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _addServer,
                icon: const Icon(Icons.add),
                label: const Text('Add MCP server'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _configs.length,
            itemBuilder: (context, index) {
              final config = _configs[index];
              return ListTile(
                leading: Icon(
                  config.transport == McpTransportType.sse
                      ? Icons.cloud
                      : Icons.computer,
                ),
                title: Text(config.name),
                subtitle: Text(
                  config.transport == McpTransportType.sse
                      ? config.url ?? ''
                      : config.command ?? '',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') _editServer(config);
                    if (action == 'delete') _deleteServer(config);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Remove')),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addServer,
              icon: const Icon(Icons.add),
              label: const Text('Add MCP server'),
            ),
          ),
        ),
      ],
    );
  }
}
