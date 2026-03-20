import '../../core/utils/logger.dart';
import '../database/daos/conversation_dao.dart';
import '../database/daos/decision_dao.dart';
import '../database/daos/api_usage_dao.dart';
import '../database/daos/metrics_dao.dart';
import '../database/daos/settings_dao.dart';

class MetricsCollector {
  final ConversationDao _conversationDao;
  final DecisionDao _decisionDao;
  final ApiUsageDao _apiUsageDao;
  final MetricsDao _metricsDao;
  final SettingsDao _settingsDao;

  MetricsCollector({
    required ConversationDao conversationDao,
    required DecisionDao decisionDao,
    required ApiUsageDao apiUsageDao,
    required MetricsDao metricsDao,
    required SettingsDao settingsDao,
  })  : _conversationDao = conversationDao,
        _decisionDao = decisionDao,
        _apiUsageDao = apiUsageDao,
        _metricsDao = metricsDao,
        _settingsDao = settingsDao;

  Future<void> onConversationComplete(String conversationId) async {
    try {
      final today = _dateString(DateTime.now());

      // Increment session count
      final currentSessions = await _metricsDao.getMetricsForDate(today);
      final existingCount = currentSessions
              .where((m) => m.metricType == 'session_count')
              .firstOrNull
              ?.value ??
          0;
      await _metricsDao.upsertMetric(
        date: today,
        metricType: 'session_count',
        value: existingCount + 1,
      );

      // Update decision count for today
      final decisions = await _decisionDao.getRecentDecisions(100);
      final todayDecisions = decisions
          .where((d) =>
              _dateString(
                  DateTime.fromMillisecondsSinceEpoch(d.createdAt)) ==
              today)
          .length;
      await _metricsDao.upsertMetric(
        date: today,
        metricType: 'decision_count',
        value: todayDecisions.toDouble(),
      );

      // Update message count for today
      final messageCount =
          await _conversationDao.getMessageCount(conversationId);
      final existingMessages = currentSessions
              .where((m) => m.metricType == 'message_count')
              .firstOrNull
              ?.value ??
          0;
      await _metricsDao.upsertMetric(
        date: today,
        metricType: 'message_count',
        value: existingMessages + messageCount,
      );

      log.i(
          'Metrics updated for $today: session +1, $todayDecisions decisions, $messageCount messages');
    } catch (e) {
      log.e('Metrics collection failed: $e');
    }
  }

  Future<void> runDailyAggregation() async {
    try {
      final yesterday =
          _dateString(DateTime.now().subtract(const Duration(days: 1)));
      final lastAggregation = await _settingsDao
          .getString(SettingsKeys.lastMetricsAggregationDate);

      if (lastAggregation == yesterday) {
        log.d('Daily aggregation already done for $yesterday');
        return;
      }

      // API cost for yesterday
      final yesterdayStart =
          DateTime.now().subtract(const Duration(days: 1));
      final dayStart = DateTime(
          yesterdayStart.year, yesterdayStart.month, yesterdayStart.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final cost = await _apiUsageDao.getCostForDateRange(
        dayStart.millisecondsSinceEpoch,
        dayEnd.millisecondsSinceEpoch,
      );
      if (cost != null && cost > 0) {
        await _metricsDao.upsertMetric(
          date: yesterday,
          metricType: 'api_cost',
          value: cost,
        );
      }

      await _settingsDao.setString(
          SettingsKeys.lastMetricsAggregationDate, yesterday);
      log.i('Daily metrics aggregation complete for $yesterday');
    } catch (e) {
      log.e('Daily aggregation failed: $e');
    }
  }

  Future<Map<String, double>> getMetricsForDate(String date) async {
    final metrics = await _metricsDao.getMetricsForDate(date);
    return {for (final m in metrics) m.metricType: m.value};
  }

  Future<Map<String, double>> getMetricsForWeek(DateTime weekStart) async {
    final start = _dateString(weekStart);
    final end = _dateString(weekStart.add(const Duration(days: 7)));
    final metrics = await _metricsDao.getMetricsForDateRange(start, end);
    final result = <String, double>{};
    for (final m in metrics) {
      result[m.metricType] = (result[m.metricType] ?? 0) + m.value;
    }
    return result;
  }

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
