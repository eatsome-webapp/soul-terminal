import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'project_state_dao.g.dart';

@DriftAccessor(include: {'../tables/project_state.drift'})
class ProjectStateDao extends DatabaseAccessor<SoulDatabase>
    with _$ProjectStateDaoMixin {
  ProjectStateDao(super.db);

  Future<void> upsertState({
    required String projectId,
    required String currentStatus,
    String? unvalidatedAssumptions,
    String? riskiestItem,
    String? scopeCreepFlags,
    String? sourceConversationId,
  }) async {
    await into(projectState).insert(
      ProjectStateCompanion.insert(
        projectId: projectId,
        currentStatus: currentStatus,
        unvalidatedAssumptions: Value(unvalidatedAssumptions),
        riskiestItem: Value(riskiestItem),
        scopeCreepFlags: Value(scopeCreepFlags),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        sourceConversationId: Value(sourceConversationId),
      ),
    );
  }

  Future<ProjectStateData?> getLatestState(String projectId) {
    return (select(projectState)
          ..where((s) => s.projectId.equals(projectId))
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<ProjectStateData>> getStateHistory(String projectId,
      {int limit = 10}) {
    return (select(projectState)
          ..where((s) => s.projectId.equals(projectId))
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)])
          ..limit(limit))
        .get();
  }
}
