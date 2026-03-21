import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:logger/logger.dart';
import '../database/daos/contacts_dao.dart';

/// Syncs device contacts to local cache and provides lookup functionality.
/// All data stays on-device in Drift SQLite.
class ContactsService {
  final ContactsDao _contactsDao;
  final Logger _logger = Logger();

  ContactsService({required ContactsDao contactsDao}) : _contactsDao = contactsDao;

  /// Sync contacts from device to local cache.
  /// Returns number of contacts synced, or -1 if permission denied.
  Future<int> syncContacts() async {
    final hasPermission = await FlutterContacts.requestPermission(readonly: true);
    if (!hasPermission) {
      _logger.w('Contacts permission denied');
      return -1;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false, // skip photos for performance
    );

    int synced = 0;
    for (final contact in contacts) {
      final phones = contact.phones.map((p) => p.number).toList();
      final emails = contact.emails.map((e) => e.address).toList();

      await _contactsDao.upsertContact(
        id: contact.id,
        displayName: contact.displayName,
        phones: phones.isNotEmpty ? jsonEncode(phones) : null,
        emails: emails.isNotEmpty ? jsonEncode(emails) : null,
      );
      synced++;
    }

    _logger.i('Synced $synced contacts to local cache');
    return synced;
  }

  /// Resolve an email address to a contact display name.
  /// Returns the email itself if no matching contact found.
  Future<String> resolveEmailToName(String email) async {
    final contact = await _contactsDao.findByEmail(email);
    if (contact != null) {
      return contact.displayName;
    }
    return email;
  }

  /// Resolve a list of attendee emails to display names.
  /// Returns a map of email -> display name.
  Future<Map<String, String>> resolveAttendeeNames(List<String> emails) async {
    final result = <String, String>{};
    for (final email in emails) {
      result[email] = await resolveEmailToName(email);
    }
    return result;
  }

  /// Get a contact by email for display in conversations.
  Future<String?> getContactDisplayName(String email) async {
    final contact = await _contactsDao.findByEmail(email);
    return contact?.displayName;
  }

  /// Get all cached contacts.
  Future<List<dynamic>> getAllCachedContacts() async {
    return await _contactsDao.getAllContacts();
  }

  /// Clear the local contacts cache.
  Future<void> clearCache() async {
    await _contactsDao.clearAll();
    _logger.i('Contacts cache cleared');
  }
}
