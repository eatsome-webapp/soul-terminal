// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'briefing_dao.dart';

// ignore_for_file: type=lint
mixin _$BriefingDaoMixin on DatabaseAccessor<SoulDatabase> {
  StucknessSignals get stucknessSignals => attachedDatabase.stucknessSignals;
  Briefings get briefings => attachedDatabase.briefings;
  BriefingDaoManager get managers => BriefingDaoManager(this);
}

class BriefingDaoManager {
  final _$BriefingDaoMixin _db;
  BriefingDaoManager(this._db);
  $StucknessSignalsTableManager get stucknessSignals =>
      $StucknessSignalsTableManager(_db.attachedDatabase, _db.stucknessSignals);
  $BriefingsTableManager get briefings =>
      $BriefingsTableManager(_db.attachedDatabase, _db.briefings);
}
