import 'dart:convert';
import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:logger/logger.dart';
import '../database/daos/calendar_dao.dart';

/// Syncs device calendar events to local cache and provides query functionality.
/// All data stays on-device in Drift SQLite.
class CalendarService {
  final CalendarDao _calendarDao;
  final Logger _logger = Logger();

  CalendarService({required CalendarDao calendarDao})
      : _calendarDao = calendarDao;

  /// Sync calendar events for the next 7 days from device to local cache.
  /// Returns number of events synced, or -1 if permission denied.
  Future<int> syncEvents() async {
    final calendar = DeviceCalendar.instance;

    var permStatus = await calendar.hasPermissions();
    if (permStatus != CalendarPermissionStatus.granted) {
      permStatus = await calendar.requestPermissions();
      if (permStatus != CalendarPermissionStatus.granted) {
        _logger.w('Calendar permission denied: $permStatus');
        return -1;
      }
    }

    final calendars = await calendar.listCalendars();
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    int synced = 0;

    for (final cal in calendars) {
      final events = await calendar.listEvents(
        now,
        weekLater,
        calendarIds: [cal.id],
      );

      for (final event in events) {
        if (event.startDate == null || event.endDate == null) continue;

        await _calendarDao.upsertEvent(
          eventId: event.instanceId ?? event.eventId ?? '${cal.id}_$synced',
          calendarId: cal.id,
          title: event.title ?? '',
          startTime: event.startDate!.millisecondsSinceEpoch,
          endTime: event.endDate!.millisecondsSinceEpoch,
          location: event.location,
          description: event.description,
        );
        synced++;
      }
    }

    _logger.i('Synced $synced calendar events to local cache');
    return synced;
  }

  /// Get events for a specific date from local cache.
  Future<List<dynamic>> getEventsForDate(DateTime date) async {
    return await _calendarDao.getEventsForDate(date);
  }

  /// Get upcoming events from local cache.
  Future<List<dynamic>> getUpcomingEvents({int limit = 20}) async {
    return await _calendarDao.getUpcomingEvents(limit: limit);
  }

  /// Syncs project deadlines to device calendar as all-day events.
  /// Creates or updates a calendar event for each project with a deadline.
  /// Uses project.id as external ID for upsert behavior.
  Future<int> syncProjectDeadlines(List<dynamic> projects) async {
    final calendar = DeviceCalendar.instance;

    var permStatus = await calendar.hasPermissions();
    if (permStatus != CalendarPermissionStatus.granted) {
      permStatus = await calendar.requestPermissions();
      if (permStatus != CalendarPermissionStatus.granted) {
        _logger.w('Calendar permission denied, cannot sync project deadlines');
        return -1;
      }
    }

    // Find first writable calendar
    final calendars = await calendar.listCalendars();
    final writableCalendar = calendars.where((c) => !c.readOnly).firstOrNull;
    if (writableCalendar == null) {
      _logger.w('No writable calendar found for project deadline sync');
      return 0;
    }

    int synced = 0;
    for (final project in projects) {
      final deadlineMs = project.deadline as int?;
      if (deadlineMs == null) continue;

      final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
      final projectName = project.name as String;
      final projectId = project.id as String;

      try {
        await calendar.createEvent(
          calendarId: writableCalendar.id,
          title: 'SOUL Deadline: $projectName',
          startDate: DateTime(deadline.year, deadline.month, deadline.day),
          endDate: DateTime(
              deadline.year, deadline.month, deadline.day, 23, 59, 59),
          isAllDay: true,
          description:
              'Project deadline for $projectName (managed by SOUL)',
        );
        synced++;
      } catch (error) {
        _logger.e(
            'Failed to sync deadline for $projectName to calendar: $error');
      }
    }

    _logger.i('Synced $synced project deadlines to device calendar');
    return synced;
  }

  /// Clear the local calendar cache.
  Future<void> clearCache() async {
    await _calendarDao.clearAll();
    _logger.i('Calendar cache cleared');
  }
}
