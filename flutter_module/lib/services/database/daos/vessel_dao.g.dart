// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vessel_dao.dart';

// ignore_for_file: type=lint
mixin _$VesselDaoMixin on DatabaseAccessor<SoulDatabase> {
  VesselTasks get vesselTasks => attachedDatabase.vesselTasks;
  VesselConfigs get vesselConfigs => attachedDatabase.vesselConfigs;
  Selectable<VesselTask> recentVesselTasks(int limit) {
    return customSelect(
      'SELECT * FROM vessel_tasks ORDER BY created_at DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {vesselTasks},
    ).asyncMap(vesselTasks.mapFromRow);
  }

  Selectable<VesselTask> vesselTaskById(String id) {
    return customSelect(
      'SELECT * FROM vessel_tasks WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {vesselTasks},
    ).asyncMap(vesselTasks.mapFromRow);
  }

  Selectable<VesselTask> vesselTasksByStatus(String status) {
    return customSelect(
      'SELECT * FROM vessel_tasks WHERE status = ?1 ORDER BY created_at DESC',
      variables: [Variable<String>(status)],
      readsFrom: {vesselTasks},
    ).asyncMap(vesselTasks.mapFromRow);
  }

  Selectable<VesselConfig> activeConfigByType(String vesselType) {
    return customSelect(
      'SELECT * FROM vessel_configs WHERE vessel_type = ?1 AND is_active = 1 LIMIT 1',
      variables: [Variable<String>(vesselType)],
      readsFrom: {vesselConfigs},
    ).asyncMap(vesselConfigs.mapFromRow);
  }

  Selectable<VesselConfig> allConfigs() {
    return customSelect(
      'SELECT * FROM vessel_configs ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {vesselConfigs},
    ).asyncMap(vesselConfigs.mapFromRow);
  }

  VesselDaoManager get managers => VesselDaoManager(this);
}

class VesselDaoManager {
  final _$VesselDaoMixin _db;
  VesselDaoManager(this._db);
  $VesselTasksTableManager get vesselTasks =>
      $VesselTasksTableManager(_db.attachedDatabase, _db.vesselTasks);
  $VesselConfigsTableManager get vesselConfigs =>
      $VesselConfigsTableManager(_db.attachedDatabase, _db.vesselConfigs);
}
