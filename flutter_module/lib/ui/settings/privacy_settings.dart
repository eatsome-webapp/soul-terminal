import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/sentry_config.dart';

/// Key for crash reporting preference in secure storage.
const _crashReportingKey = 'crash_reporting_enabled';

/// Privacy settings section with crash reporting opt-out toggle.
class PrivacySettings extends ConsumerStatefulWidget {
  const PrivacySettings({super.key});

  @override
  ConsumerState<PrivacySettings> createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends ConsumerState<PrivacySettings> {
  static const _storage = FlutterSecureStorage();
  bool _crashReportingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final value = await _storage.read(key: _crashReportingKey);
    if (mounted) {
      setState(() => _crashReportingEnabled = value != 'false');
    }
  }

  Future<void> _toggleCrashReporting(bool enabled) async {
    setState(() => _crashReportingEnabled = enabled);
    await _storage.write(
      key: _crashReportingKey,
      value: enabled.toString(),
    );

    if (!enabled) {
      await SentryConfig.close();
    }
    // Re-enabling requires app restart — Sentry can't be re-initialized mid-run
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Privacy', style: textTheme.titleMedium),
        ),
        SwitchListTile(
          title: const Text('Crashrapportage'),
          subtitle: const Text(
            'Stuur automatische foutmeldingen (geen persoonlijke data)',
          ),
          value: _crashReportingEnabled,
          onChanged: _toggleCrashReporting,
        ),
        const Divider(),
      ],
    );
  }
}
