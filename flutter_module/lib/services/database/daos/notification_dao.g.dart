// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationDaoMixin on DatabaseAccessor<SoulDatabase> {
  MonitoredNotifications get monitoredNotifications =>
      attachedDatabase.monitoredNotifications;
  NotificationDaoManager get managers => NotificationDaoManager(this);
}

class NotificationDaoManager {
  final _$NotificationDaoMixin _db;
  NotificationDaoManager(this._db);
  $MonitoredNotificationsTableManager get monitoredNotifications =>
      $MonitoredNotificationsTableManager(
        _db.attachedDatabase,
        _db.monitoredNotifications,
      );
}
