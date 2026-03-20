// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_dao.dart';

// ignore_for_file: type=lint
mixin _$StreakDaoMixin on DatabaseAccessor<SoulDatabase> {
  Streaks get streaks => attachedDatabase.streaks;
  StreakDaoManager get managers => StreakDaoManager(this);
}

class StreakDaoManager {
  final _$StreakDaoMixin _db;
  StreakDaoManager(this._db);
  $StreaksTableManager get streaks =>
      $StreaksTableManager(_db.attachedDatabase, _db.streaks);
}
