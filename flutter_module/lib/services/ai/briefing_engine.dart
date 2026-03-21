import 'package:logger/logger.dart';
import '../database/daos/briefing_dao.dart';
import '../database/daos/calendar_dao.dart';
import '../database/daos/decision_dao.dart';
import '../database/daos/notification_dao.dart';
import '../database/daos/project_dao.dart';
import '../database/daos/project_state_dao.dart';
import '../database/daos/settings_dao.dart';
import '../platform/local_notification_service.dart';
import '../vessels/openclaw/openclaw_ci_monitor.dart';
import 'claude_service.dart';

/// Generates morning briefings by gathering context from calendar, decisions,
/// and notifications, then calling Claude Sonnet for synthesis.
class BriefingEngine {
  final ClaudeService _claudeService;
  final BriefingDao _briefingDao;
  final CalendarDao _calendarDao;
  final DecisionDao _decisionDao;
  final NotificationDao _notificationDao;
  final LocalNotificationService _notificationService;
  final SettingsDao _settingsDao;
  final ProjectDao _projectDao;
  final ProjectStateDao _projectStateDao;
  final OpenClawCiMonitor? _ciMonitorService;
  final Logger _logger = Logger();

  BriefingEngine({
    required ClaudeService claudeService,
    required BriefingDao briefingDao,
    required CalendarDao calendarDao,
    required DecisionDao decisionDao,
    required NotificationDao notificationDao,
    required LocalNotificationService notificationService,
    required SettingsDao settingsDao,
    required ProjectDao projectDao,
    required ProjectStateDao projectStateDao,
    OpenClawCiMonitor? ciMonitorService,
  })  : _claudeService = claudeService,
        _briefingDao = briefingDao,
        _calendarDao = calendarDao,
        _decisionDao = decisionDao,
        _notificationDao = notificationDao,
        _notificationService = notificationService,
        _settingsDao = settingsDao,
        _projectDao = projectDao,
        _projectStateDao = projectStateDao,
        _ciMonitorService = ciMonitorService;

  /// Get configured briefing hour (default: 7).
  Future<int> _getBriefingHour() async {
    return await _settingsDao.getInt(SettingsKeys.briefingHour) ?? 7;
  }

  /// Get configured briefing minute (default: 30).
  Future<int> _getBriefingMinute() async {
    return await _settingsDao.getInt(SettingsKeys.briefingMinute) ?? 30;
  }

