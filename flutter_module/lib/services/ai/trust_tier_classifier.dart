import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import 'intervention_config.dart';
import '../database/daos/audit_dao.dart';

/// Trust tier determines the approval flow for vessel actions.
enum TrustTier {
  autonomous, // tier 0: no approval needed
  softApproval, // tier 1: single tap
  hardApproval, // tier 2: double tap with confirmation
}

/// Classifies vessel tools into trust tiers based on YAML config and track record.
///
/// Default deny: unclassified tools are always hardApproval.
/// Supports runtime promotion/demotion based on success/failure counts.
class TrustTierClassifier {
  final InterventionConfig _config;
  final AuditDao _auditDao;
  final Logger _logger = Logger();

  /// Overrides from tier promotion/demotion. Key: tool name, Value: tier override.
  final Map<String, TrustTier> _tierOverrides = {};

  TrustTierClassifier({
    required InterventionConfig config,
    required AuditDao auditDao,
  })  : _config = config,
        _auditDao = auditDao;

  /// Classify a tool/action into a trust tier.
  /// Returns the effective tier considering config + overrides.
  /// Default deny: unclassified tools are hardApproval.
  TrustTier classify(String toolName) {
    // Check overrides first (from promotion/demotion)
    if (_tierOverrides.containsKey(toolName)) {
      return _tierOverrides[toolName]!;
    }

    // Check YAML config
    if (_config.autonomousTools.contains(toolName)) {
      return TrustTier.autonomous;
    }
    if (_config.softApprovalTools.contains(toolName)) {
      return TrustTier.softApproval;
    }
    if (_config.hardApprovalTools.contains(toolName)) {
      return TrustTier.hardApproval;
    }

    // Default deny: unclassified = hard approval
    _logger
        .w('TrustTier: unclassified tool "$toolName" -> hardApproval (default deny)');
    return TrustTier.hardApproval;
  }

  /// Evaluate track record and potentially promote/demote a tool.
  /// Promotion: 10+ successes with 0 failures -> promote by 1 tier.
  /// Demotion: 3+ failures -> demote by 1 tier.
  Future<TrustTier?> evaluateTrackRecord(String toolName) async {
    final record = await _auditDao.getToolTrackRecord(toolName);
    final currentTier = classify(toolName);

    if (record.failures >= 3 && currentTier != TrustTier.hardApproval) {
      // Demote
      final demoted = TrustTier.values[currentTier.index + 1];
      _tierOverrides[toolName] = demoted;
      _logger.i(
          'TrustTier: demoting "$toolName" to ${demoted.name} (${record.failures} failures)');
      return demoted;
    }

    if (record.successes >= 10 &&
        record.failures == 0 &&
        currentTier != TrustTier.autonomous) {
      // Promote
      final promoted = TrustTier.values[currentTier.index - 1];
      _tierOverrides[toolName] = promoted;
      _logger.i(
          'TrustTier: promoting "$toolName" to ${promoted.name} (${record.successes} successes)');
      return promoted;
    }

    return null; // no change
  }

  /// Override the tier for a specific tool (used by settings UI and promotion/demotion).
  void overrideTier(String toolName, TrustTier tier) {
    _tierOverrides[toolName] = tier;
  }

  /// Get all current tier classifications (config + overrides) for display.
  Map<TrustTier, List<String>> getAllClassifications() {
    final result = <TrustTier, List<String>>{
      TrustTier.autonomous: [..._config.autonomousTools],
      TrustTier.softApproval: [..._config.softApprovalTools],
      TrustTier.hardApproval: [..._config.hardApprovalTools],
    };

    // Apply overrides
    for (final entry in _tierOverrides.entries) {
      for (final tier in TrustTier.values) {
        result[tier]!.remove(entry.key);
      }
      result[entry.value]!.add(entry.key);
    }

    return result;
  }

  /// Persist tier overrides to YAML config file.
  Future<void> persistOverrides() async {
    if (_tierOverrides.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/soul_config.yaml');

    Map<String, dynamic> configMap = {};
    if (await file.exists()) {
      try {
        final yaml = loadYaml(await file.readAsString());
        if (yaml is YamlMap) {
          configMap = Map<String, dynamic>.from(yaml.value);
        }
      } catch (_) {
        // Start fresh if YAML is corrupted
      }
    }

    // Build the trust_tiers section from current classifications
    final classifications = getAllClassifications();
    configMap['trust_tiers'] = {
      'autonomous': classifications[TrustTier.autonomous],
      'soft_approval': classifications[TrustTier.softApproval],
      'hard_approval': classifications[TrustTier.hardApproval],
    };

    // Build minimal YAML for trust_tiers section
    final buffer = StringBuffer();
    for (final entry in configMap.entries) {
      if (entry.key == 'trust_tiers') {
        buffer.writeln('trust_tiers:');
        final tiers = entry.value as Map<String, dynamic>;
        for (final tierEntry in tiers.entries) {
          buffer.writeln('  ${tierEntry.key}:');
          final tools = tierEntry.value as List<String>;
          for (final tool in tools) {
            buffer.writeln('    - $tool');
          }
        }
      } else {
        // Preserve other top-level keys by re-reading original content
        // For simplicity, only update trust_tiers and keep rest intact
      }
    }

    // Read original, replace trust_tiers block, write back
    final original = await file.exists() ? await file.readAsString() : '';
    final trustTiersYaml = buffer.toString().trim();
    final trustTiersRegex = RegExp(
      r'trust_tiers:.*?(?=\n\w|\Z)',
      dotAll: true,
    );
    final updated = trustTiersRegex.hasMatch(original)
        ? original.replaceFirst(trustTiersRegex, trustTiersYaml)
        : '$original\n$trustTiersYaml\n';
    await file.writeAsString(updated);
    _logger.i('TrustTier: persisted ${_tierOverrides.length} overrides to config');
  }
}
