import 'dart:async';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../ai/trust_tier_classifier.dart';
import '../database/daos/audit_dao.dart';
import 'models/vessel_task.dart';
import 'models/vessel_result.dart';
import 'models/vessel_connection.dart';
import 'vessel_interface.dart';
import 'vessel_router.dart';
import 'openclaw/openclaw_client.dart';
import 'agent_sdk/agent_sdk_client.dart';
import '../database/daos/vessel_dao.dart';

/// Status of an autonomous execution session.
enum AutonomousSessionStatus { running, stopping, stopped, timedOut }

/// State of an autonomous session, emitted via [VesselManager.autonomousSessionStream].
class AutonomousSessionState {
  final String taskId;
  final String toolName;
  final AutonomousSessionStatus status;
  final DateTime startedAt;

  const AutonomousSessionState({
    required this.taskId,
    required this.toolName,
    required this.status,
    required this.startedAt,
  });
}

/// Orchestrates vessel connections, task lifecycle, approval flow, and routing.
///
/// Central service for all vessel operations. Manages:
/// - Connection state for OpenClaw and Agent SDK
/// - Task proposal -> approval -> execution -> result lifecycle (VES-09)
/// - Trust tier classification and autonomous execution (TRUST-01..05)
/// - Kill switch with 5-second stop SLA
/// - Routing decisions (VES-13)
/// - Task persistence via VesselDao
class VesselManager {
  final VesselRouter _router;
  final VesselDao _vesselDao;
  final Logger _log = Logger();

  OpenClawClient? _openClawClient;
  AgentSdkClient? _agentSdkClient;

  TrustTierClassifier? _trustClassifier;
  AuditDao? _auditDao;

  final _taskController = StreamController<VesselTask>.broadcast();
  final Map<String, VesselTask> _activeTasks = {};

  // Autonomous session tracking
  final _autonomousSessionController =
      StreamController<AutonomousSessionState>.broadcast();
  Timer? _maxRuntimeTimer;
  String? _activeAutonomousTaskId;

  /// Max runtime for autonomous sessions (minutes). Default 10.
  int maxRuntimeMinutes = 10;

  VesselManager({
    required VesselRouter router,
    required VesselDao vesselDao,
  })  : _router = router,
        _vesselDao = vesselDao;

  /// Stream of task state changes.
  Stream<VesselTask> get taskUpdates => _taskController.stream;

  /// Stream of autonomous session state changes.
  Stream<AutonomousSessionState> get autonomousSessionStream =>
      _autonomousSessionController.stream;

  /// Whether an autonomous session is currently active.
  bool get hasActiveAutonomousSession => _activeAutonomousTaskId != null;

  /// Current active tasks by ID.
  Map<String, VesselTask> get activeTasks => Map.unmodifiable(_activeTasks);

  /// Public accessor for OpenClaw client (needed for WebSocket, health checks).
  OpenClawClient? get openClawClient => _openClawClient;

  /// Public accessor for Agent SDK client (needed for health checks).
  AgentSdkClient? get agentSdkClient => _agentSdkClient;

  /// Get the output stream for a specific vessel type (VES-10).
  /// Returns null if the vessel is not connected.
  Stream<String>? getOutputStream(VesselType type) {
    final client = _getClient(type);
    return client?.outputStream;
  }

  /// Send terminal input to a connected vessel.
  void sendTerminalInput(VesselType type, String data) {
    final client = _getClient(type);
    if (client is OpenClawClient) {
      client.sendInput(data);
    }
    // Agent SDK doesn't support interactive input currently
  }

  /// Set the trust tier classifier for tier-aware approval flow.
  void setTrustClassifier(TrustTierClassifier classifier) {
    _trustClassifier = classifier;
  }

  /// Set the audit DAO for logging all actions.
  void setAuditDao(AuditDao dao) {
    _auditDao = dao;
  }

  /// Set the OpenClaw client (after user configures connection).
  void setOpenClawClient(OpenClawClient client) {
    _openClawClient = client;
  }

  /// Remove and dispose the OpenClaw client.
  void removeOpenClawClient() {
    _openClawClient?.dispose();
    _openClawClient = null;
  }

  /// Set the Agent SDK client (after user configures connection).
  void setAgentSdkClient(AgentSdkClient client) {
    _agentSdkClient = client;
  }

