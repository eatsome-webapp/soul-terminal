import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'achievement_dao.g.dart';

@DriftAccessor(include: {'../tables/achievements.drift'})
class AchievementDao extends DatabaseAccessor<SoulDatabase>
    with _$AchievementDaoMixin {
  AchievementDao(super.db);

  Future<void> insertAchievement({
    required String milestoneType,
    required int achievedAt,
    String? contextSummary,
    required String celebrationTier,
  }) async {
    await into(achievements).insert(AchievementsCompanion.insert(
      milestoneType: milestoneType,
      achievedAt: achievedAt,
      contextSummary: Value(contextSummary),
      celebrationTier: celebrationTier,
    ));
  }

  Future<bool> hasAchievement(String milestoneType) async {
    final result = await (select(achievements)
          ..where((a) => a.milestoneType.equals(milestoneType))
          ..limit(1))
        .getSingleOrNull();
    return result != null;
  }

  Future<List<Achievement>> getUndisplayed() {
    return (select(achievements)
          ..where((a) => a.displayed.equals(0))
          ..orderBy([(a) => OrderingTerm.desc(a.achievedAt)]))
        .get();
  }

  Future<void> markDisplayed(int id) async {
    await (update(achievements)..where((a) => a.id.equals(id))).write(
      const AchievementsCompanion(displayed: Value(1)),
    );
  }

  Future<List<Achievement>> getAll() {
    return (select(achievements)
          ..orderBy([(a) => OrderingTerm.desc(a.achievedAt)]))
        .get();
  }
}
