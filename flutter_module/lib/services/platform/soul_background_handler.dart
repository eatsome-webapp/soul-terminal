import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import '../ai/briefing_engine.dart';
import '../ai/claude_service.dart';
import '../ai/intervention_config.dart';
import '../ai/intervention_engine.dart';
import '../ai/stuckness_detector.dart';
import '../database/soul_database.dart';
import '../memory/cold_migration_service.dart';
import '../memory/distillation_service.dart';
import '../memory/project_state_extractor.dart';
import '../success/celebration_service.dart';
import '../success/metrics_collector.dart';
import '../success/milestone_detector.dart';
import '../success/momentum_calculator.dart';
import '../success/streak_service.dart';
import '../success/weekly_review_engine.dart';
import '../monitoring/ci_monitor_service.dart';
import '../profile_pack/profile_pack_service.dart';
import '../profile_pack/profile_manifest.dart';
import '../database/daos/settings_dao.dart';
import 'local_notification_service.dart';

/// Top-level callback -- MUST be top-level or static.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SoulBackgroundHandler());
}

/// Background handler for SOUL's foreground service.
/// Runs in a SEPARATE isolate from the UI.
///
/// Responsibilities:
/// - Periodic checks (every 15 min via onRepeatEvent)
/// - Morning briefing time check and generation trigger
/// - Stuckness detection trigger
/// - Notification processing
///
/// Communication with main isolate via sendDataToMain/sendDataToTask.
/// Database access via separate Drift connection (isolates cannot share connections).
class SoulBackgroundHandler extends TaskHandler {
  final Logger _logger = Logger();
  late LocalNotificationService _notificationService;
  late BriefingEngine _briefingEngine;
  late StucknessDetector _stucknessDetector;
  late InterventionEngine _interventionEngine;
  late SoulDatabase _backgroundDb;
  late DistillationService _distillationService;
  late ColdMigrationService _coldMigrationService;
  late MetricsCollector _metricsCollector;
  late StreakService _streakService;
  late MilestoneDetector _milestoneDetector;
  late CelebrationService _celebrationService;
  late WeeklyReviewEngine _weeklyReviewEngine;
  late MomentumCalculator _momentumCalculator;
  late ProjectStateExtractor _projectStateExtractor;
  late CiMonitorService _ciMonitorService;
  DateTime? _lastStucknessCheck;
  DateTime? _lastProfileUpdateCheck;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _logger.i('SoulBackgroundHandler started at $timestamp by $starter');

    _notificationService = LocalNotificationService();
    await _notificationService.initialize();

    // Background isolate needs its own database connection.
    _backgroundDb = SoulDatabase();

    const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
    final claudeService = ClaudeService(apiKey: apiKey);

    _briefingEngine = BriefingEngine(
      claudeService: claudeService,
      briefingDao: _backgroundDb.briefingDao,
      calendarDao: _backgroundDb.calendarDao,
      decisionDao: _backgroundDb.decisionDao,
      notificationDao: _backgroundDb.notificationDao,
      notificationService: _notificationService,
      settingsDao: _backgroundDb.settingsDao,
      projectDao: _backgroundDb.projectDao,
      projectStateDao: _backgroundDb.projectStateDao,
    );

    _stucknessDetector = StucknessDetector(
      conversationDao: _backgroundDb.conversationDao,
      decisionDao: _backgroundDb.decisionDao,
      briefingDao: _backgroundDb.briefingDao,
      notificationService: _notificationService,
    );

