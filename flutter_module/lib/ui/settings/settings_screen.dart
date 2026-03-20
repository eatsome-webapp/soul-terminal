import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'permission_status_settings.dart';
import 'agentic_settings.dart';
import 'background_service_settings.dart';
import 'notification_filter_settings.dart';
import 'byok_settings.dart';
import 'vessel_settings.dart';
import 'openclaw_settings.dart';
import 'privacy_settings.dart';
import 'intervention_settings.dart';
import 'trust_tier_settings.dart';

/// Main Settings screen assembling all settings sections.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instellingen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsCard(child: ByokSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: OpenClawSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: VesselSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: PermissionStatusSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: AgenticSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: BackgroundServiceSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: NotificationFilterSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: InterventionSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: TrustTierSettings()),
            SizedBox(height: 12),
            _SettingsCard(child: PrivacySettings()),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
