import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'contacts_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/cached_contacts.drift',
  },
)
class ContactsDao extends DatabaseAccessor<SoulDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.db);

  Future<void> upsertContact({
    required String id,
    required String displayName,
    String? phones,
    String? emails,
  }) {
    return into(cachedContacts).insertOnConflictUpdate(
      CachedContactsCompanion.insert(
        id: id,
        displayName: displayName,
        phones: Value(phones),
        emails: Value(emails),
        lastSynced: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<CachedContact?> findByEmail(String email) {
    return (select(cachedContacts)
          ..where((c) => c.emails.like('%$email%'))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<CachedContact>> getAllContacts() {
    return (select(cachedContacts)
          ..orderBy([(c) => OrderingTerm.asc(c.displayName)]))
        .get();
  }

  Future<void> clearAll() => delete(cachedContacts).go();
}
