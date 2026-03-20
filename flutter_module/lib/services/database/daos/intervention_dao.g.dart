// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention_dao.dart';

// ignore_for_file: type=lint
mixin _$InterventionDaoMixin on DatabaseAccessor<SoulDatabase> {
  InterventionStates get interventionStates =>
      attachedDatabase.interventionStates;
  Selectable<InterventionRow> activeInterventions() {
    return customSelect(
      'SELECT * FROM intervention_states WHERE level != \'resolved\' AND level != \'inactive\' ORDER BY detected_at DESC',
      variables: [],
      readsFrom: {interventionStates},
    ).asyncMap(interventionStates.mapFromRow);
  }

  Selectable<InterventionRow> interventionById(String id) {
    return customSelect(
      'SELECT * FROM intervention_states WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {interventionStates},
    ).asyncMap(interventionStates.mapFromRow);
  }

  Selectable<InterventionRow> interventionsOlderThan(int cutoff) {
    return customSelect(
      'SELECT * FROM intervention_states WHERE detected_at < ?1',
      variables: [Variable<int>(cutoff)],
      readsFrom: {interventionStates},
    ).asyncMap(interventionStates.mapFromRow);
  }

  InterventionDaoManager get managers => InterventionDaoManager(this);
}

class InterventionDaoManager {
  final _$InterventionDaoMixin _db;
  InterventionDaoManager(this._db);
  $InterventionStatesTableManager get interventionStates =>
      $InterventionStatesTableManager(
        _db.attachedDatabase,
        _db.interventionStates,
      );
}
