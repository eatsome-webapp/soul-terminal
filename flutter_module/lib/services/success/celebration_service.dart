import '../../core/utils/logger.dart';
import '../database/daos/achievement_dao.dart';
import '../platform/local_notification_service.dart';
import 'milestone_detector.dart';

class CelebrationService {
  final AchievementDao _achievementDao;
  final LocalNotificationService? _notificationService;

  CelebrationService({
    required AchievementDao achievementDao,
    LocalNotificationService? notificationService,
  })  : _achievementDao = achievementDao,
        _notificationService = notificationService;

  Future<void> celebrate(List<DetectedMilestone> milestones) async {
    for (final milestone in milestones) {
      switch (milestone.celebrationTier) {
        case 'micro':
          // Micro: chat message only — handled via system prompt injection
          log.i('Micro celebration: ${milestone.contextSummary}');
          break;
        case 'minor':
          // Minor: chat message + animation — handled via UI layer
          log.i('Minor celebration: ${milestone.contextSummary}');
          break;
        case 'major':
          // Major: confetti + push notification + journal entry
          await _notificationService?.showAlertNotification(
            title: 'SOUL \u2014 Milestone bereikt!',
            body: milestone.contextSummary,
            payload: 'milestone_${milestone.milestoneType}',
          );
          log.i('Major celebration: ${milestone.contextSummary}');
          break;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getUndisplayedCelebrations() async {
    final undisplayed = await _achievementDao.getUndisplayed();
    return undisplayed.map((a) => {
      'id': a.id,
      'milestoneType': a.milestoneType,
      'contextSummary': a.contextSummary ?? '',
      'celebrationTier': a.celebrationTier,
      'achievedAt': a.achievedAt,
    }).toList();
  }

  Future<void> markDisplayed(int achievementId) async {
    await _achievementDao.markDisplayed(achievementId);
  }

  Future<String?> getCelebrationContextForPrompt() async {
    final undisplayed = await _achievementDao.getUndisplayed();
    if (undisplayed.isEmpty) return null;

    final buffer = StringBuffer();
    buffer.writeln('The user just hit these milestones. Celebrate naturally in your response:');
    for (final a in undisplayed) {
      buffer.writeln('- ${a.contextSummary ?? a.milestoneType}');
    }
    return buffer.toString();
  }
}
