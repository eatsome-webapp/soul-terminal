import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Manages local notification channels and delivery for SOUL.
/// Can be used from both main isolate and background isolate.
class LocalNotificationService {
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Notification IDs
  static const int briefingNotificationId = 1001;
  static const int nudgeNotificationId = 1002;
  static const int alertNotificationId = 1003;
  static const int nlsDisconnectNotificationId = 1004;
  static const int budgetWarningNotificationId = 1005;

  /// Channel IDs
  static const String briefingChannelId = 'soul_briefings';
  static const String nudgeChannelId = 'soul_nudges';
  static const String alertChannelId = 'soul_alerts';
  static const String interventionChannelId = 'soul_interventions';
  static const String interventionChannelName = 'SOUL Interventies';
  static const String interventionChannelDesc =
      'Interventie notificaties wanneer SOUL ingrijpt';
  static const String decisionChannelId = 'soul_decisions';
  static const String decisionChannelName = 'SOUL Beslissingen';
  static const String decisionChannelDesc =
      'Beslissingsvoorstellen met actieknoppen';

  /// Initialize the plugin. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
    _logger.i('LocalNotificationService initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    _logger.i(
        'Notification tapped: ${response.id}, payload: ${response.payload}');
    // Navigation handled by main isolate via payload inspection
  }

  /// Show a morning briefing notification.
  Future<void> showBriefingNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.show(
      briefingNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          briefingChannelId,
          'SOUL Briefings',
          channelDescription: 'Daily briefings from SOUL',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: payload ?? 'briefing',
    );
    _logger.i('Briefing notification shown');
  }

  /// Show a stuckness nudge notification.
  Future<void> showNudgeNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.show(
      nudgeNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          nudgeChannelId,
          'SOUL Nudges',
          channelDescription:
              'Stuckness interventions and suggestions from SOUL',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: payload ?? 'nudge',
    );
    _logger.i('Nudge notification shown');
  }

  /// Show an alert notification (relevant notification from another app).
  Future<void> showAlertNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.show(
      alertNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          alertChannelId,
          'SOUL Alerts',
          channelDescription: 'Relevant notification surfacing from SOUL',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload ?? 'alert',
    );
    _logger.i('Alert notification shown');
  }

  /// Show NLS disconnect notification (after failed rebind attempts).
  Future<void> showNlsDisconnectNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.show(
      nlsDisconnectNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          alertChannelId,
          'SOUL Alerts',
          channelDescription: 'Relevant notification surfacing from SOUL',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload ?? 'nls_settings',
    );
    _logger.i('NLS disconnect notification shown');
  }

  /// Show budget warning notification.
  Future<void> showBudgetWarningNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.show(
      budgetWarningNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          alertChannelId,
          'SOUL Alerts',
          channelDescription: 'Relevant notification surfacing from SOUL',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: payload ?? 'budget_settings',
    );
    _logger.i('Budget warning notification shown');
  }

  /// Send a Level 2 intervention push notification.
  Future<void> showInterventionNotification({
    required String title,
    required String body,
    required int notificationId,
  }) async {
    await initialize();
    await _plugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          interventionChannelId,
          interventionChannelName,
          channelDescription: interventionChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'open_chat',
              'Open SOUL',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
    );
    _logger.i('Intervention notification shown: $title');
  }

  /// Send a Level 3 decision proposal notification with accept/reject buttons.
  Future<void> showDecisionProposalNotification({
    required String title,
    required String body,
    required int notificationId,
    required String interventionId,
  }) async {
    await initialize();
    await _plugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          decisionChannelId,
          decisionChannelName,
          channelDescription: decisionChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          styleInformation: BigTextStyleInformation(body),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'accept_decision_$interventionId',
              'Akkoord',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'reject_decision_$interventionId',
              'Ik kies zelf',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
    );
    _logger.i('Decision proposal notification shown: $title');
  }

  /// Update the foreground notification to show autonomous session status.
  Future<void> showAutonomousSessionNotification({
    required String toolName,
    required String elapsed,
  }) async {
    await initialize();
    await _plugin.show(
      0, // Foreground service notification ID
      'SOUL \u2014 Autonome sessie actief',
      '$toolName wordt uitgevoerd... ($elapsed)',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'soul_foreground',
          'SOUL Background Service',
          channelDescription:
              'Keeps SOUL running for proactive intelligence',
          importance: Importance.low,
          priority: Priority.low,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'stop_autonomous',
              'Stop',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
    );
    _logger.i('Autonomous session notification updated: $toolName');
  }

  /// Cancel a specific notification.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
