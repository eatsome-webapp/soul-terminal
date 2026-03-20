import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

/// Settings section for notification monitoring allowlist.
/// UI Spec: NotificationFilterSettings component.
class NotificationFilterSettings extends ConsumerStatefulWidget {
  const NotificationFilterSettings({super.key});

  @override
  ConsumerState<NotificationFilterSettings> createState() => _NotificationFilterSettingsState();
}

class _NotificationFilterSettingsState extends ConsumerState<NotificationFilterSettings> {
  bool _listenerEnabled = false;

  final Map<String, bool> _devTools = {
    'com.github.android': true,
  };
  final Map<String, bool> _communication = {
    'com.slack': true,
    'com.discord': false,
    'org.telegram.messenger': false,
    'com.whatsapp': false,
  };
  final Map<String, bool> _email = {
    'com.google.android.gm': true,
  };

  static const _appNames = {
    'com.github.android': 'GitHub',
    'com.slack': 'Slack',
    'com.discord': 'Discord',
    'org.telegram.messenger': 'Telegram',
    'com.whatsapp': 'WhatsApp',
    'com.google.android.gm': 'Gmail',
  };

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permService = ref.read(permissionServiceProvider);
    final enabled = await permService.isNotificationListenerEnabled();
    if (mounted) setState(() => _listenerEnabled = enabled);
  }

  Future<void> _requestPermission() async {
    final permService = ref.read(permissionServiceProvider);
    await permService.openNotificationListenerSettings();
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
          child: Text('Notification Monitoring', style: textTheme.titleMedium),
        ),
        ListTile(
          title: const Text('Notification access'),
          trailing: ActionChip(
            label: Text(_listenerEnabled ? 'Enabled' : 'Tap to enable'),
            backgroundColor: _listenerEnabled
                ? colorScheme.primary.withOpacity(0.12)
                : colorScheme.tertiaryContainer,
            onPressed: _listenerEnabled ? null : _requestPermission,
          ),
        ),
        if (_listenerEnabled) ...[
          _buildCategory('Dev tools', _devTools),
          _buildCategory('Communication', _communication),
          _buildCategory('Email', _email),
        ],
        const Divider(),
      ],
    );
  }

  Widget _buildCategory(String title, Map<String, bool> apps) {
    return ExpansionTile(
      title: Text(title),
      children: apps.entries.map((entry) {
        return SwitchListTile(
          title: Text(_appNames[entry.key] ?? entry.key),
          value: entry.value,
          dense: true,
          onChanged: (value) {
            setState(() => apps[entry.key] = value);
            // TODO: update NotificationMonitor allowedPackages
          },
        );
      }).toList(),
    );
  }
}
