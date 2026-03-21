import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../models/intervention.dart';
import '../database/daos/calendar_dao.dart';
import '../database/daos/intervention_dao.dart';
import '../database/daos/project_dao.dart';
import '../platform/local_notification_service.dart';
import 'intervention_config.dart';
import 'stuckness_detector.dart';

/// Core intervention engine with deterministic 3-level escalation.
///
/// State machine: INACTIVE -> DETECTED -> LEVEL_1 -> LEVEL_2 -> LEVEL_3 -> RESOLVED
///
/// - Level 1 (nudge): in-chat card via sendDataToMain
/// - Level 2 (notification): push notification via intervention channel
/// - Level 3 (proposal): decision proposal with accept/reject buttons
///
/// Called every 15 minutes from SoulBackgroundHandler.onRepeatEvent().
class InterventionEngine {
  final InterventionDao _interventionDao;
  final StucknessDetector _stucknessDetector;
  final LocalNotificationService _notificationService;
  final InterventionConfig _config;
  final CalendarDao _calendarDao;
  final ProjectDao _projectDao;
  final Logger _logger = Logger();

  InterventionEngine({
    required InterventionDao interventionDao,
    required StucknessDetector stucknessDetector,
    required LocalNotificationService notificationService,
    required InterventionConfig config,
    required CalendarDao calendarDao,
    required ProjectDao projectDao,
  })  : _interventionDao = interventionDao,
        _stucknessDetector = stucknessDetector,
        _notificationService = notificationService,
        _config = config,
        _calendarDao = calendarDao,
        _projectDao = projectDao;

  /// Run all trigger checks. Called from background handler every 15 minutes.
  Future<List<InterventionAction>> checkAllTriggers() async {
    final actions = <InterventionAction>[];
    actions.addAll(await _autoResolveProposals());
    actions.addAll(await _checkStuckness());
    actions.addAll(await _checkInactivity());
    actions.addAll(await _checkDecisionDelays());
    actions.addAll(await _checkDeadlineProximity());
    actions.addAll(await _checkProjectDeadlines());
    actions.addAll(await _escalateActiveInterventions());
    return actions;
  }

  Future<List<InterventionAction>> _checkStuckness() async {
    final results = await _stucknessDetector.detectStuckness();
    final actions = <InterventionAction>[];
    for (final result in results) {
      if (result.score < _config.stucknessThreshold) continue;

      final existing = await _interventionDao.getActiveInterventions();
      final alreadyTracked = existing.any(
        (i) =>
            i.type == InterventionType.stuckness &&
            i.relatedEntityId == result.topic,
      );
      if (alreadyTracked) continue;

      final state = InterventionState(
        id: const Uuid().v4(),
        type: InterventionType.stuckness,
        level: InterventionLevel.detected,
        triggerDescription:
            'Stuck op onderwerp: ${result.topic} (score: ${result.score.toStringAsFixed(2)})',
        detectedAt: DateTime.now(),
        relatedEntityId: result.topic,
      );
      await _interventionDao.upsertIntervention(state);
      actions.add(InterventionAction.nudge(state));
    }
    return actions;
  }

  Future<List<InterventionAction>> _checkInactivity() async {
    final isInactive = await _stucknessDetector
        .detectInactivity(_config.inactivityThresholdHours);
    if (!isInactive) return [];

    final existing = await _interventionDao.getActiveInterventions();
    final alreadyTracked =
        existing.any((i) => i.type == InterventionType.inactivity);
    if (alreadyTracked) return [];

    final state = InterventionState(
      id: const Uuid().v4(),
      type: InterventionType.inactivity,
      level: InterventionLevel.detected,
      triggerDescription:
          'Geen interactie sinds meer dan ${_config.inactivityThresholdHours} uur',
      detectedAt: DateTime.now(),
    );
    await _interventionDao.upsertIntervention(state);
    return [
      InterventionAction.notification(
        state,
        'Je bent al ${_config.inactivityThresholdHours}+ uur stil. Wat houdt je tegen?',
      ),
    ];
  }

