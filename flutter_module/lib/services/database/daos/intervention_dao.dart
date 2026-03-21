import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../models/intervention.dart' as imodel;
import '../soul_database.dart';

part 'intervention_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/intervention_states.drift',
  },
)
class InterventionDao extends DatabaseAccessor<SoulDatabase>
    with _$InterventionDaoMixin {
  final Logger _logger = Logger();

  InterventionDao(super.db);

  Future<void> upsertIntervention(imodel.InterventionState state) async {
    await into(interventionStates).insertOnConflictUpdate(
      InterventionStatesCompanion.insert(
        id: state.id,
        type: state.type.name,
        level: state.level.name,
        triggerDescription: state.triggerDescription,
        proposedDefault: Value(state.proposedDefault),
        proposalDeadlineAt:
            Value(state.proposalDeadlineAt?.millisecondsSinceEpoch),
        detectedAt: state.detectedAt.millisecondsSinceEpoch,
        level1SentAt: Value(state.level1SentAt?.millisecondsSinceEpoch),
        level2SentAt: Value(state.level2SentAt?.millisecondsSinceEpoch),
        level3SentAt: Value(state.level3SentAt?.millisecondsSinceEpoch),
        resolvedAt: Value(state.resolvedAt?.millisecondsSinceEpoch),
        relatedEntityId: Value(state.relatedEntityId),
      ),
    );
  }

  Future<List<imodel.InterventionState>> getActiveInterventions() async {
    final rows = await activeInterventions().get();
    return rows.map(_rowToState).toList();
  }

  Future<imodel.InterventionState?> getById(String id) async {
    final row = await interventionById(id).getSingleOrNull();
    if (row == null) return null;
    return _rowToState(row);
  }

  Future<void> resolveIntervention(String id, DateTime resolvedAt) async {
    await (update(interventionStates)..where((t) => t.id.equals(id))).write(
      InterventionStatesCompanion(
        level: const Value('resolved'),
        resolvedAt: Value(resolvedAt.millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteOlderThan(DateTime cutoff) async {
    await (delete(interventionStates)
          ..where((t) =>
              t.detectedAt.isSmallerThanValue(cutoff.millisecondsSinceEpoch)))
        .go();
  }

  imodel.InterventionState _rowToState(InterventionRow row) {
    return imodel.InterventionState(
      id: row.id,
      type: imodel.InterventionType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => imodel.InterventionType.stuckness,
      ),
      level: imodel.InterventionLevel.values.firstWhere(
        (l) => l.name == row.level,
        orElse: () => imodel.InterventionLevel.detected,
      ),
      triggerDescription: row.triggerDescription,
      proposedDefault: row.proposedDefault,
      proposalDeadlineAt: row.proposalDeadlineAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.proposalDeadlineAt!)
          : null,
      detectedAt: DateTime.fromMillisecondsSinceEpoch(row.detectedAt),
      level1SentAt: row.level1SentAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.level1SentAt!)
          : null,
      level2SentAt: row.level2SentAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.level2SentAt!)
          : null,
      level3SentAt: row.level3SentAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.level3SentAt!)
          : null,
      resolvedAt: row.resolvedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.resolvedAt!)
          : null,
      relatedEntityId: row.relatedEntityId,
    );
  }
}
