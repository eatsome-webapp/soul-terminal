import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/vessels/models/vessel_connection.dart';
import '../../services/vessels/models/vessel_task.dart';
import '../settings/background_service_settings.dart';
import '../settings/notification_filter_settings.dart';
import '../settings/permission_status_settings.dart';
import '../../core/di/providers.dart';
import '../../services/database/daos/settings_dao.dart';
import 'vessel_settings_provider.dart';
import 'vessel_status_indicator.dart';

/// Settings screen for configuring vessel connections (OpenClaw, Agent SDK).
///
/// Provides host/port/token input for each vessel type with
/// test connection and disconnect functionality.
class VesselSettingsScreen extends ConsumerStatefulWidget {
  const VesselSettingsScreen({super.key});

  @override
  ConsumerState<VesselSettingsScreen> createState() =>
      _VesselSettingsScreenState();
}

class _VesselSettingsScreenState extends ConsumerState<VesselSettingsScreen> {
  // API key fields
  final _apiKeyController = TextEditingController();
  bool _apiKeyVisible = false;

  // OpenClaw fields
  final _openClawHostController = TextEditingController();
  final _openClawPortController = TextEditingController();
  final _openClawTokenController = TextEditingController();
  final _openClawUrlPrefixController = TextEditingController();
  bool _openClawTokenVisible = false;
  bool _openClawUseTls = true;

