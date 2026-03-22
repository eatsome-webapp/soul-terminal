import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../services/database/daos/settings_dao.dart';
import '../../services/profile_pack/profile_pack_service.dart';

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
  String _updateFrequency = 'daily';
  bool _updateAvailable = false;
  String _updateProfileId = '';
  String _updateRemoteVersion = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadUpdateSettings();
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

  Future<void> _loadUpdateSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final frequency = await settingsDao.getString(SettingsKeys.profileUpdateCheckFrequency) ?? 'daily';
    final available = await settingsDao.getBool(SettingsKeys.profileUpdateAvailable) ?? false;
    final profileId = await settingsDao.getString(SettingsKeys.profileUpdateProfileId) ?? '';
    final remoteVersion = await settingsDao.getString(SettingsKeys.profileUpdateRemoteVersion) ?? '';
    if (mounted) {
      setState(() {
        _updateFrequency = frequency;
        _updateAvailable = available;
        _updateProfileId = profileId;
        _updateRemoteVersion = remoteVersion;
      });
    }
  }

  Future<void> _setUpdateFrequency(String? value) async {
    if (value == null) return;
    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setString(SettingsKeys.profileUpdateCheckFrequency, value);
    setState(() => _updateFrequency = value);
  }

  Future<void> _performUpdate() async {
    setState(() => _isUpdating = true);
    try {
      final packService = ProfilePackService();
      final manifest = await packService.fetchManifest();
      final profile = manifest.profiles.where((p) => p.id == _updateProfileId).firstOrNull;

      if (profile == null || !profile.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Update niet beschikbaar')),
          );
        }
        return;
      }

      final zipPath = await packService.downloadPack(profile, (_) {});
      await packService.installPack(profile, zipPath);

      // Clear update flag
      final settingsDao = ref.read(settingsDaoProvider);
      await settingsDao.setBool(SettingsKeys.profileUpdateAvailable, false);

      if (mounted) {
        setState(() {
          _updateAvailable = false;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_updateProfileId bijgewerkt naar $_updateRemoteVersion')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update mislukt: $e')),
        );
      }
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Profile Updates', style: textTheme.titleMedium),
        ),
        ListTile(
          title: const Text('Update frequentie'),
          trailing: DropdownButton<String>(
            value: _updateFrequency,
            onChanged: _setUpdateFrequency,
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Dagelijks')),
              DropdownMenuItem(value: 'weekly', child: Text('Wekelijks')),
              DropdownMenuItem(value: 'never', child: Text('Nooit')),
            ],
          ),
        ),
        if (_updateAvailable) ...[
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.primaryContainer,
            child: ListTile(
              leading: Icon(Icons.system_update, color: colorScheme.primary),
              title: Text('Update beschikbaar: $_updateProfileId'),
              subtitle: Text('Versie $_updateRemoteVersion'),
              trailing: _isUpdating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FilledButton(
                      onPressed: _performUpdate,
                      child: const Text('Nu updaten'),
                    ),
            ),
          ),
        ],
        const Divider(),
      ],
    );
  }
}
