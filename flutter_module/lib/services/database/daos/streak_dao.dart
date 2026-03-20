import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'streak_dao.g.dart';

@DriftAccessor(include: {'../tables/streaks.drift'})
class StreakDao extends DatabaseAccessor<SoulDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  Future<Streak?> getStreak(String streakType) {
    return (select(streaks)
          ..where((s) => s.streakType.equals(streakType))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertStreak({
    required String streakType,
    required int currentCount,
    required int longestCount,
    required String lastActiveDate,
    required int graceUsed,
  }) async {
    await into(streaks).insert(
      StreaksCompanion.insert(
        streakType: streakType,
        currentCount: Value(currentCount),
        longestCount: Value(longestCount),
        lastActiveDate: lastActiveDate,
        graceUsed: Value(graceUsed),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