    // Load intervention config from YAML
    final configFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/soul_config.yaml',
    );
    InterventionConfig config;
    if (await configFile.exists()) {
      try {
        final yaml = loadYaml(await configFile.readAsString()) as YamlMap;
        config = InterventionConfig.fromYaml(yaml);
      } catch (_) {
        config = InterventionConfig.defaults();
      }
    } else {
      config = InterventionConfig.defaults();
    }

    _interventionEngine = InterventionEngine(
      interventionDao: _backgroundDb.interventionDao,
      stucknessDetector: _stucknessDetector,
      notificationService: _notificationService,
      config: config,
      calendarDao: _backgroundDb.calendarDao,
      projectDao: _backgroundDb.projectDao,
    );

    // Phase 8: Memory Distillation & Success Tracking
    _distillationService = DistillationService(
      claudeService: claudeService,
      conversationDao: _backgroundDb.conversationDao,
      distillationDao: _backgroundDb.distillationDao,
    );

    _coldMigrationService = ColdMigrationService(
      conversationDao: _backgroundDb.conversationDao,
      settingsDao: _backgroundDb.settingsDao,
    );

    _metricsCollector = MetricsCollector(
      conversationDao: _backgroundDb.conversationDao,
      decisionDao: _backgroundDb.decisionDao,
      apiUsageDao: _backgroundDb.apiUsageDao,
      metricsDao: _backgroundDb.metricsDao,
      settingsDao: _backgroundDb.settingsDao,
    );

    _streakService = StreakService(
      streakDao: _backgroundDb.streakDao,
      notificationService: _notificationService,
    );

    _momentumCalculator = MomentumCalculator(
      metricsDao: _backgroundDb.metricsDao,
      streakDao: _backgroundDb.streakDao,
    );

    _milestoneDetector = MilestoneDetector(
      achievementDao: _backgroundDb.achievementDao,
      metricsDao: _backgroundDb.metricsDao,
      streakDao: _backgroundDb.streakDao,
    );

    _celebrationService = CelebrationService(
      achievementDao: _backgroundDb.achievementDao,
      notificationService: _notificationService,
    );

    _weeklyReviewEngine = WeeklyReviewEngine(
      claudeService: claudeService,
      weeklyReviewDao: _backgroundDb.weeklyReviewDao,
      settingsDao: _backgroundDb.settingsDao,
      metricsCollector: _metricsCollector,
      momentumCalculator: _momentumCalculator,
      streakService: _streakService,
      decisionDao: _backgroundDb.decisionDao,
      notificationService: _notificationService,
    );

    _projectStateExtractor = ProjectStateExtractor(
      claudeService: claudeService,
      conversationDao: _backgroundDb.conversationDao,
      projectDao: _backgroundDb.projectDao,
      projectStateDao: _backgroundDb.projectStateDao,
    );

    // Phase 10: CI monitoring (no OpenClaw in background — status unknown)
    _ciMonitorService = CiMonitorService(
      projectDao: _backgroundDb.projectDao,
      notificationService: _notificationService,
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    _logger.d('onRepeatEvent at $timestamp');

    FlutterForegroundTask.sendDataToMain({
      'type': 'heartbeat',
      'timestamp': timestamp.toIso8601String(),
    });

    // Check if morning briefing is due
    try {
      if (await _briefingEngine.shouldSendBriefing()) {
        await _briefingEngine.generateBriefing();
      }
    } catch (error) {
      _logger.e('Briefing check failed: $error');
    }

    // Check stuckness signals (max once per hour)
    try {
      final now = DateTime.now();
      if (_lastStucknessCheck == null ||
          now.difference(_lastStucknessCheck!).inMinutes >= 60) {
        await _stucknessDetector.detectStuckness();
        await _stucknessDetector.generateNudge();
        _lastStucknessCheck = now;
      }
    } catch (error) {
      _logger.e('Stuckness check failed: $error');
    }

    // Run all intervention triggers
    try {
      final actions = await _interventionEngine.checkAllTriggers();
      for (final action in actions) {
        await _dispatchInterventionAction(action);
      }
    } catch (error) {
      _logger.e('Intervention check failed: $error');
    }

    // Phase 8: Daily metrics aggregation (once per day)
    try {
      await _metricsCollector.runDailyAggregation();
    } catch (error) {
      _logger.e('Daily metrics aggregation failed: $error');
    }

    // Phase 8: Streak break check (once per day)
    try {
      await _streakService.checkStreakBreak();
    } catch (error) {
      _logger.e('Streak break check failed: $error');
    }

    // Phase 8: Milestone detection (after metrics)
    try {
      final milestones = await _milestoneDetector.checkMilestones();
      if (milestones.isNotEmpty) {
        await _celebrationService.celebrate(milestones);
      }
    } catch (error) {
      _logger.e('Milestone detection failed: $error');
    }

    // Phase 8: Warm-to-cold migration
    try {
      await _coldMigrationService.migrateWarmToCold();
    } catch (error) {
      _logger.e('Cold migration failed: $error');
    }

    // Phase 8: Weekly review (Sunday evening only)
    try {
      if (await _weeklyReviewEngine.shouldSendReview()) {
        await _weeklyReviewEngine.generateReview();
      }
    } catch (error) {
      _logger.e('Weekly review check failed: $error');
    }

    // Phase 10: CI monitoring check (rate-limited internally to 15min)
    try {
      await _ciMonitorService.checkAllProjects();
    } catch (error) {
      _logger.e('CI monitoring check failed: $error');
    }

    // Phase 12: Profile pack update check (rate-limited to daily/weekly)
    try {
      final now = DateTime.now();
      if (_lastProfileUpdateCheck == null ||
          now.difference(_lastProfileUpdateCheck!).inHours >= 1) {
        await _checkProfileUpdates();
        _lastProfileUpdateCheck = now;
      }
    } catch (error) {
      _logger.e('Profile update check failed: $error');
    }
  }

  /// Check for profile pack updates.
  /// Reads frequency preference from settings, fetches manifest if due,
  /// compares versions, and stores update-available flag.
  /// Uses direct File I/O for version markers (no Pigeon — runs in background isolate).
  Future<void> _checkProfileUpdates() async {
    final settingsDao = _backgroundDb.settingsDao;

    // Check frequency preference
    final frequency = await settingsDao.getString(SettingsKeys.profileUpdateCheckFrequency) ?? 'daily';
    if (frequency == 'never') {
      _logger.d('Profile update check disabled by user');
      return;
    }

    // Check if enough time has passed since last check
    final lastCheckStr = await settingsDao.getString(SettingsKeys.profileUpdateLastCheck);
    if (lastCheckStr != null) {
      final lastCheck = DateTime.tryParse(lastCheckStr);
      if (lastCheck != null) {
        final hoursSinceCheck = DateTime.now().difference(lastCheck).inHours;
        final requiredHours = frequency == 'weekly' ? 168 : 24; // 7 days or 1 day
        if (hoursSinceCheck < requiredHours) {
          _logger.d('Profile update check not due yet ($hoursSinceCheck hrs < $requiredHours hrs)');
          return;
        }
      }
    }

    _logger.i('Running profile update check...');

    try {
      final packService = ProfilePackService();
      final manifest = await packService.fetchManifest();
      await packService.cacheManifest(manifest);

      // Check each installed profile for updates
      bool foundUpdate = false;
      for (final profile in manifest.profiles) {
        if (!profile.isAvailable) continue;

        final localVersion = ProfilePackService.readInstalledVersionFromFile(profile.id);
        if (localVersion == null) continue; // Not installed

        if (ProfileEntry.isNewer(profile.version, localVersion)) {
          _logger.i('Update available for ${profile.id}: $localVersion -> ${profile.version}');
          await settingsDao.setBool(SettingsKeys.profileUpdateAvailable, true);
          await settingsDao.setString(SettingsKeys.profileUpdateRemoteVersion, profile.version);
          await settingsDao.setString(SettingsKeys.profileUpdateProfileId, profile.id);
          foundUpdate = true;

          // Notify main isolate
          FlutterForegroundTask.sendDataToMain({
            'type': 'profile_update_available',
            'profileId': profile.id,
            'currentVersion': localVersion,
            'remoteVersion': profile.version,
          });
          break; // Only report first update found
        }
      }

      if (!foundUpdate) {
        await settingsDao.setBool(SettingsKeys.profileUpdateAvailable, false);
      }

      // Update last check timestamp
      await settingsDao.setString(
        SettingsKeys.profileUpdateLastCheck,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      _logger.e('Profile update check failed: $e');
      // Don't update lastCheck on failure — retry next cycle
    }
  }

  @override
  void onReceiveData(Object data) {
    _logger.d('Received data from main isolate: $data');

    if (data is Map<String, dynamic>) {
      final command = data['command'] as String?;
      switch (command) {
        case 'generateBriefing':
          _logger.i('Briefing generation requested');
          _handleGenerateBriefing();
          break;
        case 'checkStuckness':
          _logger.i('Stuckness check requested');
          _handleCheckStuckness();
          break;
        case 'check_interventions':
          _logger.i('Intervention check requested');
          _runInterventionCheck();
          break;
        case 'conversationComplete':
          final conversationId = data['conversationId'] as String?;
          if (conversationId != null) {
            _handleConversationComplete(conversationId);
          }
          break;
        case 'messageAdded':
          final conversationId = data['conversationId'] as String?;
          if (conversationId != null) {
            _distillationService.incrementCounter(conversationId);
          }
          break;
        default:
          _logger.w('Unknown command: $command');
      }
    }
  }

  Future<void> _handleConversationComplete(String conversationId) async {
    try {
      // Record streak activity
      await _streakService.recordActivity();

      // Collect metrics
      await _metricsCollector.onConversationComplete(conversationId);

      // Check if distillation is needed
      if (_distillationService.shouldDistill(conversationId)) {
        await _distillationService.distill(conversationId);
      }

      // Extract project state (MEMD-03)
      await _projectStateExtractor.onConversationComplete(conversationId);

      // Check milestones after metrics update
      final milestones = await _milestoneDetector.checkMilestones();
      if (milestones.isNotEmpty) {
        await _celebrationService.celebrate(milestones);
        // Notify main isolate about celebrations
        FlutterForegroundTask.sendDataToMain({
          'type': 'milestone_detected',
          'milestones': milestones.map((m) => {
            'type': m.milestoneType,
            'tier': m.celebrationTier,
            'context': m.contextSummary,
          }).toList(),
        });
      }

      _logger.i('Conversation complete hooks executed for $conversationId');
    } catch (error) {
      _logger.e('Conversation complete hooks failed: $error');
    }
  }

  Future<void> _handleGenerateBriefing() async {
    try {
      await _briefingEngine.generateBriefing();
    } catch (error) {
      _logger.e('Briefing generation failed: $error');
    }
  }

  Future<void> _handleCheckStuckness() async {
    try {
      await _stucknessDetector.detectStuckness();
      await _stucknessDetector.generateNudge();
      _lastStucknessCheck = DateTime.now();
    } catch (error) {
      _logger.e('Stuckness check failed: $error');
    }
  }

  Future<void> _runInterventionCheck() async {
    try {
      final actions = await _interventionEngine.checkAllTriggers();
      for (final action in actions) {
        await _dispatchInterventionAction(action);
      }
    } catch (error) {
      _logger.e('Ad-hoc intervention check failed: $error');
    }
  }

  Future<void> _dispatchInterventionAction(InterventionAction action) async {
    switch (action.type) {
      case InterventionActionType.nudge:
        // Send data to main isolate for chat nudge card
        FlutterForegroundTask.sendDataToMain({
          'type': 'intervention_nudge',
          'interventionId': action.intervention.id,
          'description': action.intervention.triggerDescription,
          'level': action.intervention.level.name,
        });
        break;
      case InterventionActionType.notification:
        await _notificationService.showInterventionNotification(
          title: 'SOUL \u2014 We moeten praten',
          body: action.message ?? action.intervention.triggerDescription,
          notificationId: action.intervention.id.hashCode,
        );
        break;
      case InterventionActionType.proposal:
        final deadlineText = action.intervention.proposalDeadlineAt != null
            ? _formatDeadline(action.intervention.proposalDeadlineAt!)
            : '1 uur';
        final proposedDefault =
            action.intervention.proposedDefault ?? 'het voorstel';
        await _notificationService.showDecisionProposalNotification(
          title: 'SOUL \u2014 Beslissing nodig',
          body: '${action.intervention.triggerDescription}\n'
              'Ik kies $proposedDefault tenzij je voor $deadlineText reageert',
          notificationId: action.intervention.id.hashCode,
          interventionId: action.intervention.id,
        );
        break;
      case InterventionActionType.autoResolved:
        await _notificationService.showInterventionNotification(
          title: 'SOUL \u2014 Beslissing genomen',
          body:
              'Deadline verstreken. Gekozen: ${action.intervention.proposedDefault ?? "voorstel"}',
          notificationId: action.intervention.id.hashCode,
        );
        break;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final remaining = deadline.difference(now);
    if (remaining.inMinutes <= 0) return 'nu';
    if (remaining.inMinutes < 60) return '${remaining.inMinutes} minuten';
    return '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _logger.i('SoulBackgroundHandler destroyed at $timestamp');
    await _backgroundDb.close();
  }

  @override
  void onNotificationButtonPressed(String id) {
    _logger.i('Notification button pressed: $id');

    if (id == 'stop_autonomous') {
      // Send kill command to main isolate (VesselManager runs there)
      FlutterForegroundTask.sendDataToMain({
        'type': 'kill_autonomous_session',
        'reason': 'notification_stop_button',
      });
      return;
    }

    if (id.startsWith('accept_decision_')) {
      final interventionId = id.replaceFirst('accept_decision_', '');
      FlutterForegroundTask.sendDataToMain({
        'type': 'accept_decision',
        'interventionId': interventionId,
      });
      return;
    }

    if (id.startsWith('reject_decision_')) {
      final interventionId = id.replaceFirst('reject_decision_', '');
      FlutterForegroundTask.sendDataToMain({
        'type': 'reject_decision',
        'interventionId': interventionId,
      });
      return;
    }
  }

  @override
  void onNotificationPressed() {
    _logger.i('Foreground notification pressed');
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {
    _logger.i('Foreground notification dismissed');
  }
}
