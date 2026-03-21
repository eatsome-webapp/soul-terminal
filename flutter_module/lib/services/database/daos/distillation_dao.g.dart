// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distillation_dao.dart';

// ignore_for_file: type=lint
mixin _$DistillationDaoMixin on DatabaseAccessor<SoulDatabase> {
  DistilledFacts get distilledFacts => attachedDatabase.distilledFacts;
  DistillationDaoManager get managers => DistillationDaoManager(this);
}

class DistillationDaoManager {
  final _$DistillationDaoMixin _db;
  DistillationDaoManager(this._db);
  $DistilledFactsTableManager get distilledFacts =>
      $DistilledFactsTableManager(_db.attachedDatabase, _db.distilledFacts);
}
