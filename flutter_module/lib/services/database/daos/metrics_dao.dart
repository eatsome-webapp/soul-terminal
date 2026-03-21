import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'metrics_dao.g.dart';

@DriftAccessor(include: {'../tables/daily_metrics.drift'})
class MetricsDao extends DatabaseAccessor<SoulDatabase>
    with _$MetricsDaoMixin {
  MetricsDao(super.db);

  Future<void> upsertMetric({
    required String date,
    required String metricType,
    required double value,
  }) async {
    await into(dailyMetrics).insert(
      DailyMetricsCompanion.insert(
        date: date,
        metricType: metricType,
        value: value,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<DailyMetric>> getMetricsForDate(String date) {
    return (select(dailyMetrics)..where((m) => m.date.equals(date))).get();
  }

  Future<List<DailyMetric>> getMetricsForDateRange(
      String startDate, String endDate) {
    return (select(dailyMetrics)
          ..where((m) =>
              m.date.isBiggerOrEqualValue(startDate) &
              m.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(m) => OrderingTerm.asc(m.date)]))
        .get();
  }

  Future<double?> getCumulativeMetric(String metricType) async {
    final result = await customSelect(
      'SELECT SUM(value) AS total FROM daily_metrics WHERE metric_type = ?',
      variables: [Variable.withString(metricType)],
    ).getSingleOrNull();
    return result?.read<double?>('total');
  }
}
