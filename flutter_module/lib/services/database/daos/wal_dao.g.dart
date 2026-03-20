// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wal_dao.dart';

// ignore_for_file: type=lint
mixin _$WalDaoMixin on DatabaseAccessor<SoulDatabase> {
  AgenticWal get agenticWal => attachedDatabase.agenticWal;
  WalDaoManager get managers => WalDaoManager(this);
}

class WalDaoManager {
  final _$WalDaoMixin _db;
  WalDaoManager(this._db);
  $AgenticWalTableManager get agenticWal =>
      $AgenticWalTableManager(_db.attachedDatabase, _db.agenticWal);
}
