import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../services/vessels/agent_sdk/agent_sdk_client.dart';
import '../../services/vessels/agent_sdk/agent_sdk_config.dart';
import '../../services/vessels/models/vessel_connection.dart';

/// Agent SDK Relay settings: URL, token, test connection.
class VesselSettings extends ConsumerStatefulWidget {
  const VesselSettings({super.key});

  @override
  ConsumerState<VesselSettings> createState() => _VesselSettingsState();
}

enum _ConnectionTestState { idle, testing, connected, error }

class _VesselSettingsState extends ConsumerState<VesselSettings> {
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  _ConnectionTestState _testState = _ConnectionTestState.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final apiKeyService = ref.read(apiKeyServiceProvider);
    final url = await apiKeyService.getRelayUrl();
    final token = await apiKeyService.getRelayToken();
    if (mounted) {
      setState(() {
        _urlController.text = url ?? '';
        _tokenController.text = token ?? '';
      });
    }
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    final token = _tokenController.text.trim();

    if (url.isEmpty || token.isEmpty) {
      setState(() {
        _testState = _ConnectionTestState.error;
        _errorMessage = 'Vul zowel URL als token in';
      });
      return;
    }

    setState(() {
      _testState = _ConnectionTestState.testing;
      _errorMessage = null;
    });

    final config = AgentSdkConfig(relayUrl: url, token: token);
    final client = AgentSdkClient(config: config);

    try {
      final connection = await client.connect();
      if (!mounted) return;

      if (connection.status == ConnectionStatus.connected) {
        // Save credentials on successful test
        final apiKeyService = ref.read(apiKeyServiceProvider);
        await apiKeyService.saveRelayUrl(url);
        await apiKeyService.saveRelayToken(token);

        setState(() {
          _testState = _ConnectionTestState.connected;
        });
      } else {
        setState(() {
          _testState = _ConnectionTestState.error;
          _errorMessage = connection.errorMessage ??
              'Kan niet verbinden met relay server. Controleer of `npx soul-relay` draait.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testState = _ConnectionTestState.error;
          _errorMessage = e.toString();
        });
      }
    } finally {
      client.dispose();
    }
  }

  Future<void> _pasteToken() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _tokenController.text = data!.text!.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Agent SDK Relay', style: textTheme.titleMedium),
        ),

        // URL input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Relay URL',
              hintText: 'http://192.168.1.x:3000',
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Token input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _tokenController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Token',
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                onPressed: _pasteToken,
                tooltip: 'Plakken',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Test connection button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed:
                _testState == _ConnectionTestState.testing ? null : _testConnection,
            child: _testState == _ConnectionTestState.testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Test verbinding'),
          ),
        ),
        const SizedBox(height: 8),

        // Connection status feedback
        if (_testState == _ConnectionTestState.testing)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Verbinden...'),
              ],
            ),
          ),
        if (_testState == _ConnectionTestState.connected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                const Text('Verbonden'),
              ],
            ),
          ),
        if (_testState == _ConnectionTestState.error && _errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),

        const Divider(),
      ],
    );
  }
}