  // Agent SDK fields
  final _agentSdkUrlController = TextEditingController();
  final _agentSdkTokenController = TextEditingController();
  bool _agentSdkTokenVisible = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from saved state after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(vesselSettingsNotifierProvider);
      if (settings.openClawHost.isNotEmpty) {
        _openClawHostController.text = settings.openClawHost;
        _openClawPortController.text = settings.openClawPort.toString();
        _openClawUrlPrefixController.text = settings.openClawUrlPrefix;
        setState(() => _openClawUseTls = settings.openClawUseTls);
      }
      if (settings.agentSdkUrl.isNotEmpty) {
        _agentSdkUrlController.text = settings.agentSdkUrl;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _openClawHostController.dispose();
    _openClawPortController.dispose();
    _openClawTokenController.dispose();
    _openClawUrlPrefixController.dispose();
    _agentSdkUrlController.dispose();
    _agentSdkTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(vesselSettingsNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasAnyConnection =
        settings.openClawStatus == ConnectionStatus.connected ||
            settings.agentSdkStatus == ConnectionStatus.connected ||
            settings.openClawHost.isNotEmpty ||
            settings.agentSdkUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vessels'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!hasAnyConnection) _buildEmptyState(colorScheme, textTheme),

          // Anthropic API Key section
          _buildSectionHeader(context, 'Anthropic API Key'),
          const SizedBox(height: 8),
          _buildApiKeyCard(context, settings),
          const SizedBox(height: 24),

          // OpenClaw section
          _buildSectionHeader(context, 'OpenClaw'),
          const SizedBox(height: 8),
          _buildOpenClawCard(context, settings),
          const SizedBox(height: 24),

          // Agent SDK section
          _buildSectionHeader(context, 'Agent SDK'),
          const SizedBox(height: 8),
          _buildAgentSdkCard(context, settings),
          const SizedBox(height: 24),

          // Phase 4: Background service settings
          const BackgroundServiceSettings(),
          const SizedBox(height: 8),

          // Phase 4: Notification filter settings
          const NotificationFilterSettings(),
          const SizedBox(height: 8),

          // Phase 4: Permission status settings
          const PermissionStatusSettings(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.hub_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No vessels connected',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to OpenClaw or Agent SDK to start orchestrating tasks from your phone.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildApiKeyCard(BuildContext context, VesselSettingsState settings) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              children: [
                Icon(
                  settings.hasApiKey ? Icons.check_circle : Icons.warning_amber,
                  size: 16,
                  color: settings.hasApiKey
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  settings.hasApiKey ? 'Key configured' : 'No key set',
                  style: textTheme.bodySmall?.copyWith(
                    color: settings.hasApiKey
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Key input
            TextFormField(
              controller: _apiKeyController,
              obscureText: !_apiKeyVisible,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: settings.hasApiKey ? 'Enter new key to replace' : 'Paste API key',
                hintText: 'sk-ant-api03-...',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _apiKeyVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _apiKeyVisible = !_apiKeyVisible),
                    ),
                    IconButton(
                      icon: const Icon(Icons.paste_outlined),
                      tooltip: 'Paste',
                      onPressed: () async {
                        final data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          setState(() {
                            _apiKeyController.text = data!.text!.trim();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                if (settings.hasApiKey)
                  TextButton(
                    onPressed: _confirmDeleteApiKey,
                    child: Text(
                      'Remove key',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _apiKeyController.text.trim().startsWith('sk-ant-')
                      ? _saveApiKey
                      : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (!key.startsWith('sk-ant-')) return;

    await ref
        .read(vesselSettingsNotifierProvider.notifier)
        .saveApiKey(key);

    _apiKeyController.clear();

    if (mounted) {
      _showSnackBar('API key saved');
    }
  }

  Future<void> _confirmDeleteApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove API key'),
        content: const Text(
          'SOUL will stop working until you add a new key.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(vesselSettingsNotifierProvider.notifier)
          .deleteApiKey();
      _showSnackBar('API key removed');
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildOpenClawCard(
    BuildContext context,
    VesselSettingsState settings,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            VesselStatusIndicator(
              vesselName: 'OpenClaw',
              status: settings.openClawStatus,
            ),
            const SizedBox(height: 16),

            // Host field
            TextFormField(
              controller: _openClawHostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: 'localhost',
              ),
            ),
            const SizedBox(height: 12),

            // Port field
            TextFormField(
              controller: _openClawPortController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '18789',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // URL prefix field (optional, for reverse proxy setups)
            TextFormField(
              controller: _openClawUrlPrefixController,
              decoration: const InputDecoration(
                labelText: 'URL prefix (optioneel)',
                hintText: '/api',
                helperText: 'Laat leeg tenzij achter reverse proxy',
              ),
            ),
            const SizedBox(height: 12),

            // TLS toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use HTTPS / WSS'),
              value: _openClawUseTls,
              onChanged: (value) => setState(() => _openClawUseTls = value),
            ),
            const SizedBox(height: 4),

            // Token field (obscured)
            TextFormField(
              controller: _openClawTokenController,
              decoration: InputDecoration(
                labelText: 'Token',
                hintText: 'Enter token',
                suffixIcon: IconButton(
                  icon: Icon(
                    _openClawTokenVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _openClawTokenVisible = !_openClawTokenVisible;
                    });
                  },
                ),
              ),
              obscureText: !_openClawTokenVisible,
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                if (settings.openClawStatus == ConnectionStatus.connected)
                  TextButton(
                    onPressed: () => _confirmDisconnect(VesselType.openClaw),
                    child: Text(
                      'Disconnect',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: settings.isTesting ? null : _testOpenClaw,
                  icon: settings.isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Test connection'),
                ),
              ],
            ),

            // Setup Guide button — re-trigger onboarding
            if (settings.openClawStatus == ConnectionStatus.connected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Reset bootstrap state
                    final settingsDao = ref.read(settingsDaoProvider);
                    await settingsDao.setString(
                      SettingsKeys.vesselBootstrapStep('openclaw'),
                      '0',
                    );
                    await settingsDao.setString(
                      SettingsKeys.vesselBootstrapCompleted('openclaw'),
                      'false',
                    );
                    // Trigger onboarding message
                    ref.read(onboardingPendingProvider.notifier).state =
                        OnboardingPending(
                      isPending: true,
                      vesselId: 'openclaw',
                      vesselName: 'OpenClaw',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Setup guide gestart — ga naar chat'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.school_outlined),
                  label: const Text('Setup Guide'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSdkCard(
    BuildContext context,
    VesselSettingsState settings,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            VesselStatusIndicator(
              vesselName: 'Agent SDK',
              status: settings.agentSdkStatus,
            ),
            const SizedBox(height: 16),

            // Relay URL field
            TextFormField(
              controller: _agentSdkUrlController,
              decoration: const InputDecoration(
                labelText: 'Relay URL',
                hintText: 'https://relay.example.com',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),

            // Token field (obscured)
            TextFormField(
              controller: _agentSdkTokenController,
              decoration: InputDecoration(
                labelText: 'Token',
                hintText: 'Enter token',
                suffixIcon: IconButton(
                  icon: Icon(
                    _agentSdkTokenVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _agentSdkTokenVisible = !_agentSdkTokenVisible;
                    });
                  },
                ),
              ),
              obscureText: !_agentSdkTokenVisible,
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                if (settings.agentSdkStatus == ConnectionStatus.connected)
                  TextButton(
                    onPressed: () => _confirmDisconnect(VesselType.agentSdk),
                    child: Text(
                      'Disconnect',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: settings.isTesting ? null : _testAgentSdk,
                  icon: settings.isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Test connection'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testOpenClaw() async {
    final host = _openClawHostController.text.trim();
    final portText = _openClawPortController.text.trim();
    final token = _openClawTokenController.text.trim();
    final urlPrefix = _openClawUrlPrefixController.text.trim();

    if (host.isEmpty || token.isEmpty) {
      _showSnackBar('Vul host en token in.');
      return;
    }

    final port = int.tryParse(portText) ?? 443;
    final notifier = ref.read(vesselSettingsNotifierProvider.notifier);

    await notifier.saveOpenClawConfig(
      host, port, token,
      useTls: _openClawUseTls,
      urlPrefix: urlPrefix,
    );

    if (!mounted) return;

    final state = ref.read(vesselSettingsNotifierProvider);
    if (state.openClawError == null) {
      _showSnackBar('Verbonden met OpenClaw (${state.openClawToolCount} tools geladen)');
    } else {
      _showSnackBar(state.openClawError!);
    }
  }

  Future<void> _testAgentSdk() async {
    final url = _agentSdkUrlController.text.trim();
    final token = _agentSdkTokenController.text.trim();

    if (url.isEmpty || token.isEmpty) {
      _showSnackBar('Vul relay URL en token in.');
      return;
    }

    final notifier = ref.read(vesselSettingsNotifierProvider.notifier);
    await notifier.saveAgentSdkConfig(url, token);

    if (!mounted) return;

    final state = ref.read(vesselSettingsNotifierProvider);
    if (state.agentSdkStatus == ConnectionStatus.connected) {
      _showSnackBar('Verbonden met Agent SDK');
    } else {
      _showSnackBar('Kan niet verbinden met Agent SDK');
    }
  }

  Future<void> _confirmDisconnect(VesselType type) async {
    final vesselName =
        type == VesselType.openClaw ? 'OpenClaw' : 'Agent SDK';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect'),
        content: const Text(
          'This will remove the saved connection. You can reconnect later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(vesselSettingsNotifierProvider.notifier)
          .disconnect(type);
      _showSnackBar('$vesselName disconnected');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