  Future<List<InterventionAction>> _checkDecisionDelays() async {
    final active = await _interventionDao.getActiveInterventions();
    final decisionDelays =
        active.where((i) => i.type == InterventionType.decisionDelay).toList();
    final actions = <InterventionAction>[];
    final now = DateTime.now();

    for (final delay in decisionDelays) {
      final elapsed = now.difference(delay.detectedAt);

      if (delay.level == InterventionLevel.detected &&
          elapsed.inHours >= _config.decisionNudgeHours) {
        final updated = delay.copyWith(
          level: InterventionLevel.level1Sent,
          level1SentAt: now,
        );
        await _interventionDao.upsertIntervention(updated);
        actions.add(InterventionAction.nudge(updated));
      } else if (delay.level == InterventionLevel.level1Sent &&
          elapsed.inHours >= _config.decisionConfrontHours) {
        final updated = delay.copyWith(
          level: InterventionLevel.level2Sent,
          level2SentAt: now,
        );
        await _interventionDao.upsertIntervention(updated);
        actions.add(InterventionAction.notification(
          updated,
          'Open beslissing: ${delay.triggerDescription}',
        ));
      } else if (delay.level == InterventionLevel.level2Sent &&
          elapsed.inHours >= _config.decisionProposeHours) {
        final updated = delay.copyWith(
          level: InterventionLevel.level3Sent,
          level3SentAt: now,
        );
        await _interventionDao.upsertIntervention(updated);
        actions.add(InterventionAction.proposal(updated));
      }
    }
    return actions;
  }

  /// Check calendar events for approaching deadlines.
  Future<List<InterventionAction>> _checkDeadlineProximity() async {
    final now = DateTime.now();
    final actions = <InterventionAction>[];

    for (final warningDays in _config.deadlineWarningDays) {
      final targetDate = now.add(Duration(days: warningDays));
      final events = await _calendarDao.getEventsForDate(targetDate);

      for (final event in events) {
        final title = event.title.toLowerCase();
        if (!title.contains('deadline') &&
            !title.contains('launch') &&
            !title.contains('release') &&
            !title.contains('demo') &&
            !title.contains('presentation') &&
            !title.contains('deliverable')) {
          continue;
        }

        final existing = await _interventionDao.getActiveInterventions();
        final alreadyTracked = existing.any(
          (i) =>
              i.type == InterventionType.deadlineProximity &&
              i.relatedEntityId == '${event.eventId}_$warningDays',
        );
        if (alreadyTracked) continue;

        final state = InterventionState(
          id: const Uuid().v4(),
          type: InterventionType.deadlineProximity,
          level: InterventionLevel.detected,
          triggerDescription:
              'Deadline over $warningDays dagen: ${event.title}',
          detectedAt: now,
          relatedEntityId: '${event.eventId}_$warningDays',
        );
        await _interventionDao.upsertIntervention(state);

        if (warningDays <= 1) {
          actions.add(InterventionAction.notification(
            state,
            'MORGEN: ${event.title}. Wat moet nog?',
          ));
        } else if (warningDays <= 3) {
          actions.add(InterventionAction.notification(
            state,
            'Over $warningDays dagen: ${event.title}. Liggen we op schema?',
          ));
        } else {
          actions.add(InterventionAction.nudge(state));
        }
      }
    }
    return actions;
  }

  /// Check project deadlines and trigger notifications at 7/3/1 day thresholds.
  Future<List<InterventionAction>> _checkProjectDeadlines() async {
    final projects = await _projectDao.getProjectsWithDeadlines();
    final now = DateTime.now();
    final actions = <InterventionAction>[];

    for (final project in projects) {
      if (project.deadline == null) continue;
      final deadline = DateTime.fromMillisecondsSinceEpoch(project.deadline!);
      final daysRemaining = deadline.difference(now).inDays;

      if (daysRemaining > 7) continue;

      // Check if already tracked for this threshold
      final thresholdKey = daysRemaining <= 1
          ? '1'
          : daysRemaining <= 3
              ? '3'
              : '7';
      final existing = await _interventionDao.getActiveInterventions();
      final alreadyTracked = existing.any(
        (i) =>
            i.type == InterventionType.deadlineProximity &&
            i.relatedEntityId == 'project_${project.id}_$thresholdKey',
      );
      if (alreadyTracked) continue;

      final state = InterventionState(
        id: const Uuid().v4(),
        type: InterventionType.deadlineProximity,
        level: InterventionLevel.detected,
        triggerDescription:
            'Project deadline over $daysRemaining dagen: ${project.name}',
        detectedAt: now,
        relatedEntityId: 'project_${project.id}_$thresholdKey',
      );
      await _interventionDao.upsertIntervention(state);

      if (daysRemaining <= 1) {
        // Level 3: Intervention-level confrontation
        await _notificationService.showAlertNotification(
          title: 'DEADLINE MORGEN: ${project.name}',
          body: 'Je deadline voor ${project.name} is morgen. Focus nu.',
        );
        actions.add(InterventionAction.notification(
          state,
          'DEADLINE MORGEN: ${project.name}',
        ));
      } else if (daysRemaining <= 3) {
        // Level 2: Push notification
        await _notificationService.showNudgeNotification(
          title: 'Deadline nadert: ${project.name}',
          body: '${project.name} deadline over $daysRemaining dagen.',
        );
        actions.add(InterventionAction.notification(
          state,
          'Deadline nadert: ${project.name} over $daysRemaining dagen.',
        ));
      } else {
        // Level 1: Log only (included in briefing context)
        _logger.i(
            'Deadline approaching for ${project.name}: $daysRemaining days');
        actions.add(InterventionAction.nudge(state));
      }
    }
    return actions;
  }

