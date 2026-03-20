import 'dart:convert';
import 'package:logger/logger.dart';

import '../database/daos/project_dao.dart';
import '../database/soul_database.dart' show Project;
import '../vessels/openclaw/openclaw_client.dart';
import '../vessels/openclaw/openclaw_tools.dart';
import '../platform/local_notification_service.dart';
import 'ci_status.dart';

/// Monitors GitHub Actions CI status per project via OpenClaw.
/// Polls each project's repo for workflow runs and open PRs,
/// caches status, and triggers notifications on failures/stale PRs.
class CiMonitorService {
  final ProjectDao _projectDao;
  final OpenClawClient? _openClawClient;
  final LocalNotificationService _notificationService;
  final Logger _logger;

  final Map<String, CiStatus> _statusCache = {};

  /// Rate limit: skip projects checked less than 15 minutes ago.
  static const _checkInterval = Duration(minutes: 15);

  CiMonitorService({
    required ProjectDao projectDao,
    OpenClawClient? openClawClient,
    required LocalNotificationService notificationService,
    Logger? logger,
  })  : _projectDao = projectDao,
        _openClawClient = openClawClient,
        _notificationService = notificationService,
        _logger = logger ?? Logger();

  /// Check all active projects with a repo URL for CI status.
  Future<void> checkAllProjects() async {
    final projects = await _projectDao.getActiveProjects();
    final projectsWithRepo =
        projects.where((p) => p.repoUrl != null && p.repoUrl!.isNotEmpty);

    for (final project in projectsWithRepo) {
      final cached = _statusCache[project.id];
      if (cached?.checkedAt != null) {
        final elapsed = DateTime.now().difference(cached!.checkedAt!);
        if (elapsed < _checkInterval) {
          _logger.d('Skipping ${project.name} — checked ${elapsed.inMinutes}m ago');
          continue;
        }
      }
      await checkProject(project);
    }
  }

  /// Check CI status for a single project.
  Future<CiStatus> checkProject(Project project) async {
    if (_openClawClient == null) {
      final status = CiStatus(
        projectId: project.id,
        health: CiHealth.unknown,
        checkedAt: DateTime.now(),
      );
      _statusCache[project.id] = status;
      return status;
    }

    final repoMatch = RegExp(r'github\.com[/:]([^/]+)/([^/.]+)')
        .firstMatch(project.repoUrl ?? '');
    if (repoMatch == null) {
      _logger.w('Cannot parse repo URL for ${project.name}: ${project.repoUrl}');
      final status = CiStatus(
        projectId: project.id,
        health: CiHealth.unknown,
        checkedAt: DateTime.now(),
      );
      _statusCache[project.id] = status;
      return status;
    }

    final owner = repoMatch.group(1)!;
    final repo = repoMatch.group(2)!;
    final tools = OpenClawTools(_openClawClient!);
    final previous = _statusCache[project.id];

    CiHealth health = CiHealth.unknown;
    String? lastWorkflowName;
    String? lastCommitSha;
    DateTime? lastRunAt;

    // Check workflow runs
    try {
      final runsResult = await tools.exec(
        command: 'gh api repos/$owner/$repo/actions/runs '
            "--jq '.workflow_runs[:3] | .[] | {status,conclusion,name,head_sha,created_at}'",
      );

      final output = runsResult['output'] as String? ?? '';
      if (output.isNotEmpty) {
        // Parse newline-separated JSON objects
        final lines = output.trim().split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final run = jsonDecode(line) as Map<String, dynamic>;
            lastWorkflowName ??= run['name'] as String?;
            lastCommitSha ??= run['head_sha'] as String?;
            final createdAt = run['created_at'] as String?;
            if (createdAt != null && lastRunAt == null) {
              lastRunAt = DateTime.tryParse(createdAt);
            }

            final conclusion = run['conclusion'] as String?;
            if (conclusion == 'success' && health == CiHealth.unknown) {
              health = CiHealth.passing;
            } else if (conclusion == 'failure') {
              health = CiHealth.failing;
            }
          } catch (e) {
            _logger.d('Failed to parse run JSON line: $e');
          }
        }
      }
    } catch (e) {
      _logger.e('Failed to check workflow runs for $owner/$repo: $e');
    }

    // Check open PRs
    int openPrCount = 0;
    int stalePrCount = 0;
    try {
      final prResult = await tools.exec(
        command: "gh api repos/$owner/$repo/pulls --jq '.[].created_at'",
      );

      final prOutput = prResult['output'] as String? ?? '';
      if (prOutput.isNotEmpty) {
        final prDates = prOutput.trim().split('\n');
        openPrCount = prDates.length;
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        for (final dateStr in prDates) {
          final cleaned = dateStr.replaceAll('"', '').trim();
          final date = DateTime.tryParse(cleaned);
          if (date != null && date.isBefore(sevenDaysAgo)) {
            stalePrCount++;
          }
        }
      }
    } catch (e) {
      _logger.e('Failed to check PRs for $owner/$repo: $e');
    }

    final status = CiStatus(
      projectId: project.id,
      health: health,
      lastWorkflowName: lastWorkflowName,
      lastCommitSha: lastCommitSha,
      lastRunAt: lastRunAt,
      openPrCount: openPrCount,
      stalePrCount: stalePrCount,
      checkedAt: DateTime.now(),
    );

    _statusCache[project.id] = status;
    await _alertOnFailure(project, previous, status);

    _logger.i('CI status for ${project.name}: ${status.health.name} '
        '(PRs: $openPrCount, stale: $stalePrCount)');
    return status;
  }

  /// Alert on CI state transitions.
  Future<void> _alertOnFailure(
    Project project,
    CiStatus? previous,
    CiStatus current,
  ) async {
    // Transition from passing/unknown to failing
    if (previous?.health != CiHealth.failing &&
        current.health == CiHealth.failing) {
      await _notificationService.showAlertNotification(
        title: 'CI Failure: ${project.name}',
        body: 'Workflow "${current.lastWorkflowName ?? "Unknown"}" is failing. '
            'Check the latest commit: ${current.lastCommitSha?.substring(0, 7) ?? "?"}',
      );
    }

    // New stale PRs detected
    if ((previous?.stalePrCount ?? 0) == 0 && current.stalePrCount > 0) {
      await _notificationService.showNudgeNotification(
        title: 'Stale PRs: ${project.name}',
        body: '${current.stalePrCount} PRs open >7 days',
      );
    }
  }

  /// Get cached status for a project.
  CiStatus? getStatus(String projectId) => _statusCache[projectId];

  /// Get all cached statuses.
  Map<String, CiStatus> getAllStatuses() => Map.unmodifiable(_statusCache);

  /// Analyzes all project states and returns cross-project insights.
  /// E.g., "Project A is blocked, switch to Project B where CI is green."
  Future<List<String>> getCrossProjectInsights() async {
    final projects = await _projectDao.getActiveProjects();
    if (projects.length < 2) return [];

    final insights = <String>[];
    final blocked = <Project>[];
    final available = <Project>[];

    for (final project in projects) {
      final status = _statusCache[project.id];
      if (status?.health == CiHealth.failing) {
        blocked.add(project);
      } else if (status?.health == CiHealth.passing) {
        available.add(project);
      }
    }

    for (final blockedProject in blocked) {
      for (final availableProject in available) {
        insights.add(
          '${blockedProject.name} heeft een falende CI pipeline — '
          'schakel naar ${availableProject.name} waar alles groen is.',
        );
      }
    }

    return insights;
  }
}
