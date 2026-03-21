// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_dao.dart';

// ignore_for_file: type=lint
mixin _$MetricsDaoMixin on DatabaseAccessor<SoulDatabase> {
  DailyMetrics get dailyMetrics => attachedDatabase.dailyMetrics;
  MetricsDaoManager get managers => MetricsDaoManager(this);
}

class MetricsDaoManager {
  final _$MetricsDaoMixin _db;
  MetricsDaoManager(this._db);
  $DailyMetricsTableManager get dailyMetrics =>
      $DailyMetricsTableManager(_db.attachedDatabase, _db.dailyMetrics);
}
