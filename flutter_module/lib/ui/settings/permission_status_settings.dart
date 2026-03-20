import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../services/platform/notification_monitor.dart';

/// Settings section showing status of all Phase 4 permissions.
/// Each row shows status, description, and action button.
class PermissionStatusSettings extends ConsumerStatefulWidget {
  const PermissionStatusSettings({super.key});

  @override
  ConsumerState<PermissionStatusSettings> createState() =>
      _PermissionStatusSettingsState();
}

class _PermissionStatusSettingsState
    extends ConsumerState<PermissionStatusSettings> {
  Map<String, bool> _permissions = {};
  NlsHealthStatus _nlsHealth = NlsHealthStatus.unknown;
  StreamSubscription<NlsHealthStatus>? _nlsSubscription;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    final monitor = ref.read(notificationMonitorProvider);
    _nlsHealth = monitor.currentHealthStatus;
    _nlsSubscription = monitor.healthStatus.listen((status) {
      if (mounted) setState(() => _nlsHealth = status);
    });
  }

  @override
  void dispose() {
    _nlsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    final permService = ref.read(permissionServiceProvider);
    final states = await permService.getAllPermissionStates();
    if (mounted) setState(() => _permissions = states);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final permissionEntries = [
      _PermissionEntry(
        key: 'contacts',
        label: 'Contacts',
        icon: Icons.contacts,
        subtitle: 'Resolve names in briefings and calendar events',
      ),
      _PermissionEntry(
        key: 'calendar',
        label: 'Calendar',
        icon: Icons.calendar_today,
        subtitle: 'Include your schedule in morning briefings',
      ),
      _PermissionEntry(
        key: 'notifications',
        label: 'Notifications',
        icon: Icons.notifications,
        subtitle: 'Send briefings and nudges',
      ),
      _PermissionEntry(
        key: 'notificationListener',
        label: 'Notification access',
        icon: Icons.notifications_active,
        subtitle: 'Monitor other apps for relevant alerts',
        isSpecial: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Permissions', style: textTheme.titleMedium),
        ),
        ...permissionEntries.map((entry) {
          final granted = _permissions[entry.key] ?? false;
          return ListTile(
            leading: Icon(entry.icon),
            title: Text(entry.label),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.subtitle),
                if (!granted && entry.isSpecial)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Opens system settings — find SOUL and toggle on',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                if (entry.key == 'notificationListener' &&
                    granted &&
                    _nlsHealth == NlsHealthStatus.disconnected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Niet verbonden — SOUL kan geen notificaties lezen',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: _buildTrailing(entry, granted, colorScheme),
            onTap: granted ? null : () => _requestPermission(entry.key),
          );
        }),
        const Divider(),
      ],
    );
  }

  Widget _buildTrailing(
    _PermissionEntry entry,
    bool granted,
    ColorScheme colorScheme,
  ) {
    if (!granted) {
      return FilledButton.tonal(
        onPressed: () => _requestPermission(entry.key),
        child: const Text('Grant'),
      );
    }

    // NLS health-aware trailing for notificationListener
    if (entry.key == 'notificationListener') {
      switch (_nlsHealth) {
        case NlsHealthStatus.reconnecting:
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        case NlsHealthStatus.disconnected:
          return Icon(Icons.error, color: colorScheme.error);
        case NlsHealthStatus.connected:
        case NlsHealthStatus.unknown:
          return Icon(Icons.check_circle, color: colorScheme.primary);
      }
    }

    return Icon(Icons.check_circle, color: colorScheme.primary);
  }

  Future<void> _requestPermission(String key) async {
    final permService = ref.read(permissionServiceProvider);

    switch (key) {
      case 'contacts':
        await permService.requestContactsPermission();
      case 'calendar':
        await permService.requestCalendarPermission();
      case 'notifications':
        await permService.requestNotificationPermission();
      case 'notificationListener':
        if (mounted) {
          _showNotificationListenerGuide();
        }
        await permService.openNotificationListenerSettings();
    }
    await _loadPermissions();
  }

  void _showNotificationListenerGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification access'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOUL needs notification access to monitor alerts from '
              'other apps (GitHub, Slack, etc.) and include relevant '
              'ones in your briefings.',
            ),
            SizedBox(height: 16),
            Text(
              'On the next screen:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Find "SOUL" in the list'),
            Text('2. Tap to open it'),
            Text('3. Toggle the switch ON'),
            Text('4. Confirm the warning (your data stays on-device)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _PermissionEntry {
  final String key;
  final String label;
  final IconData icon;
  final String subtitle;
  final bool isSpecial;

  const _PermissionEntry({
    required this.key,
    required this.label,
    required this.icon,
    required this.subtitle,
    this.isSpecial = false,
  });
}
