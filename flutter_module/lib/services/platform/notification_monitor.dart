import 'dart:async';
import 'dart:math';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:logger/logger.dart';
import '../database/daos/notification_dao.dart';
import 'local_notification_service.dart';

/// NLS connection health status for UI and monitoring.
enum NlsHealthStatus { connected, disconnected, reconnecting, unknown }

/// Monitors notifications from other apps via NotificationListenerService.
/// Filters by user-configured allowlist and stores relevant notifications.
/// Includes health monitoring with auto-rebind on disconnect.
class NotificationMonitor {
  final NotificationDao _notificationDao;
  final Logger _logger = Logger();
  StreamSubscription<ServiceNotificationEvent>? _subscription;

  /// Health status stream for UI consumption.
  final _healthController = StreamController<NlsHealthStatus>.broadcast();
  Stream<NlsHealthStatus> get healthStatus => _healthController.stream;
  NlsHealthStatus _currentHealth = NlsHealthStatus.unknown;
  NlsHealthStatus get currentHealthStatus => _currentHealth;

  /// Tracks last notification timestamp for staleness detection.
  DateTime? _lastNotificationTime;

  /// Rebind attempt state.
  int _rebindAttempts = 0;
  static const int _maxRebindBeforeAlert = 3;
  Timer? _rebindTimer;

  /// Callback for injecting system messages into chat.
  void Function(String message)? onDisconnectMessage;

  /// Reference to notification service for alerts.
  LocalNotificationService? notificationService;

  /// Default allowlist of app package names to monitor.
  /// User can customize via settings.
  Set<String> allowedPackages = {
    'com.github.android',
    'io.github.nicehash',
    'com.slack',
    'org.telegram.messenger',
    'com.discord',
    'com.google.android.gm',
    'com.microsoft.teams',
    'com.whatsapp',
  };

  /// Keywords that indicate a notification is relevant/actionable.
  static const _relevanceKeywords = [
    'failed', 'error', 'urgent', 'critical', 'review requested',
    'mentioned', 'assigned', 'blocked', 'deadline', 'breaking',
    'ci run', 'build failed', 'deploy', 'production',
  ];

  NotificationMonitor({required NotificationDao notificationDao})
      : _notificationDao = notificationDao;

  /// Start listening for notifications.
  /// Returns false if permission is not granted.
  Future<bool> startListening() async {
    final isGranted = await NotificationListenerService.isPermissionGranted();
    if (!isGranted) {
      _logger.w('Notification listener permission not granted');
      return false;
    }

    _subscription = NotificationListenerService.notificationsStream.listen(
      _onNotification,
      onError: (error) => _logger.e('Notification stream error: $error'),
    );

    _logger.i('NotificationMonitor started listening');
    return true;
  }

  /// Stop listening for notifications.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _logger.i('NotificationMonitor stopped');
  }

  void _onNotification(ServiceNotificationEvent event) {
    _lastNotificationTime = DateTime.now();

    final packageName = event.packageName;
    if (packageName == null) return;

    // Filter: only process notifications from allowed packages
    if (!allowedPackages.contains(packageName)) return;

    final title = event.title ?? '';
    final content = event.content ?? '';
    final isRelevant = _checkRelevance(title, content);

    _logger.d('Captured notification from $packageName: $title (relevant: $isRelevant)');

    _notificationDao.insertNotification(
      packageName: packageName,
      title: title.isNotEmpty ? title : null,
      content: content.isNotEmpty ? content : null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isRelevant: isRelevant,
    );
  }

  /// Check if notification content contains relevance keywords.
  bool _checkRelevance(String title, String content) {
    final combined = '$title $content'.toLowerCase();
    return _relevanceKeywords.any((keyword) => combined.contains(keyword));
  }

  /// Update the allowlist of monitored packages.
  void updateAllowedPackages(Set<String> packages) {
    allowedPackages = packages;
    _logger.i('Updated allowed packages: ${packages.length} apps');
  }

  /// Check NLS health. Call from foreground service loop (every 5 min).
  Future<void> checkHealth() async {
    final isGranted = await NotificationListenerService.isPermissionGranted();
    if (!isGranted) {
      _updateHealth(NlsHealthStatus.disconnected);
      _onDisconnectDetected();
      return;
    }

    // Check if stream subscription is still active
    if (_subscription == null) {
      _updateHealth(NlsHealthStatus.disconnected);
      _onDisconnectDetected();
      return;
    }

    _updateHealth(NlsHealthStatus.connected);
    _rebindAttempts = 0; // Reset on healthy check
  }

  void _onDisconnectDetected() {
    _logger.w('NLS disconnect detected');

    // Notify chat
    onDisconnectMessage?.call(
      'Ik kan je notificaties niet meer lezen. Ga naar Instellingen > Notificatietoegang om dit te herstellen.',
    );

    // Attempt rebind with exponential backoff
    _attemptRebind();
  }

  void _attemptRebind() {
    if (_rebindAttempts >= _maxRebindBeforeAlert) {
      _logger.w('NLS rebind failed $_rebindAttempts times, sending alert notification');
      notificationService?.showNlsDisconnectNotification(
        title: 'SOUL — Notificatietoegang verloren',
        body: 'Ik kan je notificaties niet meer lezen. Tik om notificatietoegang te herstellen.',
        payload: 'nls_settings',
      );
      return;
    }

    _updateHealth(NlsHealthStatus.reconnecting);

    // Exponential backoff: 5s, 10s, 20s, 40s, 60s (capped)
    final delaySeconds = min(60, 5 * pow(2, _rebindAttempts)).toInt();
    _rebindAttempts++;

    _logger.i('NLS rebind attempt $_rebindAttempts in ${delaySeconds}s');

    _rebindTimer?.cancel();
    _rebindTimer = Timer(Duration(seconds: delaySeconds), () async {
      final success = await startListening();
      if (success) {
        _updateHealth(NlsHealthStatus.connected);
        _rebindAttempts = 0;
        _logger.i('NLS rebind successful');
      } else {
        _attemptRebind(); // Retry with next backoff
      }
    });
  }

  void _updateHealth(NlsHealthStatus status) {
    _currentHealth = status;
    _healthController.add(status);
  }

  /// Dispose resources.
  void dispose() {
    stopListening();
    _rebindTimer?.cancel();
    _healthController.close();
  }
}
