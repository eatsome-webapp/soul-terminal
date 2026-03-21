import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../services/agentic/mcp/mcp_config.dart';

/// Bottom sheet form for adding/editing an MCP server configuration.
class McpServerFormSheet extends StatefulWidget {
  final McpServerConfig? existing;

  const McpServerFormSheet({super.key, this.existing});

  @override
  State<McpServerFormSheet> createState() => _McpServerFormSheetState();

  static Future<McpServerConfig?> show(
    BuildContext context, {
    McpServerConfig? existing,
  }) {
    return showModalBottomSheet<McpServerConfig>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: McpServerFormSheet(existing: existing),
      ),
    );
  }
}

class _McpServerFormSheetState extends State<McpServerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _commandController;
  late McpTransportType _transport;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _urlController = TextEditingController(text: widget.existing?.url ?? '');
    _commandController =
        TextEditingController(text: widget.existing?.command ?? '');
    _transport = widget.existing?.transport ?? McpTransportType.sse;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final config = McpServerConfig(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      transport: _transport,
      url: _transport == McpTransportType.sse
          ? _urlController.text.trim()
          : null,
      command: _transport == McpTransportType.stdio
          ? _commandController.text.trim()
          : null,
    );

    Navigator.of(context).pop(config);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing != null ? 'Edit MCP server' : 'Add MCP server',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Server name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            SegmentedButton<McpTransportType>(
              segments: const [
                ButtonSegment(
                    value: McpTransportType.sse, label: Text('HTTP/SSE')),
                ButtonSegment(
                    value: McpTransportType.stdio, label: Text('stdio')),
              ],
              selected: {_transport},
              onSelectionChanged: (selected) {
                setState(() => _transport = selected.first);
              },
            ),
            const SizedBox(height: 12),
            if (_transport == McpTransportType.sse)
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://localhost:8080/mcp',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            if (_transport == McpTransportType.stdio)
              TextFormField(
                controller: _commandController,
                decoration: const InputDecoration(
                  labelText: 'Command',
                  hintText: '/path/to/mcp-server',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(widget.existing != null ? 'Save' : 'Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
