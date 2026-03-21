import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'intervention_config.g.dart';

class InterventionConfig {
  final int decisionNudgeHours;
  final int decisionConfrontHours;
  final int decisionProposeHours;
  final double stucknessThreshold;
  final int stucknessCooldownDays;
  final int inactivityThresholdHours;
  final List<int> deadlineWarningDays;
  final int moodAnalysisFrequency;
  final int lowEnergyThreshold;
  final List<String> autonomousTools;
  final List<String> softApprovalTools;
  final List<String> hardApprovalTools;
  final int killSwitchMaxRuntimeMinutes;
  final int killSwitchStopTimeoutSeconds;

  const InterventionConfig({
    this.decisionNudgeHours = 4,
    this.decisionConfrontHours = 8,
    this.decisionProposeHours = 24,
    this.stucknessThreshold = 0.6,
    this.stucknessCooldownDays = 7,
    this.inactivityThresholdHours = 24,
    this.deadlineWarningDays = const [7, 3, 1],
    this.moodAnalysisFrequency = 3,
    this.lowEnergyThreshold = 2,
    this.autonomousTools = const [
      'ci_status',
      'git_log',
      'git_diff',
      'memory_update',
      'briefing_generate',
      'calendar_read',
      'notification_read',
    ],
    this.softApprovalTools = const [
      'ci_diagnose',
      'pr_draft',
      'label_add',
      'comment_add',
      'lint_fix',
    ],
    this.hardApprovalTools = const ['deploy', 'pr_merge', 'message_send'],
    this.killSwitchMaxRuntimeMinutes = 10,
    this.killSwitchStopTimeoutSeconds = 5,
  });

  factory InterventionConfig.defaults() => const InterventionConfig();

  factory InterventionConfig.fromYaml(YamlMap yaml) {
    final intervention = yaml['intervention'] as YamlMap?;
    final decision = intervention?['decision_delay'] as YamlMap?;
    final stuckness = intervention?['stuckness'] as YamlMap?;
    final inactivity = intervention?['inactivity'] as YamlMap?;
    final deadline = intervention?['deadline_proximity'] as YamlMap?;
    final mood = yaml['mood'] as YamlMap?;
    final tiers = yaml['trust_tiers'] as YamlMap?;
    final killSwitch = yaml['kill_switch'] as YamlMap?;

    return InterventionConfig(
      decisionNudgeHours: decision?['nudge_hours'] as int? ?? 4,
      decisionConfrontHours: decision?['confront_hours'] as int? ?? 8,
      decisionProposeHours: decision?['propose_hours'] as int? ?? 24,
      stucknessThreshold:
          (stuckness?['threshold'] as num?)?.toDouble() ?? 0.6,
      stucknessCooldownDays: stuckness?['cooldown_days'] as int? ?? 7,
      inactivityThresholdHours: inactivity?['threshold_hours'] as int? ?? 24,
      deadlineWarningDays:
          (deadline?['warning_days'] as YamlList?)?.cast<int>() ?? [7, 3, 1],
      moodAnalysisFrequency: mood?['analysis_frequency'] as int? ?? 3,
      lowEnergyThreshold: mood?['low_energy_threshold'] as int? ?? 2,
      autonomousTools: (tiers?['autonomous'] as YamlList?)?.cast<String>() ??
          const [
            'ci_status',
            'git_log',
            'git_diff',
            'memory_update',
            'briefing_generate',
            'calendar_read',
            'notification_read',
          ],
      softApprovalTools:
          (tiers?['soft_approval'] as YamlList?)?.cast<String>() ??
              const [
                'ci_diagnose',
                'pr_draft',
                'label_add',
                'comment_add',
                'lint_fix',
              ],
      hardApprovalTools:
          (tiers?['hard_approval'] as YamlList?)?.cast<String>() ??
              const ['deploy', 'pr_merge', 'message_send'],
      killSwitchMaxRuntimeMinutes:
          killSwitch?['max_runtime_minutes'] as int? ?? 10,
      killSwitchStopTimeoutSeconds:
          killSwitch?['stop_timeout_seconds'] as int? ?? 5,
    );
  }
}

@riverpod
Future<InterventionConfig> interventionConfig(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/soul_config.yaml');
  if (await file.exists()) {
    try {
      final yaml = loadYaml(await file.readAsString()) as YamlMap;
      return InterventionConfig.fromYaml(yaml);
    } catch (_) {
      return InterventionConfig.defaults();
    }
  }
  // Copy default from assets on first use
  final defaultYaml = await rootBundle
      .loadString('assets/config/default_intervention_config.yaml');
  await file.writeAsString(defaultYaml);
  final yaml = loadYaml(defaultYaml) as YamlMap;
  return InterventionConfig.fromYaml(yaml);
}
