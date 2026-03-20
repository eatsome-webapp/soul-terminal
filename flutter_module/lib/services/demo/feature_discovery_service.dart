import 'dart:convert';
import 'package:logger/logger.dart';
import '../database/daos/settings_dao.dart';

/// Tracks which features the user has discovered through natural conversation.
/// No feature gates — everything is available, just not announced until contextually relevant.
class FeatureDiscoveryService {
  final SettingsDao _settingsDao;
  final Logger _logger = Logger();

  /// Feature keys in recommended discovery order
  static const List<String> allFeatures = [
    'chat', // Always discovered (base feature)
    'decisions', // When SOUL logs a decision
    'memory', // When SOUL references past context
    'briefings', // When user discusses scheduling/morning routine
    'vessels', // When user discusses automation/CI/deployment
    'terminal', // When vessels are connected
    'multi_project', // When user mentions multiple projects
  ];

  FeatureDiscoveryService({required SettingsDao settingsDao})
      : _settingsDao = settingsDao;

  /// Get list of already-discovered feature keys
  Future<List<String>> getDiscoveredFeatures() async {
    final json =
        await _settingsDao.getString(SettingsKeys.featuresDiscovered);
    if (json == null || json.isEmpty) return ['chat']; // chat is always discovered
    return List<String>.from(jsonDecode(json));
  }

  /// Mark a feature as discovered
  Future<void> markDiscovered(String featureKey) async {
    final discovered = await getDiscoveredFeatures();
    if (discovered.contains(featureKey)) return;
    discovered.add(featureKey);
    await _settingsDao.setString(
      SettingsKeys.featuresDiscovered,
      jsonEncode(discovered),
    );
    _logger.i('Feature discovered: $featureKey');
  }

  /// Get features not yet discovered (for system prompt hint injection)
  Future<List<String>> getUndiscoveredFeatures() async {
    final discovered = await getDiscoveredFeatures();
    return allFeatures.where((f) => !discovered.contains(f)).toList();
  }

  /// Build system prompt section about feature discovery
  Future<String> buildDiscoveryPrompt() async {
    final undiscovered = await getUndiscoveredFeatures();
    if (undiscovered.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Feature Discovery');
    buffer.writeln('The user has not yet discovered these features. '
        'Mention them NATURALLY when contextually relevant — never force them:');
    for (final feature in undiscovered) {
      buffer.writeln('- $feature');
    }
    return buffer.toString();
  }
}
