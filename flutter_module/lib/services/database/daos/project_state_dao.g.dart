// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_state_dao.dart';

// ignore_for_file: type=lint
mixin _$ProjectStateDaoMixin on DatabaseAccessor<SoulDatabase> {
  ProjectState get projectState => attachedDatabase.projectState;
  ProjectStateDaoManager get managers => ProjectStateDaoManager(this);
}

class ProjectStateDaoManager {
  final _$ProjectStateDaoMixin _db;
  ProjectStateDaoManager(this._db);
  $ProjectStateTableManager get projectState =>
      $ProjectStateTableManager(_db.attachedDatabase, _db.projectState);
}