  /// Escalate existing active interventions based on elapsed time.
  Future<List<InterventionAction>> _escalateActiveInterventions() async {
    final active = await _interventionDao.getActiveInterventions();
    final actions = <InterventionAction>[];
    final now = DateTime.now();

    for (final intervention in active) {
      switch (intervention.level) {
        case InterventionLevel.detected:
          // Auto-escalate to Level 1 (nudge)
          final updated = intervention.copyWith(
            level: InterventionLevel.level1Sent,
            level1SentAt: now,
          );
          await _interventionDao.upsertIntervention(updated);
          actions.add(InterventionAction.nudge(updated));
          break;

        case InterventionLevel.level1Sent:
          final elapsed = now.difference(intervention.level1SentAt!);
          if (elapsed.inHours >= _config.decisionConfrontHours) {
            final updated = intervention.copyWith(
              level: InterventionLevel.level2Sent,
              level2SentAt: now,
            );
            await _interventionDao.upsertIntervention(updated);
            actions.add(InterventionAction.notification(
              updated,
              intervention.triggerDescription,
            ));
          }
          break;

        case InterventionLevel.level2Sent:
          final elapsed = now.difference(intervention.level2SentAt!);
          if (elapsed.inHours >= _config.decisionProposeHours) {
            final deadline = now.add(const Duration(hours: 1));
            final updated = intervention.copyWith(
              level: InterventionLevel.level3Sent,
              level3SentAt: now,
              proposalDeadlineAt: deadline,
            );
            await _interventionDao.upsertIntervention(updated);
            actions.add(InterventionAction.proposal(updated));
          }
          break;

        case InterventionLevel.level3Sent:
          // Auto-resolve handled by _autoResolveProposals
          break;

        default:
          break;
      }
    }
    return actions;
  }

  /// Auto-resolve proposals that have passed their deadline.
  /// Called as part of checkAllTriggers().
  Future<List<InterventionAction>> _autoResolveProposals() async {
    final active = await _interventionDao.getActiveInterventions();
    final now = DateTime.now();
    final actions = <InterventionAction>[];
    for (final intervention in active) {
      if (intervention.level == InterventionLevel.level3Sent &&
          intervention.proposalDeadlineAt != null &&
          now.isAfter(intervention.proposalDeadlineAt!)) {
        final updated = intervention.copyWith(
          level: InterventionLevel.resolved,
          resolvedAt: now,
        );
        await _interventionDao.upsertIntervention(updated);
        _logger.i(
          'Auto-resolved proposal ${intervention.id}: '
          'chose "${intervention.proposedDefault}"',
        );
        actions.add(InterventionAction.autoResolved(updated));
      }
    }
    return actions;
  }

  /// Resolve an intervention (user addressed the issue).
  Future<void> resolve(String interventionId) async {
    await _interventionDao.resolveIntervention(
      interventionId,
      DateTime.now(),
    );
  }
}

/// Action to take as result of intervention check.
enum InterventionActionType { nudge, notification, proposal, autoResolved }

class InterventionAction {
  final InterventionActionType type;
  final InterventionState intervention;
  final String? message;

  const InterventionAction._(this.type, this.intervention, this.message);

  factory InterventionAction.nudge(InterventionState intervention) =>
      InterventionAction._(InterventionActionType.nudge, intervention, null);

  factory InterventionAction.notification(
    InterventionState intervention,
    String message,
  ) =>
      InterventionAction._(
        InterventionActionType.notification,
        intervention,
        message,
      );

  factory InterventionAction.proposal(InterventionState intervention) =>
      InterventionAction._(InterventionActionType.proposal, intervention, null);

  factory InterventionAction.autoResolved(InterventionState intervention) =>
      InterventionAction._(
        InterventionActionType.autoResolved,
        intervention,
        null,
      );
}
