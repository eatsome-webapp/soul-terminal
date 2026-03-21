import 'dart:math';
import '../../core/utils/logger.dart';
import '../database/daos/metrics_dao.dart';
import '../database/daos/streak_dao.dart';

class MomentumCalculator {
  final MetricsDao _metricsDao;
  final StreakDao _streakDao;

  // Weights: session frequency 30%, decision velocity 25%, commit frequency 20%, streak 15%, task completion 10%
  static const double weightSessionFrequency = 0.30;
  static const double weightDecisionVelocity = 0.25;
  static const double weightCommitFrequency = 0.20;
  static const double weightStreakLength = 0.15;
  static const double weightTaskCompletion = 0.10;

  MomentumCalculator({
    required MetricsDao metricsDao,
    required StreakDao streakDao,
  })  : _metricsDao = metricsDao,
        _streakDao = streakDao;

  Future<double> calculate() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final startDate = _dateString(weekAgo);
      final endDate = _dateString(now);

      final weekMetrics =
          await _metricsDao.getMetricsForDateRange(startDate, endDate);

      // Aggregate weekly totals by metric_type
      final totals = <String, double>{};
      for (final m in weekMetrics) {
        totals[m.metricType] = (totals[m.metricType] ?? 0) + m.value;
      }

      // Normalize each component to 0-1 range with reasonable caps
      final sessionScore =
          _normalize(totals['session_count'] ?? 0, 35); // 5/day = 35/week
      final decisionScore =
          _normalize(totals['decision_count'] ?? 0, 20); // ~3/day
      final commitScore =
          _normalize(totals['commit_count'] ?? 0, 30); // ~4/day
      final messageScore = _normalize(
          totals['message_count'] ?? 0, 500); // proxy for task completion

      // Streak component
      final streak = await _streakDao.getStreak('daily');
      final streakScore =
          _normalize((streak?.currentCount ?? 0).toDouble(), 30);

      final momentum = sessionScore * weightSessionFrequency +
          decisionScore * weightDecisionVelocity +
          commitScore * weightCommitFrequency +
          streakScore * weightStreakLength +
          messageScore * weightTaskCompletion;

      // Clamp to 0-100
      final score = (momentum * 100).clamp(0, 100).roundToDouble();

      log.d('Momentum score: $score (sessions=$sessionScore, '
          'decisions=$decisionScore, commits=$commitScore, '
          'streak=$streakScore, messages=$messageScore)');

      return score;
    } catch (e) {
      log.e('Momentum calculation failed: $e');
      return 0;
    }
  }

  double _normalize(double value, double maxExpected) {
    return min(value / maxExpected, 1.0);
  }

  Future<String> getMomentumSummary() async {
    final score = await calculate();
    final label = score >= 75
        ? 'High'
        : score >= 40
            ? 'Medium'
            : 'Low';
    return 'Momentum: $label (${score.toInt()}/100)';
  }

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
