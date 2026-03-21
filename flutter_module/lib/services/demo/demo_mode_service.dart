import 'package:logger/logger.dart';

import '../database/daos/settings_dao.dart';
import 'demo_templates.dart';

/// Manages demo mode interactions for new users without an API key.
///
/// Provides 3 pre-loaded strategic analysis responses using templates,
/// tracks remaining interactions via SettingsDao, and signals when
/// the demo is exhausted.
class DemoModeService {
  final SettingsDao _settingsDao;
  final Logger _logger = Logger();

  DemoModeService({required SettingsDao settingsDao})
      : _settingsDao = settingsDao;

  /// Check if demo mode is active (interactions remaining > 0).
  Future<bool> isDemoActive() async {
    final remaining = await _settingsDao.getInt(
      SettingsKeys.demoInteractionsRemaining,
    );
    return (remaining ?? 3) > 0;
  }

  /// Get remaining demo interactions count.
  Future<int> getRemainingInteractions() async {
    return await _settingsDao.getInt(
      SettingsKeys.demoInteractionsRemaining,
    ) ??
        3;
  }

  /// Generate a demo response for the given user input.
  ///
  /// Decrements the remaining counter after each interaction.
  /// Returns null if no demo interactions remaining.
  Future<String?> generateDemoResponse(String userInput) async {
    final remaining = await getRemainingInteractions();
    if (remaining <= 0) return null;

    final interactionNumber = 4 - remaining; // 1, 2, or 3
    final keywords = DemoTemplates.extractKeywords(userInput);

    String template;
    switch (interactionNumber) {
      case 1:
        template = DemoTemplates.strategicAnalysis;
        break;
      case 2:
        template = DemoTemplates.technicalRisks;
        break;
      case 3:
        template = DemoTemplates.milestonePlan;
        break;
      default:
        return null;
    }

    // Fill template placeholders
    var response = template;
    keywords.forEach((key, value) {
      response = response.replaceAll('{{$key}}', value);
    });

    // Decrement remaining
    await _settingsDao.setInt(
      SettingsKeys.demoInteractionsRemaining,
      remaining - 1,
    );

    _logger.i(
      'Demo interaction $interactionNumber served, ${remaining - 1} remaining',
    );
    return response;
  }

  /// Reset demo mode (e.g., for testing).
  Future<void> resetDemo() async {
    await _settingsDao.setInt(SettingsKeys.demoInteractionsRemaining, 3);
  }
}
