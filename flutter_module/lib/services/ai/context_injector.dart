import 'dart:convert';
import 'package:logger/logger.dart';
import '../database/daos/calendar_dao.dart';
import '../database/daos/notification_dao.dart';
import '../database/daos/profile_dao.dart';
import '../platform/contacts_service.dart';

/// Injects phone-native context (calendar, contacts, notifications) into
/// Claude system prompts. Enriches conversations with real-world awareness.
class ContextInjector {
  final CalendarDao _calendarDao;
  final NotificationDao _notificationDao;
  final ContactsService _contactsService;
  final ProfileDao _profileDao;
  final Logger _logger = Logger();

  ContextInjector({
    required CalendarDao calendarDao,
    required NotificationDao notificationDao,
    required ContactsService contactsService,
    required ProfileDao profileDao,
  })  : _calendarDao = calendarDao,
        _notificationDao = notificationDao,
        _contactsService = contactsService,
        _profileDao = profileDao;

  /// Build the full phone context block for injection into Claude's system prompt.
  /// Returns empty string if no relevant context available.
  Future<String> buildFullContext() async {
    final sections = <String>[];

    final calendarContext = await buildCalendarContext();
    if (calendarContext.isNotEmpty) sections.add(calendarContext);

    final notificationContext = await buildNotificationContext();
    if (notificationContext.isNotEmpty) sections.add(notificationContext);

    if (sections.isEmpty) return '';

    return '## PHONE CONTEXT\n${sections.join('\n\n')}';
  }

  /// Build calendar context with resolved attendee names.
  Future<String> buildCalendarContext() async {
    final now = DateTime.now();
    final todayEvents = await _calendarDao.getEventsForDate(now);
    final tomorrowEvents = await _calendarDao.getEventsForDate(
      now.add(const Duration(days: 1)),
    );

    if (todayEvents.isEmpty && tomorrowEvents.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('### Calendar');

    if (todayEvents.isNotEmpty) {
      buffer.writeln('**Today:**');
      for (final event in todayEvents) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(event.startTime);
        final timeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

        // Resolve attendee names
        String attendeeStr = '';
        if (event.attendeeEmails != null) {
          try {
            final emails = List<String>.from(jsonDecode(event.attendeeEmails!));
            final nameMap = await _contactsService.resolveAttendeeNames(emails);
            final names = nameMap.values.toList();
            if (names.isNotEmpty) {
              attendeeStr = ' with ${names.join(', ')}';
            }
          } catch (_) {
            // JSON decode error, skip attendees
          }
        }

        buffer.writeln('- $timeStr: ${event.title}$attendeeStr');
        if (event.location != null && event.location!.isNotEmpty) {
          buffer.writeln('  Location: ${event.location}');
        }
      }
    }

    if (tomorrowEvents.isNotEmpty) {
      buffer.writeln('**Tomorrow:**');
      for (final event in tomorrowEvents) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(event.startTime);
        final timeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        buffer.writeln('- $timeStr: ${event.title}');
      }
    }

    return buffer.toString().trim();
  }

  /// Build notification context from unsurfaced relevant notifications.
  Future<String> buildNotificationContext() async {
    final notifications = await _notificationDao.getUnsurfacedRelevant();
    if (notifications.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('### Recent Notifications');
    for (final notification in notifications.take(5)) {
      // take max 5 to avoid prompt bloat
      final appName = _getAppName(notification.packageName);
      buffer.writeln('- [$appName] ${notification.title ?? 'No title'}: ${notification.content ?? ''}');
    }

    return buffer.toString().trim();
  }

  /// Build contact context when user references a person.
  Future<String> buildContactContext(String nameOrEmail) async {
    final displayName = await _contactsService.getContactDisplayName(nameOrEmail);
    if (displayName == null) return '';
    return 'Known contact: $displayName';
  }

  /// Detect language from user message text using simple heuristic.
  ///
  /// Checks for Dutch-specific words vs English-specific words.
  /// Returns 'nl' or 'en'. Defaults to 'nl' when scores are tied.
  String detectLanguage(String userMessage) {
    final lower = userMessage.toLowerCase();
    const dutchMarkers = [
      'de', 'het', 'een', 'van', 'voor', 'met', 'dat', 'niet', 'zijn',
      'maar', 'ook', 'nog', 'wel', 'naar', 'dan', 'als', 'moet', 'wil',
      'kan', 'hoe',
    ];
    const englishMarkers = [
      'the', 'and', 'for', 'with', 'that', 'not', 'but', 'also', 'still',
      'should', 'want', 'can', 'how', 'this', 'from', 'have', 'what',
      'which',
    ];

    final words = lower.split(RegExp(r'\s+'));
    int dutchScore = 0;
    int englishScore = 0;
    for (final word in words) {
      if (dutchMarkers.contains(word)) dutchScore++;
      if (englishMarkers.contains(word)) englishScore++;
    }
    return dutchScore >= englishScore ? 'nl' : 'en';
  }

  /// Persist detected language preference in the founder profile.
  Future<void> persistLanguagePreference(String language) async {
    await _profileDao.upsertTrait(
      id: 'preferred_language',
      category: 'preferences',
      traitKey: 'preferred_language',
      traitValue: language,
      confidence: 1.0,
    );
  }

  /// Map package names to human-readable app names.
  String _getAppName(String packageName) {
    const appNames = {
      'com.github.android': 'GitHub',
      'com.slack': 'Slack',
      'org.telegram.messenger': 'Telegram',
      'com.discord': 'Discord',
      'com.google.android.gm': 'Gmail',
      'com.microsoft.teams': 'Teams',
      'com.whatsapp': 'WhatsApp',
    };
    return appNames[packageName] ?? packageName.split('.').last;
  }
}
