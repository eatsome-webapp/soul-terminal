import 'package:logger/logger.dart';

import 'models/vessel_task.dart';

/// Routes tasks to the appropriate vessel based on intent keywords.
/// Pattern matches the existing ModelRouter approach in services/ai/model_router.dart.
///
/// - OpenClaw: automation, ops, web tasks, browser, messaging, cron, deploy
/// - Agent SDK: deep coding sessions, file editing, code review, refactoring
class VesselRouter {
  final Logger _log = Logger();

  /// Classify a task description and return the target vessel.
  VesselType route(String taskDescription) {
    final lower = taskDescription.toLowerCase();

    // Agent SDK indicators (deep coding)
    const codingPatterns = [
      'build feature',
      'refactor',
      'write code',
      'implement',
      'fix bug',
      'add test',
      'code review',
      'pull request',
      'write tests',
      'edit file',
      'update code',
      'create file',
      'debug',
      'coding session',
    ];

    // OpenClaw indicators (automation/ops)
    const opsPatterns = [
      'deploy',
      'run command',
      'check status',
      'send message',
      'schedule',
      'cron',
      'webhook',
      'browser',
      'scrape',
      'search web',
      'whatsapp',
      'telegram',
      'slack',
      'discord',
      'execute',
      'shell',
      'terminal',
      'screenshot',
      'fetch url',
      'python script',
      'node script',
      'automation',
    ];

    for (final pattern in codingPatterns) {
      if (lower.contains(pattern)) return VesselType.agentSdk;
    }
    for (final pattern in opsPatterns) {
      if (lower.contains(pattern)) return VesselType.openClaw;
    }

    // Default to OpenClaw (more versatile, always available)
    return VesselType.openClaw;
  }

  /// Intelligent routing considering vessel availability (RELAY-05).
  /// Falls back to available vessel if preferred is disconnected.
  VesselType routeWithAvailability({
    required String taskDescription,
    required bool openClawAvailable,
    required bool agentSdkAvailable,
  }) {
    final preferred = route(taskDescription);

    // If preferred vessel is available, use it
    if (preferred == VesselType.openClaw && openClawAvailable) return preferred;
    if (preferred == VesselType.agentSdk && agentSdkAvailable) return preferred;

    // Fallback: use whatever is available
    if (openClawAvailable) {
      _log.i('Routing fallback: ${preferred.name} unavailable, using OpenClaw');
      return VesselType.openClaw;
    }
    if (agentSdkAvailable) {
      _log.i('Routing fallback: ${preferred.name} unavailable, using Agent SDK');
      return VesselType.agentSdk;
    }

    // Nothing available — return preferred and let VesselManager handle the error
    _log.w('No vessels available for routing');
    return preferred;
  }
}
