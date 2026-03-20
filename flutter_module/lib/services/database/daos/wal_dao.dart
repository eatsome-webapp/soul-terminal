import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'wal_dao.g.dart';

@DriftAccessor(include: {'../tables/agentic_wal.drift'})
class WalDao extends DatabaseAccessor<SoulDatabase> with _$WalDaoMixin {
  WalDao(super.db);

  Future<int> insertEntry({
    required String sessionId,
    required int iteration,
    required String intention,
    required String toolName,
    required String toolArgs,
    required int startedAt,
  }) async {
    return into(agenticWal).insert(AgenticWalCompanion.insert(
      sessionId: sessionId,
      iteration: iteration,
      intention: intention,
      toolName: toolName,
      toolArgs: toolArgs,
      startedAt: startedAt,
    ));
  }

  Future<void> updateStatus(int id, String status,
      {String? resultSummary, int? completedAt}) async {
    await (update(agenticWal)..where((w) => w.id.equals(id))).write(
      AgenticWalCompanion(
        status: Value(status),
        resultSummary: Value(resultSummary),
        completedAt: Value(completedAt),
      ),
    );
  }

  Future<List<AgenticWalData>> getIncompleteEntries() {
    return (select(agenticWal)
          ..where(
              (w) => w.status.isIn(['pending', 'executing']))
          ..orderBy([(w) => OrderingTerm.asc(w.startedAt)]))
        .get();
  }

  Future<List<AgenticWalData>> getEntriesForSession(String sessionId) {
    return (select(agenticWal)
          ..where((w) => w.sessionId.equals(sessionId))
          ..orderBy([(w) => OrderingTerm.asc(w.iteration)]))
        .get();
  }
}
