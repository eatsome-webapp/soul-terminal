// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_usage_dao.dart';

// ignore_for_file: type=lint
mixin _$ApiUsageDaoMixin on DatabaseAccessor<SoulDatabase> {
  ApiUsage get apiUsage => attachedDatabase.apiUsage;
  ApiUsageDaoManager get managers => ApiUsageDaoManager(this);
}

class ApiUsageDaoManager {
  final _$ApiUsageDaoMixin _db;
  ApiUsageDaoManager(this._db);
  $ApiUsageTableManager get apiUsage =>
      $ApiUsageTableManager(_db.attachedDatabase, _db.apiUsage);
}
