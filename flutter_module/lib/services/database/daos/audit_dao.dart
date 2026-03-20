import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../soul_database.dart';

part 'audit_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/audit_log.drift',
  },
)
class AuditDao extends DatabaseAccessor<SoulDatabase> with _$AuditDaoMixin {
  final Logger _logger = Logger();

  AuditDao(super.db);

  /// Log an action to the audit trail.
  Future<void> logAction({
    required String actionType,
    required String toolName,
    required int tier,
    String? reasoning,
    String? result,
    required DateTime executedAt,
    String? sessionId,
    String? vesselType,
  }) async {
    await into(auditLog).insert(
      AuditLogCompanion.insert(
        actionType: actionType,
        toolName: toolName,
        tier: tier,
        reasoning: Value(reasoning),
        result: Value(result),
        executedAt: executedAt.millisecondsSinceEpoch,
        sessionId: Value(sessionId),
        vesselType: Value(vesselType),
      ),
    );
    _logger.d('Audit: $actionType $toolName tier=$tier result=$result');
  }

  /// Get recent audit log entries.
  Future<List<AuditLogData>> getRecent({int limit = 50}) async {
    return recentAuditEntries(limit).get();
  }

  /// Count successes and failures for a specific tool (for tier promotion/demotion).
  Future<({int successes, int failures})> getToolTrackRecord(
      String toolName) async {
    final successRows = await toolSuccessCount(toolName).get();
    final failureRows = await toolFailureCount(toolName).get();

    final successes = successRows.firstOrNull ?? 0;
    final failures = failureRows.firstOrNull ?? 0;

    return (successes: successes, failures: failures);
  }

  /// Delete entries older than cutoff.
  Future<void> deleteOlderThan(DateTime cutoff) async {
    await deleteAuditOlderThan(cutoff.millisecondsSinceEpoch);
    _logger.i('Audit: deleted entries older than $cutoff');
  }
}
