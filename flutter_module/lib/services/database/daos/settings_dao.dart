import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'settings_dao.g.dart';

/// Constants for settings keys used across the app.
class SettingsKeys {
  static const String briefingHour = 'briefing_hour';
  static const String briefingMinute = 'briefing_minute';
  static const String crashReportingEnabled = 'crash_reporting_enabled';
  static const String dailyBudgetUsd = 'daily_budget_usd';
  static const String monthlyBudgetUsd = 'monthly_budget_usd';
  static const String budgetWarningEnabled = 'budget_warning_enabled';
  static const String lastDailyBudgetWarningDate = 'last_daily_budget_warning_date';
  static const String lastMonthlyBudgetWarningDate = 'last_monthly_budget_warning_date';

  // Phase 8: Memory Distillation
  static const String lastColdMigrationTimestamp = 'last_cold_migration_timestamp';
  static const String lastMetricsAggregationDate = 'last_metrics_aggregation_date';

  // Phase 8: Weekly Review
  static const String weeklyReviewHour = 'weekly_review_hour';
  static const String weeklyReviewMinute = 'weekly_review_minute';
  static const String weeklyReviewDay = 'weekly_review_day';

  // Phase 8: Distillation
  static const String distillationMessageThreshold = 'distillation_message_threshold';

  // Phase 10: Multi-project
  static const String activeProjectId = 'active_project_id';
  static const String demoInteractionsRemaining = 'demo_interactions_remaining';
  static const String featuresDiscovered = 'features_discovered';

  // Phase 11.1: OpenClaw URL prefix
  static const String openClawUrlPrefix = 'openclaw_url_prefix';

  // Phase 10: Setup Wizard
  static const String setupCompleted = 'setup_completed';
  static const String setupProfile = 'setup_profile'; // claude_code, python, terminal_only

  // Phase 12: Profile Pack System
  static const String interruptedProfileInstall = 'interrupted_profile_install';
  static const String profileUpdateCheckFrequency = 'profile_update_check_frequency'; // daily, weekly, never
  static const String profileUpdateLastCheck = 'profile_update_last_check'; // ISO 8601 timestamp
  static const String profileUpdateAvailable = 'profile_update_available'; // true/false
  static const String profileUpdateRemoteVersion = 'profile_update_remote_version'; // e.g. 2026.03.23-r1
  static const String profileUpdateProfileId = 'profile_update_profile_id'; // e.g. claude-code

  // Phase 11: Vessel onboarding (chronological order of use)
  static String vesselFirstConnected(String vesselId) => 'vessel_first_connected_$vesselId';
  static String vesselBootstrapStep(String vesselId) => 'vessel_bootstrap_step_$vesselId';
  static String vesselBootstrapCompleted(String vesselId) => 'vessel_bootstrap_completed_$vesselId';
}

@DriftAccessor(
  include: {'../tables/settings.drift'},
)
class SettingsDao extends DatabaseAccessor<SoulDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getString(String key) async {
    final row = await (select(settings)
          ..where((s) => s.settingKey.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  Future<int?> getInt(String key) async {
    final value = await getString(key);
    return value != null ? int.tryParse(value) : null;
  }

  Future<double?> getDouble(String key) async {
    final value = await getString(key);
    return value != null ? double.tryParse(value) : null;
  }

  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setString(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        settingKey: key,
        value: value,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> setInt(String key, int value) => setString(key, value.toString());

  Future<void> setDouble(String key, double value) => setString(key, value.toString());

  Future<void> setBool(String key, bool value) => setString(key, value.toString());

  /// Watch a string setting for reactive UI updates.
  Stream<String?> watchString(String key) {
    return (select(settings)..where((s) => s.settingKey.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }
}