  /// Get connection status for a vessel type.
  VesselConnection? getConnectionStatus(VesselType type) {
    final client = _getClient(type);
    return client != null
        ? VesselConnection(
            vesselId: client.vesselId,
            vesselName: client.vesselName,
            status: ConnectionStatus.connected,
          )
        : null;
  }

  /// Propose a task with tier-aware approval flow.
  ///
  /// Tier 0 (autonomous): bypasses approval, executes directly with audit trail.
  /// Tier 1 (softApproval): requires single-tap approve.
  /// Tier 2 (hardApproval): requires two-tap confirm.
  Future<VesselTask> proposeTask({
    required String description,
    required String tool,
    required Map<String, dynamic> args,
    VesselType? targetVessel,
    String? sessionKey,
    String? conversationId,
    TrustTier? tierOverride,
  }) async {
    final vesselType = targetVessel ?? _router.routeWithAvailability(
      taskDescription: description,
      openClawAvailable: _openClawClient != null,
      agentSdkAvailable: _agentSdkClient != null,
    );
    final tier = tierOverride ??
        _trustClassifier?.classify(tool) ??
        TrustTier.hardApproval;
    final taskId = const Uuid().v4();

    if (tier == TrustTier.autonomous) {
      // Tier 0: bypass approval, execute directly
      final task = VesselTask.proposed(
        id: taskId,
        description: description,
        targetVessel: vesselType,
        toolName: tool,
        toolArgs: args,
        proposedAt: DateTime.now(),
        sessionKey: sessionKey,
        tier: tier,
      );

      _activeTasks[taskId] = task;
      _taskController.add(task);

      await _vesselDao.insertTask(
        id: taskId,
        conversationId: conversationId,
        vesselType: vesselType.name,
        toolName: tool,
        description: description,
        status: 'executing',
      );

      // Execute directly with audit trail
      _executeAndAudit(task as ProposedTask);

      return task;
    }

    // Tier 1 or 2: require approval
    final task = VesselTask.proposed(
      id: taskId,
      description: description,
      targetVessel: vesselType,
      toolName: tool,
      toolArgs: args,
      proposedAt: DateTime.now(),
      sessionKey: sessionKey,
      tier: tier,
    );

    _activeTasks[taskId] = task;
    _taskController.add(task);

    await _vesselDao.insertTask(
      id: taskId,
      conversationId: conversationId,
      vesselType: vesselType.name,
      toolName: tool,
      description: description,
      status: 'proposed',
    );

    return task;
  }

