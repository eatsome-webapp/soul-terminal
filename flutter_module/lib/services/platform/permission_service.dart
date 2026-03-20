import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:notification_listener_service/notification_listener_service.dart'
    as nls;
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Centralized permission management for Phase 4 features.
/// Handles runtime permission requests, status checks, and system settings navigation.
class PermissionService {
  final Logger _logger = Logger();

  /// Check if POST_NOTIFICATIONS permission is granted (Android 13+).
  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request POST_NOTIFICATIONS permission.
  /// Returns true if granted.
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    _logger.i('Notification permission: $status');
    return status.isGranted;
  }

  /// Check if READ_CONTACTS permission is granted.
  Future<bool> isContactsPermissionGranted() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// Request READ_CONTACTS permission.
  /// Returns true if granted.
  Future<bool> requestContactsPermission() async {
    final granted = await FlutterContacts.requestPermission(readonly: true);
    _logger.i('Contacts permission: $granted');
    return granted;
  }

  /// Check if READ_CALENDAR permission is granted.
  /// Uses device_calendar_plus which handles its own permissions.
  Future<bool> isCalendarPermissionGranted() async {
    final status = await DeviceCalendar.instance.hasPermissions();
    return status == CalendarPermissionStatus.granted;
  }

  /// Request READ_CALENDAR permission.
  /// Uses device_calendar_plus native permission dialog.
  /// Returns true if granted.
  Future<bool> requestCalendarPermission() async {
    final status = await DeviceCalendar.instance.requestPermissions();
    _logger.i('Calendar permission: $status');
    return status == CalendarPermissionStatus.granted;
  }

  /// Check if NotificationListenerService is enabled in system settings.
  Future<bool> isNotificationListenerEnabled() async {
    return await nls.NotificationListenerService.isPermissionGranted();
  }

  /// Open system settings for NotificationListenerService.
  /// User must manually enable it — this is an Android restriction.
  /// On Xiaomi/HyperOS a warning screen appears; user must tap through it.
  Future<void> openNotificationListenerSettings() async {
    await nls.NotificationListenerService.requestPermission();
  }

  /// Get a summary of all permission states.
  Future<Map<String, bool>> getAllPermissionStates() async {
    return {
      'notifications': await isNotificationPermissionGranted(),
      'contacts': await isContactsPermissionGranted(),
      'calendar': await isCalendarPermissionGranted(),
      'notificationListener': await isNotificationListenerEnabled(),
    };
  }
}
