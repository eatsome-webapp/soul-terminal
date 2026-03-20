import '../../core/utils/logger.dart';
import '../database/daos/streak_dao.dart';
import '../platform/local_notification_service.dart';

class StreakService {
  final StreakDao _streakDao;
  final LocalNotificationService? _notificationService;

  /// Notification IDs for streak events.
  static const int streakWarningNotificationId = 9001;
  static const int streakBrokenNotificationId = 9002;

  StreakService({
    required StreakDao streakDao,
    LocalNotificationService? notificationService,
  })  : _streakDao = streakDao,
        _notificationService = notificationService;

  Future<void> recordActivity() async {
    try {
      final today = _dateString(DateTime.now());
      final streak = await _streakDao.getStreak('daily');

      if (streak == null) {
        // First ever interaction
        await _streakDao.upsertStreak(
          streakType: 'daily',
          currentCount: 1,
          longestCount: 1,
          lastActiveDate: today,
          graceUsed: 0,
        );
        log.i('Streak started: day 1');
        return;
      }

      if (streak.lastActiveDate == today) {
        // Already counted today
        return;
      }

      final yesterday =
          _dateString(DateTime.now().subtract(const Duration(days: 1)));
      final dayBeforeYesterday =
          _dateString(DateTime.now().subtract(const Duration(days: 2)));

      int newCount;
      int newGrace;

      if (streak.lastActiveDate == yesterday) {
        // Consecutive day
        newCount = streak.currentCount + 1;
        newGrace = 0;
      } else if (streak.lastActiveDate == dayBeforeYesterday &&
          streak.graceUsed == 0) {
        // Grace freeze: missed yesterday but grace available
        newCount = streak.currentCount + 1;
        newGrace = 1;
        log.i('Streak saved by grace freeze: day $newCount');
      } else {
        // Streak broken
        newCount = 1;
        newGrace = 0;
        log.i('Streak broken (was ${streak.currentCount} days)');
      }

      final newLongest =
          newCount > streak.longestCount ? newCount : streak.longestCount;

      await _streakDao.upsertStreak(
        streakType: 'daily',
        currentCount: newCount,
        longestCount: newLongest,
        lastActiveDate: today,
        graceUsed: newGrace,
      );
    } catch (e) {
      log.e('Streak update failed: $e');
    }
  }

  Future<void> checkStreakBreak() async {
    try {
      final streak = await _streakDao.getStreak('daily');
      if (streak == null || streak.currentCount == 0) return;

      final today = _dateString(DateTime.now());
      final yesterday =
          _dateString(DateTime.now().subtract(const Duration(days: 1)));

      if (streak.lastActiveDate == today ||
          streak.lastActiveDate == yesterday) {
        return; // Streak still active
      }

      final dayBeforeYesterday =
          _dateString(DateTime.now().subtract(const Duration(days: 2)));

      if (streak.lastActiveDate == dayBeforeYesterday &&
          streak.graceUsed == 0) {
        // Grace available — warn user
        await _notificationService?.showNudgeNotification(
          title: 'SOUL \u2014 Je streak is in gevaar!',
          body:
              'Je streak van ${streak.currentCount} dagen loopt af. Open SOUL om hem te redden.',
        );
      } else {
        // Streak is broken
        await _notificationService?.showNudgeNotification(
          title: 'SOUL \u2014 Streak verbroken',
          body:
              'Je streak van ${streak.currentCount} dagen is voorbij. Tijd voor een nieuwe start.',
        );
        // Reset streak
        await _streakDao.upsertStreak(
          streakType: 'daily',
          currentCount: 0,
          longestCount: streak.longestCount,
          lastActiveDate: streak.lastActiveDate,
          graceUsed: 0,
        );
      }
    } catch (e) {
      log.e('Streak break check failed: $e');
    }
  }

  Future<Map<String, int>> getStreakData() async {
    final streak = await _streakDao.getStreak('daily');
    if (streak == null) {
      return {'current': 0, 'longest': 0, 'graceUsed': 0};
    }
    return {
      'current': streak.currentCount,
      'longest': streak.longestCount,
      'graceUsed': streak.graceUsed,
    };
  }

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