  /// Approve a proposed task and begin execution (VES-09).
  Future<void> approveTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) throw StateError('Task $taskId not found');

    if (task is! ProposedTask) {
      throw StateError('Task $taskId is not in proposed state');
    }

    final approved = VesselTask.approved(
      id: task.id,
      description: task.description,
      targetVessel: task.targetVessel,
      toolName: task.toolName,
      toolArgs: task.toolArgs,
      approvedAt: DateTime.now(),
      sessionKey: task.sessionKey,
      tier: task.tier,
    );
    _activeTasks[taskId] = approved;
    _taskController.add(approved);
    await _vesselDao.updateTaskStatus(taskId, 'approved');

    await _executeTask(approved as ApprovedTask);
  }

  /// Reject a proposed task (VES-09).
  Future<void> rejectTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) throw StateError('Task $taskId not found');

    final rejected = VesselTask.rejected(
      id: task.id,
      description: task.description,
      targetVessel: task.targetVessel,
      rejectedAt: DateTime.now(),
    );
    _activeTasks[taskId] = rejected;
    _taskController.add(rejected);
    await _vesselDao.updateTaskStatus(taskId, 'rejected');
  }

  /// Retry a failed task.
  Future<void> retryTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) throw StateError('Task $taskId not found');
    if (task is! FailedTask) throw StateError('Task $taskId is not failed');

    final reproposed = VesselTask.proposed(
      id: task.id,
      description: task.description,
      targetVessel: task.targetVessel,
      toolName: '', // Will need original tool info
      toolArgs: {},
      proposedAt: DateTime.now(),
    );
    _activeTasks[taskId] = reproposed;
    _taskController.add(reproposed);
    await _vesselDao.updateTaskStatus(taskId, 'proposed');
  }

  /// Stop the current autonomous session. Must complete within 5 seconds.
  Future<bool> killAutonomousSession({String reason = 'user_kill_switch'}) async {
    final taskId = _activeAutonomousTaskId;
    if (taskId == null) return false;

    final task = _activeTasks[taskId];
    final toolName = _extractToolName(task);
    final tierIndex = task?.tier.index ?? 0;

    _autonomousSessionController.add(AutonomousSessionState(
      taskId: taskId,
      toolName: toolName,
      status: AutonomousSessionStatus.stopping,
      startedAt: DateTime.now(),
    ));

    try {
      final vesselType = task?.targetVessel ?? VesselType.openClaw;
      final client = _getClient(vesselType);
      bool timedOut = false;
      await client?.cancel(taskId).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log.w('Kill switch: graceful cancel timed out, forcing disconnect');
          timedOut = true;
        },
      );
      if (timedOut) {
        // Force disconnect on timeout
        client?.disconnect();
      }
    } catch (e) {
      _log.e('Kill switch error: $e');
    }

    _maxRuntimeTimer?.cancel();
    _maxRuntimeTimer = null;
    _activeAutonomousTaskId = null;

    final finalStatus = reason == 'timeout'
        ? AutonomousSessionStatus.timedOut
        : AutonomousSessionStatus.stopped;

    _autonomousSessionController.add(AutonomousSessionState(
      taskId: taskId,
      toolName: toolName,
      status: finalStatus,
      startedAt: DateTime.now(),
    ));

    // Audit the cancel
    await _auditDao?.logAction(
      actionType: 'vessel_cancel',
      toolName: toolName,
      tier: tierIndex,
      reasoning: reason,
      result: reason == 'timeout' ? 'timeout' : 'cancelled',
      executedAt: DateTime.now(),
      sessionId: taskId,
      vesselType: task?.targetVessel.name,
    );

    return true;
  }

  /// Execute a tier-0 task with full audit trail.
  Future<void> _executeAndAudit(ProposedTask task) async {
    final startTime = DateTime.now();
    _startAutonomousSession(task);

    // Transition to executing
    final executing = VesselTask.executing(
      id: task.id,
      description: task.description,
      targetVessel: task.targetVessel,
      progress: 0.0,
      currentStep: 'Autonomous: ${task.toolName}...',
      startedAt: startTime,
      sessionKey: task.sessionKey,
      tier: task.tier,
    );
    _activeTasks[task.id] = executing;
    _taskController.add(executing);

    try {
      final client = _getClient(task.targetVessel);
      if (client == null) {
        throw VesselException('${task.targetVessel.name} is not connected');
      }

      final result = await client.execute(
        taskId: task.id,
        tool: task.toolName,
        args: task.toolArgs,
        sessionKey: task.sessionKey,
      );

      await _auditDao?.logAction(
        actionType: 'vessel_execute',
        toolName: task.toolName,
        tier: task.tier.index,
        reasoning: task.description,
        result: 'success',
        executedAt: startTime,
        sessionId: task.id,
        vesselType: task.targetVessel.name,
      );

      final completed = VesselTask.completed(
        id: task.id,
        description: task.description,
        targetVessel: task.targetVessel,
        result: result,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
        tier: task.tier,
      );
      _activeTasks[task.id] = completed;
      _taskController.add(completed);
      await _vesselDao.updateTaskStatus(
        task.id,
        'completed',
        resultJson: result.rawResponse.toString(),
      );

      // Evaluate track record for promotion/demotion
      await _evaluateTrackRecord(task.toolName, task.id, task.proposedAt);
    } catch (e) {
      await _auditDao?.logAction(
        actionType: 'vessel_execute',
        toolName: task.toolName,
        tier: task.tier.index,
        reasoning: task.description,
        result: 'failure',
        executedAt: startTime,
        sessionId: task.id,
        vesselType: task.targetVessel.name,
      );

      final failed = VesselTask.failed(
        id: task.id,
        description: task.description,
        targetVessel: task.targetVessel,
        error: e.toString(),
        failedAt: DateTime.now(),
        tier: task.tier,
      );
      _activeTasks[task.id] = failed;
      _taskController.add(failed);
      await _vesselDao.updateTaskStatus(task.id, 'failed', error: e.toString());

      _log.e('Autonomous execution failed: $e');

      // Evaluate track record for demotion on failure
      await _evaluateTrackRecord(task.toolName, task.id, task.proposedAt);
    } finally {
      // Clean up autonomous session
      _maxRuntimeTimer?.cancel();
      _maxRuntimeTimer = null;
      _activeAutonomousTaskId = null;
    }
  }

  void _startAutonomousSession(ProposedTask task) {
    _activeAutonomousTaskId = task.id;
    _autonomousSessionController.add(AutonomousSessionState(
      taskId: task.id,
      toolName: task.toolName,
      status: AutonomousSessionStatus.running,
      startedAt: DateTime.now(),
    ));

    _maxRuntimeTimer = Timer(Duration(minutes: maxRuntimeMinutes), () {
      _log.w('Autonomous session timed out after $maxRuntimeMinutes minutes');
      killAutonomousSession(reason: 'timeout');
    });
  }

  Future<void> _evaluateTrackRecord(
      String toolName, String taskId, DateTime startedAt) async {
    if (_trustClassifier == null) return;
    final tierChange =
        await _trustClassifier!.evaluateTrackRecord(toolName);
    if (tierChange != null) {
      _log.i('Trust tier changed for $toolName: ${tierChange.name}');
      await _trustClassifier!.persistOverrides();
    }
  }

  Future<void> _executeTask(ApprovedTask task) async {
    final startedAt = DateTime.now();

    final executing = VesselTask.executing(
      id: task.id,
      description: task.description,
      targetVessel: task.targetVessel,
      progress: 0.0,
      currentStep: 'Starting ${task.toolName}...',
      startedAt: startedAt,
      sessionKey: task.sessionKey,
      tier: task.tier,
    );
    _activeTasks[task.id] = executing;
    _taskController.add(executing);
    await _vesselDao.updateTaskStatus(task.id, 'executing');

    try {
      final client = _getClient(task.targetVessel);
      if (client == null) {
        throw VesselException('${task.targetVessel.name} is not connected');
      }

      final result = await client.execute(
        taskId: task.id,
        tool: task.toolName,
        args: task.toolArgs,
        sessionKey: task.sessionKey,
      );

      // Audit approved execution
      await _auditDao?.logAction(
        actionType: 'vessel_execute',
        toolName: task.toolName,
        tier: task.tier.index,
        reasoning: task.description,
        result: 'success',
        executedAt: startedAt,
        sessionId: task.id,
        vesselType: task.targetVessel.name,
      );

      final completed = VesselTask.completed(
        id: task.id,
        description: task.description,
        targetVessel: task.targetVessel,
        result: result,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startedAt),
        tier: task.tier,
      );
      _activeTasks[task.id] = completed;
      _taskController.add(completed);
      await _vesselDao.updateTaskStatus(
        task.id,
        'completed',
        resultJson: result.rawResponse.toString(),
      );
    } catch (e) {
      // Audit failed execution
      await _auditDao?.logAction(
        actionType: 'vessel_execute',
        toolName: task.toolName,
        tier: task.tier.index,
        reasoning: task.description,
        result: 'failure',
        executedAt: startedAt,
        sessionId: task.id,
        vesselType: task.targetVessel.name,
      );

      final failed = VesselTask.failed(
        id: task.id,
        description: task.description,
        targetVessel: task.targetVessel,
        error: e.toString(),
        failedAt: DateTime.now(),
        tier: task.tier,
      );
      _activeTasks[task.id] = failed;
      _taskController.add(failed);
      await _vesselDao.updateTaskStatus(task.id, 'failed', error: e.toString());
    }
  }

  /// Extract tool name from any VesselTask variant.
  String _extractToolName(VesselTask? task) {
    if (task == null) return 'unknown';
    return switch (task) {
      ProposedTask(:final toolName) => toolName,
      ApprovedTask(:final toolName) => toolName,
      ExecutingTask() => task.currentStep,
      CompletedTask() => 'completed',
      FailedTask() => 'failed',
      RejectedTask() => 'rejected',
    };
  }

  VesselInterface? _getClient(VesselType type) {
    return switch (type) {
      VesselType.openClaw => _openClawClient,
      VesselType.agentSdk => _agentSdkClient,
    };
  }

  void dispose() {
    _maxRuntimeTimer?.cancel();
    _taskController.close();
    _autonomousSessionController.close();
    _openClawClient?.dispose();
    _agentSdkClient?.dispose();
  }
}
