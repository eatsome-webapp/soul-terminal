import 'openclaw_client.dart';

/// Manages cron jobs on OpenClaw Gateway (VES-05).
/// All operations use /tools/invoke with tool: "cron".
class OpenClawCron {
  final OpenClawClient _client;

  const OpenClawCron(this._client);

  /// Create a new cron job.
  /// [scheduleKind] determines the type of schedule:
  ///   - 'cron': standard cron expression, e.g. "0 9 * * *" (daily at 9am)
  ///   - 'iso8601': one-shot at specific time, e.g. "2026-04-01T09:00:00Z"
  ///   - 'interval': repeating interval, e.g. "every 30m", "every 2h"
  Future<Map<String, dynamic>> addJob({
    required String name,
    required String scheduleKind,
    required String scheduleExpr,
    required String prompt,
    int timeoutSeconds = 300,
    String deliveryChannel = 'none',
    String sessionTarget = 'isolated',
  }) {
    return _client.invokeTool(
      tool: 'cron',
      args: {
        'action': 'add',
        'name': name,
        'schedule': {'kind': scheduleKind, 'expr': scheduleExpr},
        'sessionTarget': sessionTarget,
        'payload': {
          'kind': 'agentTurn',
          'message': prompt,
          'timeoutSeconds': timeoutSeconds,
        },
        if (deliveryChannel != 'none')
          'delivery': {
            'mode': 'announce',
            'channel': deliveryChannel,
          },
      },
    );
  }

  /// List all cron jobs.
  Future<Map<String, dynamic>> listJobs() {
    return _client.invokeTool(
      tool: 'cron',
      args: {'action': 'list'},
    );
  }

  /// Update an existing cron job.
  Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? name,
    String? scheduleKind,
    String? scheduleExpr,
    String? prompt,
    bool? enabled,
  }) {
    return _client.invokeTool(
      tool: 'cron',
      args: {
        'action': 'update',
        'id': jobId,
        if (name != null) 'name': name,
        if (scheduleKind != null && scheduleExpr != null)
          'schedule': {'kind': scheduleKind, 'expr': scheduleExpr},
        if (prompt != null)
          'payload': {'kind': 'agentTurn', 'message': prompt},
        if (enabled != null) 'enabled': enabled,
      },
    );
  }

  /// Delete a cron job.
  Future<Map<String, dynamic>> removeJob(String jobId) {
    return _client.invokeTool(
      tool: 'cron',
      args: {'action': 'remove', 'id': jobId},
    );
  }

  /// Trigger a cron job manually.
  Future<Map<String, dynamic>> runJob(String jobId) {
    return _client.invokeTool(
      tool: 'cron',
      args: {'action': 'run', 'id': jobId},
    );
  }
}
