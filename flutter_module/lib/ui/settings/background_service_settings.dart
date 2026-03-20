import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

/// Settings section for foreground service and briefing configuration.
/// UI Spec: BackgroundServiceSettings component.
class BackgroundServiceSettings extends ConsumerStatefulWidget {
  const BackgroundServiceSettings({super.key});

  @override
  ConsumerState<BackgroundServiceSettings> createState() => _BackgroundServiceSettingsState();
}

class _BackgroundServiceSettingsState extends ConsumerState<BackgroundServiceSettings> {
  bool _serviceRunning = false;
  bool _briefingEnabled = true;
  bool _nudgeEnabled = true;
  TimeOfDay _briefingTime = const TimeOfDay(hour: 7, minute: 30);

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    final manager = ref.read(foregroundServiceManagerProvider);
    final running = await manager.isRunning();
    if (mounted) setState(() => _serviceRunning = running);
  }

  Future<void> _toggleService(bool enabled) async {
    final manager = ref.read(foregroundServiceManagerProvider);
    if (enabled) {
      await manager.startService();
    } else {
      await manager.stopService();
    }
    await _checkServiceStatus();
  }

  Future<void> _pickBriefingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _briefingTime,
    );
    if (picked != null) {
      setState(() => _briefingTime = picked);
      // TODO: persist to shared preferences and update BriefingEngine
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
          child: Text('Background Service', style: textTheme.titleMedium),
        ),
        SwitchListTile(
          title: const Text('Background service'),
          subtitle: Text(
            _serviceRunning ? 'Running' : 'Stopped',
            style: textTheme.bodySmall?.copyWith(
              color: _serviceRunning ? colorScheme.primary : colorScheme.error,
            ),
          ),
          secondary: Icon(
            Icons.circle,
            size: 8,
            color: _serviceRunning ? colorScheme.primary : colorScheme.error,
          ),
          value: _serviceRunning,
          onChanged: _toggleService,
        ),
        SwitchListTile(
          title: const Text('Morning briefing'),
          value: _briefingEnabled,
          onChanged: (value) => setState(() => _briefingEnabled = value),
        ),
        ListTile(
          title: const Text('Briefing time'),
          trailing: Text(_briefingTime.format(context)),
          onTap: _pickBriefingTime,
        ),
        SwitchListTile(
          title: const Text('Stuck detection'),
          value: _nudgeEnabled,
          onChanged: (value) => setState(() => _nudgeEnabled = value),
        ),
        const Divider(),
      ],
    );
  }
}
