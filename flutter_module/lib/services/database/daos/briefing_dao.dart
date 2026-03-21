import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'briefing_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/briefings.drift',
    '../tables/stuckness_signals.drift',
  },
)
class BriefingDao extends DatabaseAccessor<SoulDatabase>
    with _$BriefingDaoMixin {
  BriefingDao(super.db);

  Future<Briefing?> getBriefingForDate(String dateStr) {
    return (select(briefings)
          ..where((b) => b.date.equals(dateStr))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertBriefing({
    required String date,
    required String content,
    String? priorities,
    String? calendarSummary,
    int? conversationId,
  }) {
    return into(briefings).insert(
      BriefingsCompanion.insert(
        date: date,
        content: content,
        priorities: Value(priorities),
        calendarSummary: Value(calendarSummary),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        conversationId: Value(conversationId),
      ),
    );
  }

  Future<void> upsertStucknessSignal({
    required String topic,
    required int conversationCount,
    required int decisionCount,
    required int firstSeen,
    required int lastSeen,
    required double score,
  }) async {
    final existing = await (select(stucknessSignals)
          ..where((s) => s.topic.equals(topic))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      await (update(stucknessSignals)
            ..where((s) => s.id.equals(existing.id)))
          .write(StucknessSignalsCompanion(
        conversationCount: Value(conversationCount),
        decisionCount: Value(decisionCount),
        lastSeen: Value(lastSeen),
        score: Value(score),
      ));
    } else {
      await into(stucknessSignals).insert(
        StucknessSignalsCompanion.insert(
          topic: topic,
          conversationCount: conversationCount,
          decisionCount: decisionCount,
          firstSeen: firstSeen,
          lastSeen: lastSeen,
          score: score,
        ),
      );
    }
  }

  Future<List<StucknessSignal>> getActiveSignals(double threshold) {
    return (select(stucknessSignals)
          ..where((s) =>
              s.score.isBiggerOrEqualValue(threshold) & s.nudgeSent.equals(0))
          ..orderBy([(s) => OrderingTerm.desc(s.score)]))
        .get();
  }

  Future<void> markNudgeSent(int id) {
    return (update(stucknessSignals)
          ..where((s) => s.id.equals(id)))
        .write(const StucknessSignalsCompanion(nudgeSent: Value(1)));
  }
}
