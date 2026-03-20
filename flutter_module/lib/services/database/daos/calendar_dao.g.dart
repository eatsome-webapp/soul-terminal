// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_dao.dart';

// ignore_for_file: type=lint
mixin _$CalendarDaoMixin on DatabaseAccessor<SoulDatabase> {
  CachedCalendarEvents get cachedCalendarEvents =>
      attachedDatabase.cachedCalendarEvents;
  CalendarDaoManager get managers => CalendarDaoManager(this);
}

class CalendarDaoManager {
  final _$CalendarDaoMixin _db;
  CalendarDaoManager(this._db);
  $CachedCalendarEventsTableManager get cachedCalendarEvents =>
      $CachedCalendarEventsTableManager(
        _db.attachedDatabase,
        _db.cachedCalendarEvents,
      );
}