  /// Set briefing time (called from Settings UI).
  Future<void> setBriefingTime(int hour, int minute) async {
    await _settingsDao.setInt(SettingsKeys.briefingHour, hour);
    await _settingsDao.setInt(SettingsKeys.briefingMinute, minute);
    _logger.i('Briefing time set to $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// Check if a briefing should be sent now.
  /// Returns true if current time is within the briefing window and no briefing sent today.
  Future<bool> shouldSendBriefing() async {
    final now = DateTime.now();
    final hour = await _getBriefingHour();
    final minute = await _getBriefingMinute();

    if (now.hour != hour || now.minute < minute || now.minute > minute + 14) {
      return false;
    }

    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final existing = await _briefingDao.getBriefingForDate(todayStr);
    return existing == null;
  }

  /// Gather multi-project context for aggregated briefing.
  /// Returns empty string if fewer than 2 active projects.
  Future<String> _gatherMultiProjectContext() async {
    final projects = await _projectDao.getActiveProjects();
    if (projects.length < 2) return '';

    final now = DateTime.now();
    final projectEntries = <_ProjectPriority>[];

    for (final project in projects) {
      final state = await _projectStateDao.getLatestState(project.id);

      // Calculate deadline proximity
      final deadlineMs = project.deadline;
      final int? daysRemaining;
      if (deadlineMs != null) {
        final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
        daysRemaining = deadline.difference(now).inDays;
      } else {
        daysRemaining = null;
      }

      // Calculate priority score: deadline proximity x inverse activity
      final deadlineProximityScore = daysRemaining != null
          ? 1.0 / (daysRemaining + 1).clamp(1, 1000)
          : 0.1;

      // Approximate activity from state lastUpdated
      final lastUpdated = state?.updatedAt;
      final daysSinceUpdate = lastUpdated != null
          ? now
              .difference(DateTime.fromMillisecondsSinceEpoch(lastUpdated))
              .inDays
          : 30;
      final inverseActivityScore = 1.0 / (daysSinceUpdate + 1).clamp(1, 365);

      final priorityScore = deadlineProximityScore * inverseActivityScore;

      // Get CI status if available
      List<CiFailure> ciFailures = [];
      if (_ciMonitorService != null && project.repoUrl != null) {
        try {
          ciFailures =
              await _ciMonitorService.checkNow(repo: project.repoUrl!);
        } catch (_) {
          // CI check is best-effort
        }
      }

      projectEntries.add(_ProjectPriority(
        name: project.name,
        status: state?.currentStatus ?? 'unknown',
        daysRemaining: daysRemaining,
        ciHealthy: ciFailures.isEmpty,
        ciFailureCount: ciFailures.length,
        priorityScore: priorityScore,
      ));
    }

    // Sort by priority score descending
    projectEntries.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    // Build context string
    final buffer = StringBuffer('## Project Portfolio Status\n\n');
    for (var rank = 0; rank < projectEntries.length; rank++) {
      final entry = projectEntries[rank];
      buffer.writeln('### #${rank + 1}: ${entry.name}');
      buffer.writeln('- Status: ${entry.status}');
      buffer.writeln(
          '- CI: ${entry.ciHealthy ? "healthy" : "${entry.ciFailureCount} failures"}');
      if (entry.daysRemaining != null) {
        buffer.writeln('- Deadline: ${entry.daysRemaining} days remaining');
      } else {
        buffer.writeln('- Deadline: none set');
      }
      buffer.writeln();
    }

    // Cross-project insights
    final nearestDeadline = projectEntries
        .where((e) => e.daysRemaining != null)
        .toList()
      ..sort((a, b) => a.daysRemaining!.compareTo(b.daysRemaining!));

    if (nearestDeadline.isNotEmpty) {
      final urgent = nearestDeadline.first;
      if (urgent.daysRemaining! <= 7) {
        buffer.writeln(
            '### Cross-Project Insight\nConsider switching focus to ${urgent.name} '
            '(deadline in ${urgent.daysRemaining} days).');
      }
    }

    return buffer.toString();
  }

  /// Generate a morning briefing.
  /// Gathers context, calls Claude Sonnet, stores result, shows notification.
  Future<String?> generateBriefing() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Gather context
    final todayEvents = await _calendarDao.getEventsForDate(now);
    final recentDecisions = await _decisionDao.getRecentDecisions(5);
    final relevantNotifications = await _notificationDao.getUnsurfacedRelevant();
    final multiProjectContext = await _gatherMultiProjectContext();

    // Build context for Claude
    final contextParts = <String>[];

    if (multiProjectContext.isNotEmpty) {
      contextParts.add(multiProjectContext);
    }

    if (todayEvents.isNotEmpty) {
      contextParts.add('Today\'s calendar events:\n${todayEvents.map((e) => '- ${e.title} at ${DateTime.fromMillisecondsSinceEpoch(e.startTime).hour}:${DateTime.fromMillisecondsSinceEpoch(e.startTime).minute.toString().padLeft(2, '0')}').join('\n')}');
    }

    if (recentDecisions.isNotEmpty) {
      contextParts.add('Recent decisions:\n${recentDecisions.map((d) => '- ${d.title}').join('\n')}');
    }

    if (relevantNotifications.isNotEmpty) {
      contextParts.add('Relevant notifications:\n${relevantNotifications.map((n) => '- [${n.packageName}] ${n.title}: ${n.content}').join('\n')}');
    }

    if (contextParts.isEmpty) {
      contextParts.add('Your calendar is clear today. No open items.');
    }

    final contextBlock = contextParts.join('\n\n');

    // Generate briefing via Claude Sonnet
    final prompt = multiProjectContext.isNotEmpty
        ? 'Generate a concise morning briefing for a solo founder managing multiple projects based on this context:\n\n$contextBlock\n\nGenerate a priority-ranked daily briefing covering all active projects. Include cross-project recommendations if relevant. Format: Start with "Good morning! Here\'s your briefing for today." then list priorities by project, schedule, and any alerts. Keep it under 300 words. Be direct and actionable.'
        : 'Generate a concise morning briefing for a solo founder based on this context:\n\n$contextBlock\n\nFormat: Start with "Good morning! Here\'s your briefing for today." then list priorities, schedule, and any alerts. Keep it under 200 words. Be direct and actionable.';

    try {
      final briefingContent = await _claudeService.sendSingleMessage(
        prompt,
        useOpus: false, // Sonnet for speed and cost
      );

      // Store briefing
      await _briefingDao.insertBriefing(
        date: todayStr,
        content: briefingContent,
        calendarSummary: todayEvents.isNotEmpty ? '${todayEvents.length} events today' : null,
      );

      // Mark notifications as surfaced
      for (final notification in relevantNotifications) {
        await _notificationDao.markAsSurfaced(notification.id);
      }

      // Show push notification
      final shortSummary = briefingContent.length > 200
          ? '${briefingContent.substring(0, 197)}...'
          : briefingContent;

      await _notificationService.showBriefingNotification(
        title: 'Good morning! Your daily briefing',
        body: shortSummary,
        payload: 'briefing:$todayStr',
      );

      _logger.i('Morning briefing generated and delivered for $todayStr');
      return briefingContent;
    } catch (error) {
      _logger.e('Failed to generate briefing: $error');
      return null;
    }
  }
}

/// Internal helper for project priority ranking in briefings.
class _ProjectPriority {
  final String name;
  final String status;
  final int? daysRemaining;
  final bool ciHealthy;
  final int ciFailureCount;
  final double priorityScore;

  const _ProjectPriority({
    required this.name,
    required this.status,
    required this.daysRemaining,
    required this.ciHealthy,
    required this.ciFailureCount,
    required this.priorityScore,
  });
}
