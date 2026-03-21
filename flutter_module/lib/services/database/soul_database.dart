import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'daos/conversation_dao.dart';
import 'daos/decision_dao.dart';
import 'daos/project_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/vessel_dao.dart';
import 'daos/contacts_dao.dart';
import 'daos/calendar_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/briefing_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/api_usage_dao.dart';
import 'daos/intervention_dao.dart';
import 'daos/audit_dao.dart';
import 'daos/mood_dao.dart';
import 'daos/distillation_dao.dart';
import 'daos/project_state_dao.dart';
import 'daos/wal_dao.dart';
import 'daos/metrics_dao.dart';
import 'daos/streak_dao.dart';
import 'daos/achievement_dao.dart';
import 'daos/weekly_review_dao.dart';

part 'soul_database.g.dart';

@DriftDatabase(
  include: {
    'tables/conversations.drift',
    'tables/messages.drift',
    'tables/decisions.drift',
    'tables/projects.drift',
    'tables/profile_traits.drift',
    'tables/vessel_configs.drift',
    'tables/vessel_tasks.drift',
    'tables/vessel_tools.drift',
    'tables/cached_contacts.drift',
    'tables/cached_calendar_events.drift',
    'tables/monitored_notifications.drift',
    'tables/briefings.drift',
    'tables/stuckness_signals.drift',
    'tables/settings.drift',
    'tables/api_usage.drift',
    'tables/intervention_states.drift',
    'tables/audit_log.drift',
    'tables/mood_states.drift',
    'tables/distilled_facts.drift',
    'tables/project_state.drift',
    'tables/agentic_wal.drift',
    'tables/daily_metrics.drift',
    'tables/streaks.drift',
    'tables/achievements.drift',
    'tables/weekly_reviews.drift',
  },
  daos: [
    ConversationDao,
    DecisionDao,
    ProjectDao,
    ProfileDao,
    VesselDao,
    ContactsDao,
    CalendarDao,
    NotificationDao,
    BriefingDao,
    SettingsDao,
    ApiUsageDao,
    InterventionDao,
    AuditDao,
    MoodDao,
    DistillationDao,
    ProjectStateDao,
    WalDao,
    MetricsDao,
    StreakDao,
    AchievementDao,
    WeeklyReviewDao,
  ],
)
class SoulDatabase extends _$SoulDatabase {
  SoulDatabase() : super(_openConnection());

  // For testing: allow injecting a custom executor
  SoulDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(decisions);
          await m.createTable(projects);
          await m.createTable(projectFacts);
          await m.createTable(profileTraits);
          // FTS5 virtual tables and triggers are created by Drift from .drift files
        }
        if (from < 3) {
          await m.createTable(vesselConfigs);
          await m.createTable(vesselTasks);
        }
        if (from < 4) {
          await m.createTable(cachedContacts);
          await m.createTable(cachedCalendarEvents);
          await m.createTable(monitoredNotifications);
          await m.createTable(briefings);
          await m.createTable(stucknessSignals);
        }
        if (from < 5) {
          await m.createTable(settings);
          await m.createTable(apiUsage);
        }
        if (from < 6) {
          await m.createTable(interventionStates);
          // Add status column to decisions table
          await customStatement(
            "ALTER TABLE decisions ADD COLUMN status TEXT NOT NULL DEFAULT 'active'",
          );
        }
        if (from < 7) {
          await m.createTable(auditLog);
        }
        if (from < 8) {
          await m.createTable(moodStates);
        }
        if (from < 9) {
          await m.createTable(distilledFacts);
          await m.createTable(projectState);
          await m.createTable(agenticWal);
          await m.createTable(dailyMetrics);
          await m.createTable(streaks);
          await m.createTable(achievements);
          await m.createTable(weeklyReviews);
        }
        if (from < 10) {
          await customStatement('ALTER TABLE projects ADD COLUMN deadline INTEGER');
          await customStatement('ALTER TABLE projects ADD COLUMN repo_url TEXT');
          await customStatement('ALTER TABLE conversations ADD COLUMN project_id TEXT REFERENCES projects(id)');
          await customStatement('ALTER TABLE daily_metrics ADD COLUMN project_id TEXT');
        }
        if (from < 11) {
          // Rename settings.key to settings.setting_key (was a SQL reserved keyword)
          await customStatement(
            'ALTER TABLE settings RENAME COLUMN key TO setting_key',
          );
        }
        if (from < 12) {
          await m.createTable(vesselTools);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'soul.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
