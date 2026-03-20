import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../services/vessels/openclaw/openclaw_client.dart';
import '../../services/vessels/openclaw/openclaw_config.dart';
import '../../services/vessels/models/vessel_connection.dart';

/// OpenClaw Gateway settings: host, token, TLS, test connection.
class OpenClawSettings extends ConsumerStatefulWidget {
  const OpenClawSettings({super.key});

  @override
  ConsumerState<OpenClawSettings> createState() => _OpenClawSettingsState();
}

enum _ConnectionTestState { idle, testing, connected, error }

class _OpenClawSettingsState extends ConsumerState<OpenClawSettings> {
  final _hostController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _useTls = true;
  _ConnectionTestState _testState = _ConnectionTestState.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final apiKeyService = ref.read(apiKeyServiceProvider);
    final host = await apiKeyService.getOpenClawHost();
    final token = await apiKeyService.getOpenClawToken();
    final useTls = await apiKeyService.getOpenClawUseTls();
    if (mounted) {
      setState(() {
        _hostController.text = host ?? '';
        _tokenController.text = token ?? '';
        _useTls = useTls;
      });
    }
  }

  Future<void> _testAndSave() async {
    final host = _hostController.text.trim();
    final token = _tokenController.text.trim();

    if (host.isEmpty || token.isEmpty) {
      setState(() {
        _testState = _ConnectionTestState.error;
        _errorMessage = 'Vul host en token in';
      });
      return;
    }

    setState(() {
      _testState = _ConnectionTestState.testing;
      _errorMessage = null;
    });

    final config = OpenClawConfig(
      host: host,
      port: _useTls ? 443 : 18789,
      token: token,
      useTls: _useTls,
    );
    final client = OpenClawClient(config: config);

    try {
      final connection = await client.connect();
      if (!mounted) return;

      if (connection.status == ConnectionStatus.connected) {
        final apiKeyService = ref.read(apiKeyServiceProvider);
        await apiKeyService.saveOpenClawHost(host);
        await apiKeyService.saveOpenClawToken(token);
        await apiKeyService.saveOpenClawUseTls(_useTls);

        // Activate client in VesselManager
        ref.read(vesselManagerProvider).setOpenClawClient(client);

        setState(() => _testState = _ConnectionTestState.connected);
      } else {
        client.dispose();
        setState(() {
          _testState = _ConnectionTestState.error;
          _errorMessage = connection.errorMessage ?? 'Verbinding mislukt';
        });
      }
    } catch (e) {
      client.dispose();
      if (mounted) {
        setState(() {
          _testState = _ConnectionTestState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _pasteToken() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _tokenController.text = data!.text!.trim();
    }
  }

  Future<void> _disconnect() async {
    final apiKeyService = ref.read(apiKeyServiceProvider);
    await apiKeyService.deleteOpenClawCredentials();
    ref.read(vesselManagerProvider).removeOpenClawClient();
    if (mounted) {
      _hostController.clear();
      _tokenController.clear();
      setState(() {
        _testState = _ConnectionTestState.idle;
        _useTls = true;
      });
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
          child: Text('OpenClaw Gateway', style: textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Verbind SOUL met je OpenClaw server voor tools, multi-agent, webhooks en meer.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Host input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _hostController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Host',
              hintText: '91-99-232-59.sslip.io',
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
        const SizedBox(height: 4),

        // TLS toggle
        SwitchListTile(
          title: const Text('TLS (HTTPS/443)'),
          subtitle: const Text('Uit = poort 18789'),
          value: _useTls,
          onChanged: (value) => setState(() => _useTls = value),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: _testState == _ConnectionTestState.testing
                    ? null
                    : _testAndSave,
                child: _testState == _ConnectionTestState.testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verbinden & opslaan'),
              ),
              if (_testState == _ConnectionTestState.connected) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _disconnect,
                  child: Text(
                    'Verwijderen',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Status feedback
        if (_testState == _ConnectionTestState.connected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                const Text('Verbonden met OpenClaw'),
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
        const SizedBox(height: 8),
      ],
    );
  }
}
