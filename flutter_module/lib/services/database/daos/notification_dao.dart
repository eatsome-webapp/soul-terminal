import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'notification_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/monitored_notifications.drift',
  },
)
class NotificationDao extends DatabaseAccessor<SoulDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  Future<int> insertNotification({
    required String packageName,
    String? title,
    String? content,
    required int timestamp,
    String? category,
    bool isRelevant = false,
  }) {
    return into(monitoredNotifications).insert(
      MonitoredNotificationsCompanion.insert(
        packageName: packageName,
        title: Value(title),
        content: Value(content),
        timestamp: timestamp,
        category: Value(category),
        isRelevant: Value(isRelevant ? 1 : 0),
      ),
    );
  }

  Future<List<MonitoredNotification>> getUnsurfacedRelevant() {
    return (select(monitoredNotifications)
          ..where((n) => n.isRelevant.equals(1) & n.isSurfaced.equals(0))
          ..orderBy([(n) => OrderingTerm.desc(n.timestamp)]))
        .get();
  }

  Future<void> markAsSurfaced(int id) {
    return (update(monitoredNotifications)
          ..where((n) => n.id.equals(id)))
        .write(const MonitoredNotificationsCompanion(isSurfaced: Value(1)));
  }

  Future<void> clearAll() => delete(monitoredNotifications).go();
}
