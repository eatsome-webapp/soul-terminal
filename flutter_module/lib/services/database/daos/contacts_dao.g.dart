// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_dao.dart';

// ignore_for_file: type=lint
mixin _$ContactsDaoMixin on DatabaseAccessor<SoulDatabase> {
  CachedContacts get cachedContacts => attachedDatabase.cachedContacts;
  ContactsDaoManager get managers => ContactsDaoManager(this);
}

class ContactsDaoManager {
  final _$ContactsDaoMixin _db;
  ContactsDaoManager(this._db);
  $CachedContactsTableManager get cachedContacts =>
      $CachedContactsTableManager(_db.attachedDatabase, _db.cachedContacts);
}
