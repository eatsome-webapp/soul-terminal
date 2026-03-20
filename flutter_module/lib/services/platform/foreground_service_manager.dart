import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:logger/logger.dart';
import 'notification_monitor.dart';
import 'soul_background_handler.dart';
import '../vessels/vessel_manager.dart';

/// Manages the lifecycle of SOUL's foreground service.
/// Handles init, start, stop, restart, and status queries.
///
/// Also handles messages from background isolate (notification actions)
/// and routes them to appropriate services in the main isolate.
class ForegroundServiceManager {
  final Logger _logger = Logger();
  bool _initialized = false;
  bool _dataReceiverRegistered = false;

  /// NotificationMonitor for NLS health checks in the main isolate.
  /// Injected via provider. Health check runs when main isolate receives
  /// heartbeat from background handler (~every 15 min).
  NotificationMonitor? notificationMonitor;

  /// VesselManager for handling kill switch commands from notification actions.
  VesselManager? vesselManager;

  /// Callback for decision accept/reject from notification buttons.
  void Function(String interventionId, bool accepted)? onDecisionResponse;

  /// Initialize foreground task configuration.
  /// Must be called before startService().
  void initialize() {
    if (_initialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'soul_foreground',
        channelName: 'SOUL Background Service',
        channelDescription:
            'Keeps SOUL running for proactive intelligence',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(900000), // 15 min
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
    _logger.i('ForegroundServiceManager initialized');
  }

  /// Start the foreground service.
  /// Returns true if started successfully.
  Future<bool> startService() async {
    if (!_initialized) {
      initialize();
    }

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      _logger.i('Foreground service already running');
      return true;
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'SOUL is active',
      notificationText: 'Monitoring your context for proactive insights',
      callback: startCallback,
    );

    _logger.i('Foreground service start result: $result');
    return result is int && result == 0 || result == true;
  }

  /// Stop the foreground service.
  Future<bool> stopService() async {
    final result = await FlutterForegroundTask.stopService();
    _logger.i('Foreground service stop result: $result');
    return result is int && result == 0 || result == true;
  }

  /// Check if the service is currently running.
  Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// Send a command to the background handler.
  void sendCommand(Map<String, dynamic> data) {
    FlutterForegroundTask.sendDataToTask(data);
  }

  /// Request a briefing generation from the background handler.
  void requestBriefing() {
    sendCommand({
      'command': 'generateBriefing',
      'date': DateTime.now().toIso8601String(),
    });
  }

  /// Request a stuckness check from the background handler.
  void requestStucknessCheck() {
    sendCommand({'command': 'checkStuckness'});
  }

  /// Request an immediate intervention check from the background handler.
  /// Does not wait for the 15-minute interval.
  Future<void> requestInterventionCheck() async {
    FlutterForegroundTask.sendDataToTask({'command': 'check_interventions'});
  }

  /// Register data receiver for messages from background isolate.
  /// Routes notification action buttons (kill switch, decision accept/reject)
  /// to the appropriate services in the main isolate.
  void registerDataReceiver() {
    if (_dataReceiverRegistered) return;

    FlutterForegroundTask.addTaskDataCallback(_handleDataFromTask);
    _dataReceiverRegistered = true;
    _logger.i('Data receiver registered for background isolate messages');
  }

  void _handleDataFromTask(Object data) {
    if (data is! Map) return;

    final type = data['type'] as String?;
    switch (type) {
      case 'heartbeat':
        checkNlsHealth();
        break;
      case 'kill_autonomous_session':
        final reason = data['reason'] as String? ?? 'notification_stop_button';
        _logger.i('Kill switch triggered from notification: $reason');
        vesselManager?.killAutonomousSession(reason: reason);
        break;
      case 'accept_decision':
        final interventionId = data['interventionId'] as String?;
        if (interventionId != null) {
          _logger.i('Decision accepted from notification: $interventionId');
          onDecisionResponse?.call(interventionId, true);
        }
        break;
      case 'reject_decision':
        final interventionId = data['interventionId'] as String?;
        if (interventionId != null) {
          _logger.i('Decision rejected from notification: $interventionId');
          onDecisionResponse?.call(interventionId, false);
        }
        break;
      default:
        _logger.d('Received data from background: $type');
    }
  }

  /// Run NLS health check from the main isolate.
  /// Called on each background handler heartbeat (~every 15 min)
  /// or can be called manually for immediate health verification.
  Future<void> checkNlsHealth() async {
    await notificationMonitor?.checkHealth();
  }
}
