import 'package:logger/logger.dart';
import '../../core/constants.dart';
import '../database/daos/api_usage_dao.dart';
import '../database/daos/settings_dao.dart';
import '../platform/local_notification_service.dart';

/// Tracks API usage costs and triggers budget warnings.
class CostTracker {
  final ApiUsageDao _apiUsageDao;
  final SettingsDao _settingsDao;
  final LocalNotificationService _notificationService;
  final Logger _logger = Logger();

  CostTracker({
    required ApiUsageDao apiUsageDao,
    required SettingsDao settingsDao,
    required LocalNotificationService notificationService,
  })  : _apiUsageDao = apiUsageDao,
        _settingsDao = settingsDao,
        _notificationService = notificationService;

  /// Calculate cost for a single API call based on model and token usage.
  double calculateCost({
    required String model,
    required int inputTokens,
    required int outputTokens,
    int cacheCreationTokens = 0,
    int cacheReadTokens = 0,
  }) {
    double inputRate;
    double outputRate;

    if (model.contains('opus')) {
      inputRate = SoulConstants.opusInputCostPerMTok;
      outputRate = SoulConstants.opusOutputCostPerMTok;
    } else if (model.contains('haiku')) {
      inputRate = SoulConstants.haikuInputCostPerMTok;
      outputRate = SoulConstants.haikuOutputCostPerMTok;
    } else {
      // Default to Sonnet pricing
      inputRate = SoulConstants.sonnetInputCostPerMTok;
      outputRate = SoulConstants.sonnetOutputCostPerMTok;
    }

    // Regular input tokens (excluding cached)
    final regularInputCost = (inputTokens / 1000000) * inputRate;
    final outputCost = (outputTokens / 1000000) * outputRate;

    // Cache tokens: creation costs 25% more, reads cost 90% less
    final cacheCreationCost =
        (cacheCreationTokens / 1000000) * inputRate * SoulConstants.cacheCreationMultiplier;
    final cacheReadCost =
        (cacheReadTokens / 1000000) * inputRate * SoulConstants.cacheReadMultiplier;

    return regularInputCost + outputCost + cacheCreationCost + cacheReadCost;
  }

  /// Record API usage and check budget thresholds.
  Future<void> recordUsage({
    int? conversationId,
    required String model,
    required int inputTokens,
    required int outputTokens,
    int cacheCreationTokens = 0,
    int cacheReadTokens = 0,
  }) async {
    final cost = calculateCost(
      model: model,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      cacheCreationTokens: cacheCreationTokens,
      cacheReadTokens: cacheReadTokens,
    );

    await _apiUsageDao.insertUsage(
      conversationId: conversationId,
      model: model,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      cacheCreationTokens: cacheCreationTokens,
      cacheReadTokens: cacheReadTokens,
      costUsd: cost,
    );

    _logger.d(
      'API usage recorded: $model, '
      'input=$inputTokens, output=$outputTokens, '
      'cacheCreate=$cacheCreationTokens, cacheRead=$cacheReadTokens, '
      'cost=\$${cost.toStringAsFixed(4)}',
    );

    // Check budget thresholds
    await _checkBudgetThresholds();
  }

  /// Check daily and monthly budget thresholds.
  Future<void> _checkBudgetThresholds() async {
    final warningEnabled =
        await _settingsDao.getBool(SettingsKeys.budgetWarningEnabled) ?? true;
    if (!warningEnabled) return;

    // Daily budget check
    final dailyBudget =
        await _settingsDao.getDouble(SettingsKeys.dailyBudgetUsd) ?? 5.0;
    final todayCost = await _apiUsageDao.getTodayCost();

    if (todayCost >= dailyBudget) {
      await _checkAndSendDailyWarning(dailyBudget);
    }

    // Monthly budget check
    final monthlyBudget =
        await _settingsDao.getDouble(SettingsKeys.monthlyBudgetUsd) ?? 50.0;
    final monthCost = await _apiUsageDao.getMonthCost();

    if (monthCost >= monthlyBudget) {
      await _checkAndSendMonthlyWarning(monthlyBudget);
    }
  }

  Future<void> _checkAndSendDailyWarning(double budget) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final lastWarned = await _settingsDao.getString(
      SettingsKeys.lastDailyBudgetWarningDate,
    );

    if (lastWarned == todayStr) return; // Already warned today

    await _settingsDao.setString(
      SettingsKeys.lastDailyBudgetWarningDate,
      todayStr,
    );

    await _notificationService.showBudgetWarningNotification(
      title: 'SOUL — Budgetwaarschuwing',
      body:
          'Je dagbudget van \$${budget.toStringAsFixed(2)} is bereikt. SOUL blijft werken — je bent zelf verantwoordelijk voor de kosten.',
      payload: 'budget_settings',
    );

    _logger.i('Daily budget warning sent: \$${budget.toStringAsFixed(2)}');
  }

  Future<void> _checkAndSendMonthlyWarning(double budget) async {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final lastWarned = await _settingsDao.getString(
      SettingsKeys.lastMonthlyBudgetWarningDate,
    );

    if (lastWarned == monthStr) return; // Already warned this month

    await _settingsDao.setString(
      SettingsKeys.lastMonthlyBudgetWarningDate,
      monthStr,
    );

    await _notificationService.showBudgetWarningNotification(
      title: 'SOUL — Budgetwaarschuwing',
      body: 'Je maandbudget van \$${budget.toStringAsFixed(2)} is bereikt.',
      payload: 'budget_settings',
    );

    _logger.i('Monthly budget warning sent: \$${budget.toStringAsFixed(2)}');
  }

  /// Get current cost summary for display.
  Future<CostSummary> getCostSummary() async {
    final todayCost = await _apiUsageDao.getTodayCost();
    final monthCost = await _apiUsageDao.getMonthCost();
    final dailyBudget =
        await _settingsDao.getDouble(SettingsKeys.dailyBudgetUsd) ?? 5.0;
    final monthlyBudget =
        await _settingsDao.getDouble(SettingsKeys.monthlyBudgetUsd) ?? 50.0;

    return CostSummary(
      todayCost: todayCost,
      monthCost: monthCost,
      dailyBudget: dailyBudget,
      monthlyBudget: monthlyBudget,
    );
  }
}

/// Summary of current costs for UI display.
class CostSummary {
  final double todayCost;
  final double monthCost;
  final double dailyBudget;
  final double monthlyBudget;

  const CostSummary({
    required this.todayCost,
    required this.monthCost,
    required this.dailyBudget,
    required this.monthlyBudget,
  });

  bool get isDailyBudgetExceeded => todayCost >= dailyBudget;
  bool get isMonthlyBudgetExceeded => monthCost >= monthlyBudget;
}
