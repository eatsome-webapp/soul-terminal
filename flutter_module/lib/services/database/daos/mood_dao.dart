import 'package:drift/drift.dart';

import '../soul_database.dart';

part 'mood_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/mood_states.drift',
  },
)
class MoodDao extends DatabaseAccessor<SoulDatabase> with _$MoodDaoMixin {
  MoodDao(super.db);

  Future<void> insertMoodEntry({
    required String id,
    required String sessionId,
    required int energy,
    required String emotion,
    required String intent,
    required int analyzedAt,
    required int messageCount,
  }) {
    return into(moodStates).insertOnConflictUpdate(
      MoodStatesCompanion.insert(
        id: id,
        sessionId: sessionId,
        energy: energy,
        emotion: emotion,
        intent: intent,
        analyzedAt: analyzedAt,
        messageCount: messageCount,
      ),
    );
  }

  Future<MoodState?> getLatestForSession(String sessionId) {
    return latestMoodForSession(sessionId).getSingleOrNull();
  }

  Future<List<MoodState>> getRecentStates(int limit) {
    return recentMoodStates(limit).get();
  }

  Future<void> deleteOlderThan(DateTime cutoff) async {
    await (delete(moodStates)
          ..where(
              (t) => t.analyzedAt.isSmallerThanValue(cutoff.millisecondsSinceEpoch)))
        .go();
  }
}
