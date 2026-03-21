import '../../core/utils/logger.dart';
import '../ai/claude_service.dart';
import '../database/daos/decision_dao.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/weekly_review_dao.dart';
import '../platform/local_notification_service.dart';
import 'metrics_collector.dart';
import 'momentum_calculator.dart';
import 'streak_service.dart';

class WeeklyReviewEngine {
  final ClaudeService _claudeService;
  final WeeklyReviewDao _weeklyReviewDao;
  final SettingsDao _settingsDao;
  final MetricsCollector _metricsCollector;
  final MomentumCalculator _momentumCalculator;
  final StreakService _streakService;
  final DecisionDao _decisionDao;
  final LocalNotificationService? _notificationService;

  WeeklyReviewEngine({
    required ClaudeService claudeService,
    required WeeklyReviewDao weeklyReviewDao,
    required SettingsDao settingsDao,
    required MetricsCollector metricsCollector,
    required MomentumCalculator momentumCalculator,
    required StreakService streakService,
    required DecisionDao decisionDao,
    LocalNotificationService? notificationService,
  })  : _claudeService = claudeService,
        _weeklyReviewDao = weeklyReviewDao,
        _settingsDao = settingsDao,
        _metricsCollector = metricsCollector,
        _momentumCalculator = momentumCalculator,
        _streakService = streakService,
        _decisionDao = decisionDao,
        _notificationService = notificationService;

  Future<bool> shouldSendReview() async {
    final now = DateTime.now();
    final reviewDay = await _settingsDao.getInt(SettingsKeys.weeklyReviewDay) ?? 7; // Sunday
    final reviewHour = await _settingsDao.getInt(SettingsKeys.weeklyReviewHour) ?? 19;

    if (now.weekday != reviewDay) return false;
    if (now.hour != reviewHour) return false;

    // Check if review already sent this week
    final weekStart = _weekStartString(now);
    final existing = await _weeklyReviewDao.getReviewForWeek(weekStart);
    return existing == null;
  }

  Future<String?> generateReview() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(const Duration(days: 7));
      final weekStartStr = _weekStartString(now);

      // Gather context
      final weekMetrics = await _metricsCollector.getMetricsForWeek(weekStart);
      final momentum = await _momentumCalculator.calculate();
      final streakData = await _streakService.getStreakData();
      final recentDecisions = await _decisionDao.getRecentDecisions(10);

      final metricsText = weekMetrics.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      final decisionsText = recentDecisions
          .map((d) => '- ${d.title}: ${d.reasoning}')
          .join('\n');

      final prompt = '''Generate a weekly review for a solo founder. Be direct, co-founder energy.
Language: Dutch. Max 200 words.

This week's metrics:
$metricsText

Momentum score: ${momentum.toInt()}/100
Streak: ${streakData['current']} dagen (langste: ${streakData['longest']})

Recent decisions:
$decisionsText

Return a JSON object with exactly these fields:
{
  "summary": "Full review text in Dutch, co-founder tone, max 200 words",
  "highlights": ["what went well 1", "what went well 2"],
  "blockers": ["where you got stuck"],
  "priorities": ["priority 1", "priority 2", "priority 3"]
}

Only return valid JSON, nothing else.
Schrijf alsof je de co-founder bent. Geen vage complimenten. Concreet.''';

      final result = await _claudeService.analyzeWithHaiku(prompt, maxTokens: 512);
      final reviewContent = result['summary'] as String? ?? 'Review kon niet worden gegenereerd.';

      await _weeklyReviewDao.insertReview(
        weekStart: weekStartStr,
        content: reviewContent,
        metricsSummary: metricsText,
        momentumScore: momentum,
      );

      await _notificationService?.showBriefingNotification(
        title: 'SOUL \u2014 Weekoverzicht',
        body: 'Je weekoverzicht is klaar. Open SOUL om het te lezen.',
      );

      log.i('Weekly review generated for week starting $weekStartStr');
      return reviewContent;
    } catch (e) {
      log.e('Weekly review generation failed: $e');
      return null;
    }
  }

  String _weekStartString(DateTime dt) {
    final monday = dt.subtract(Duration(days: dt.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }
}
