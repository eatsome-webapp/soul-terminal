import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'api_usage_dao.g.dart';

@DriftAccessor(
  include: {'../tables/api_usage.drift'},
)
class ApiUsageDao extends DatabaseAccessor<SoulDatabase>
    with _$ApiUsageDaoMixin {
  ApiUsageDao(super.db);

  Future<int> insertUsage({
    int? conversationId,
    required String model,
    required int inputTokens,
    required int outputTokens,
    int cacheCreationTokens = 0,
    int cacheReadTokens = 0,
    required double costUsd,
  }) {
    return into(apiUsage).insert(
      ApiUsageCompanion.insert(
        conversationId: Value(conversationId),
        model: model,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        cacheCreationTokens: Value(cacheCreationTokens),
        cacheReadTokens: Value(cacheReadTokens),
        costUsd: costUsd,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Get total cost for a date range (epoch millis).
  Future<double> getTotalCost(int fromEpoch, int toEpoch) async {
    final query = selectOnly(apiUsage)
      ..addColumns([apiUsage.costUsd.sum()])
      ..where(apiUsage.createdAt.isBiggerOrEqualValue(fromEpoch) &
          apiUsage.createdAt.isSmallerThanValue(toEpoch));
    final result = await query.getSingle();
    return result.read(apiUsage.costUsd.sum()) ?? 0.0;
  }

  /// Get cost for a date range, returning null if no usage exists.
  /// Used by MetricsCollector for daily aggregation.
  Future<double?> getCostForDateRange(int startMs, int endMs) async {
    final result = await customSelect(
      'SELECT SUM(cost_usd) AS total FROM api_usage WHERE created_at >= ? AND created_at < ?',
      variables: [Variable.withInt(startMs), Variable.withInt(endMs)],
      readsFrom: {apiUsage},
    ).getSingle();
    return result.read<double?>('total');
  }

  /// Get today's total cost.
  Future<double> getTodayCost() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getTotalCost(
      startOfDay.millisecondsSinceEpoch,
      endOfDay.millisecondsSinceEpoch,
    );
  }

  /// Get current month's total cost.
  Future<double> getMonthCost() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    return getTotalCost(
      startOfMonth.millisecondsSinceEpoch,
      endOfMonth.millisecondsSinceEpoch,
    );
  }

  /// Get total tokens used today (for display).
  Future<Map<String, int>> getTodayTokens() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(apiUsage)
      ..addColumns([
        apiUsage.inputTokens.sum(),
        apiUsage.outputTokens.sum(),
      ])
      ..where(apiUsage.createdAt.isBiggerOrEqualValue(startOfDay.millisecondsSinceEpoch) &
          apiUsage.createdAt.isSmallerThanValue(endOfDay.millisecondsSinceEpoch));

    final result = await query.getSingle();
    return {
      'input': result.read(apiUsage.inputTokens.sum()) ?? 0,
      'output': result.read(apiUsage.outputTokens.sum()) ?? 0,
    };
  }

  /// Watch today's cost for reactive display.
  Stream<double> watchTodayCost() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(apiUsage)
      ..addColumns([apiUsage.costUsd.sum()])
      ..where(apiUsage.createdAt.isBiggerOrEqualValue(startOfDay.millisecondsSinceEpoch) &
          apiUsage.createdAt.isSmallerThanValue(endOfDay.millisecondsSinceEpoch));

    return query.watchSingle().map(
          (row) => row.read(apiUsage.costUsd.sum()) ?? 0.0,
        );
  }
}
