import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'calendar_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/cached_calendar_events.drift',
  },
)
class CalendarDao extends DatabaseAccessor<SoulDatabase>
    with _$CalendarDaoMixin {
  CalendarDao(super.db);

  Future<void> upsertEvent({
    required String eventId,
    required String calendarId,
    required String title,
    required int startTime,
    required int endTime,
    String? location,
    String? description,
    String? attendeeEmails,
  }) {
    return into(cachedCalendarEvents).insertOnConflictUpdate(
      CachedCalendarEventsCompanion.insert(
        eventId: eventId,
        calendarId: calendarId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: Value(location),
        description: Value(description),
        attendeeEmails: Value(attendeeEmails),
        lastSynced: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<CachedCalendarEvent>> getEventsForDate(DateTime date) {
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .millisecondsSinceEpoch;
    return (select(cachedCalendarEvents)
          ..where((e) =>
              e.startTime.isBiggerOrEqualValue(startOfDay) &
              e.startTime.isSmallerThanValue(endOfDay))
          ..orderBy([(e) => OrderingTerm.asc(e.startTime)]))
        .get();
  }

  Future<List<CachedCalendarEvent>> getUpcomingEvents({int limit = 20}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(cachedCalendarEvents)
          ..where((e) => e.startTime.isBiggerOrEqualValue(now))
          ..orderBy([(e) => OrderingTerm.asc(e.startTime)])
          ..limit(limit))
        .get();
  }

  Future<void> clearAll() => delete(cachedCalendarEvents).go();
}
