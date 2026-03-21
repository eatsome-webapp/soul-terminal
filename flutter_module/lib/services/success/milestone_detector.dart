import '../../core/utils/logger.dart';
import '../database/daos/achievement_dao.dart';
import '../database/daos/metrics_dao.dart';
import '../database/daos/streak_dao.dart';

class MilestoneRule {
  final String milestoneType;
  final String metricType;
  final double threshold;
  final String celebrationTier;
  final String contextTemplate;

  const MilestoneRule({
    required this.milestoneType,
    required this.metricType,
    required this.threshold,
    required this.celebrationTier,
    required this.contextTemplate,
  });
}

class DetectedMilestone {
  final String milestoneType;
  final String celebrationTier;
  final String contextSummary;

  const DetectedMilestone({
    required this.milestoneType,
    required this.celebrationTier,
    required this.contextSummary,
  });
}

class MilestoneDetector {
  final AchievementDao _achievementDao;
  final MetricsDao _metricsDao;
  final StreakDao _streakDao;

  static const List<MilestoneRule> rules = [
    MilestoneRule(milestoneType: '10_sessions', metricType: 'session_count', threshold: 10, celebrationTier: 'micro', contextTemplate: '10e sessie! Je bouwt een ritme.'),
    MilestoneRule(milestoneType: '50_sessions', metricType: 'session_count', threshold: 50, celebrationTier: 'minor', contextTemplate: '50 sessies met SOUL. Serieuze toewijding.'),
    MilestoneRule(milestoneType: '100_sessions', metricType: 'session_count', threshold: 100, celebrationTier: 'major', contextTemplate: '100 sessies! Je bent een machine.'),
    MilestoneRule(milestoneType: '10_decisions', metricType: 'decision_count', threshold: 10, celebrationTier: 'micro', contextTemplate: '10e beslissing! Je rolt.'),
    MilestoneRule(milestoneType: '50_decisions', metricType: 'decision_count', threshold: 50, celebrationTier: 'minor', contextTemplate: '50 beslissingen. Je maakt voortgang.'),
    MilestoneRule(milestoneType: '100_decisions', metricType: 'decision_count', threshold: 100, celebrationTier: 'major', contextTemplate: '100 beslissingen! Dat is leiderschap.'),
    MilestoneRule(milestoneType: '10_commits', metricType: 'commit_count', threshold: 10, celebrationTier: 'micro', contextTemplate: '10e commit! Code in productie.'),
    MilestoneRule(milestoneType: '50_commits', metricType: 'commit_count', threshold: 50, celebrationTier: 'minor', contextTemplate: '50 commits. Je bouwt iets echts.'),
    MilestoneRule(milestoneType: '100_commits', metricType: 'commit_count', threshold: 100, celebrationTier: 'major', contextTemplate: '100 commits! Serieuze codebase.'),
    MilestoneRule(milestoneType: 'first_vessel', metricType: 'vessel_task_count', threshold: 1, celebrationTier: 'minor', contextTemplate: 'Eerste vessel taak! SOUL heeft nu handen.'),
  ];

  // Streak milestones checked separately
  static const List<MilestoneRule> streakRules = [
    MilestoneRule(milestoneType: '7_day_streak', metricType: 'streak_daily', threshold: 7, celebrationTier: 'minor', contextTemplate: '7 dagen op rij! Een week van focus.'),
    MilestoneRule(milestoneType: '14_day_streak', metricType: 'streak_daily', threshold: 14, celebrationTier: 'minor', contextTemplate: '14 dagen! Twee weken non-stop.'),
    MilestoneRule(milestoneType: '30_day_streak', metricType: 'streak_daily', threshold: 30, celebrationTier: 'major', contextTemplate: '30 dagen streak! Dat is discipline.'),
  ];

  MilestoneDetector({
    required AchievementDao achievementDao,
    required MetricsDao metricsDao,
    required StreakDao streakDao,
  })  : _achievementDao = achievementDao,
        _metricsDao = metricsDao,
        _streakDao = streakDao;

  Future<List<DetectedMilestone>> checkMilestones() async {
    final detected = <DetectedMilestone>[];

    try {
      // Check metric-based milestones
      for (final rule in rules) {
        final alreadyAchieved = await _achievementDao.hasAchievement(rule.milestoneType);
        if (alreadyAchieved) continue;

        final cumulative = await _metricsDao.getCumulativeMetric(rule.metricType);
        if (cumulative != null && cumulative >= rule.threshold) {
          await _achievementDao.insertAchievement(
            milestoneType: rule.milestoneType,
            achievedAt: DateTime.now().millisecondsSinceEpoch,
            contextSummary: rule.contextTemplate,
            celebrationTier: rule.celebrationTier,
          );
          detected.add(DetectedMilestone(
            milestoneType: rule.milestoneType,
            celebrationTier: rule.celebrationTier,
            contextSummary: rule.contextTemplate,
          ));
        }
      }

      // Check streak milestones
      final streak = await _streakDao.getStreak('daily');
      if (streak != null) {
        for (final rule in streakRules) {
          final alreadyAchieved = await _achievementDao.hasAchievement(rule.milestoneType);
          if (alreadyAchieved) continue;

          if (streak.currentCount >= rule.threshold) {
            await _achievementDao.insertAchievement(
              milestoneType: rule.milestoneType,
              achievedAt: DateTime.now().millisecondsSinceEpoch,
              contextSummary: rule.contextTemplate,
              celebrationTier: rule.celebrationTier,
            );
            detected.add(DetectedMilestone(
              milestoneType: rule.milestoneType,
              celebrationTier: rule.celebrationTier,
              contextSummary: rule.contextTemplate,
            ));
          }
        }
      }
    } catch (e) {
      log.e('Milestone detection failed: $e');
    }

    if (detected.isNotEmpty) {
      log.i('Milestones detected: ${detected.map((m) => m.milestoneType).join(', ')}');
    }

    return detected;
  }
}
