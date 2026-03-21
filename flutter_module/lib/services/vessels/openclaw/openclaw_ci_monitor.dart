import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';

import 'openclaw_cron.dart';
import 'openclaw_tools.dart';

/// Monitors GitHub Actions CI via OpenClaw (VES-13).
/// Uses cron jobs for periodic polling and exec tool for gh CLI queries.
class OpenClawCiMonitor {
  final OpenClawCron _cron;
  final OpenClawTools _tools;
  final Logger _log = Logger();

  final _failureController = StreamController<CiFailure>.broadcast();

  OpenClawCiMonitor({
    required OpenClawCron cron,
    required OpenClawTools tools,
  })  : _cron = cron,
        _tools = tools;

  /// Stream of CI failure events for notification delivery.
  Stream<CiFailure> get failures => _failureController.stream;

  /// Set up CI monitoring cron job for a GitHub repo (VES-13).
  /// Creates a recurring 5-minute check via OpenClaw cron.
  Future<void> setupMonitoring({
    required String repo,
    String intervalMinutes = '5',
  }) async {
    await _cron.addJob(
      name: 'ci-monitor-${repo.replaceAll('/', '-')}',
      scheduleKind: 'interval',
      scheduleExpr: 'every ${intervalMinutes}m',
      prompt: 'Check GitHub Actions status for $repo. '
          'Run: gh run list --repo $repo --limit 5 --json conclusion,status,name,createdAt. '
          'Report any failures.',
      deliveryChannel: 'soul',
    );
    _log.i('CI monitoring set up for $repo (every ${intervalMinutes}m)');
  }

  /// Check CI status immediately (manual trigger).
  Future<List<CiFailure>> checkNow({required String repo}) async {
    try {
      final result = await _tools.exec(
        command: 'gh run list --repo $repo --limit 5 '
            '--json conclusion,status,name,createdAt',
      );

      final output = result['output'] as String? ?? '';
      final runs = jsonDecode(output) as List<dynamic>;
      final failures = <CiFailure>[];

      for (final run in runs) {
        if (run['conclusion'] == 'failure') {
          final failure = CiFailure(
            repo: repo,
            workflowName: run['name'] as String? ?? 'Unknown',
            createdAt: DateTime.tryParse(run['createdAt'] as String? ?? '') ??
                DateTime.now(),
          );
          failures.add(failure);
          _failureController.add(failure);
        }
      }

      return failures;
    } catch (e) {
      _log.e('CI check failed for $repo: $e');
      return [];
    }
  }

  /// Remove CI monitoring for a repo.
  Future<void> removeMonitoring({required String repo}) async {
    final jobs = await _cron.listJobs();
    final jobList = jobs['jobs'] as List<dynamic>? ?? [];
    final targetName = 'ci-monitor-${repo.replaceAll('/', '-')}';

    for (final job in jobList) {
      if (job['name'] == targetName) {
        await _cron.removeJob(job['id'] as String);
        _log.i('CI monitoring removed for $repo');
        return;
      }
    }
  }

  void dispose() {
    _failureController.close();
  }
}

/// Represents a CI build failure.
class CiFailure {
  final String repo;
  final String workflowName;
  final DateTime createdAt;

  const CiFailure({
    required this.repo,
    required this.workflowName,
    required this.createdAt,
  });
}
