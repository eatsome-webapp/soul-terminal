import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

import '../../services/ai/intervention_config.dart';

/// Settings section for configuring intervention thresholds.
///
/// Sliders for: decision nudge, confrontation, proposal timing,
/// inactivity check, and stuckness detection sensitivity.
class InterventionSettings extends ConsumerStatefulWidget {
  const InterventionSettings({super.key});

  @override
  ConsumerState<InterventionSettings> createState() =>
      _InterventionSettingsState();
}

class _InterventionSettingsState extends ConsumerState<InterventionSettings> {
  double _nudgeHours = 4;
  double _confrontHours = 8;
  double _proposeHours = 24;
  double _inactivityHours = 24;
  double _stucknessSensitivity = 0.6;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final config = ref.read(interventionConfigProvider).value;
      if (config != null) {
        _nudgeHours = config.decisionNudgeHours.toDouble();
        _confrontHours = config.decisionConfrontHours.toDouble();
        _proposeHours = config.decisionProposeHours.toDouble();
        _inactivityHours = config.inactivityThresholdHours.toDouble();
        _stucknessSensitivity = config.stucknessThreshold;
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Interventies', style: textTheme.titleMedium),
        ),
        _buildSliderTile(
          title: 'Beslissing nudge na',
          value: _nudgeHours,
          min: 2,
          max: 24,
          divisions: 5,
          label: '${_nudgeHours.toInt()} uur',
          onChanged: (value) {
            setState(() => _nudgeHours = value);
            _saveConfig();
          },
        ),
        _buildSliderTile(
          title: 'Beslissing confrontatie na',
          value: _confrontHours,
          min: 4,
          max: 48,
          divisions: 5,
          label: '${_confrontHours.toInt()} uur',
          onChanged: (value) {
            setState(() => _confrontHours = value);
            _saveConfig();
          },
        ),
        _buildSliderTile(
          title: 'Beslissing voorstel na',
          value: _proposeHours,
          min: 12,
          max: 72,
          divisions: 4,
          label: '${_proposeHours.toInt()} uur',
          onChanged: (value) {
            setState(() => _proposeHours = value);
            _saveConfig();
          },
        ),
        _buildSliderTile(
          title: 'Inactiviteit check na',
          value: _inactivityHours,
          min: 12,
          max: 48,
          divisions: 3,
          label: '${_inactivityHours.toInt()} uur',
          onChanged: (value) {
            setState(() => _inactivityHours = value);
            _saveConfig();
          },
        ),
        _buildSliderTile(
          title: 'Stuck detectie gevoeligheid',
          value: _stucknessSensitivity,
          min: 0.4,
          max: 0.8,
          divisions: 2,
          label: _stucknessSensitivity <= 0.4
              ? 'Hoog'
              : _stucknessSensitivity >= 0.8
                  ? 'Laag'
                  : 'Normaal',
          onChanged: (value) {
            setState(() => _stucknessSensitivity = value);
            _saveConfig();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton(
            onPressed: _resetDefaults,
            child: const Text('Standaardwaarden herstellen'),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(title),
            trailing: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _resetDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Standaardwaarden herstellen'),
        content: const Text(
          'Alle interventie-instellingen worden teruggezet naar de standaardwaarden. Doorgaan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _nudgeHours = 4;
                _confrontHours = 8;
                _proposeHours = 24;
                _inactivityHours = 24;
                _stucknessSensitivity = 0.6;
              });
              _saveConfig();
              Navigator.pop(ctx);
            },
            child: const Text('Herstellen'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConfig() async {
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
        // Start fresh if YAML corrupted
      }
    }

    // Update intervention section
    final intervention = <String, dynamic>{};
    intervention['decision_delay'] = {
      'nudge_hours': _nudgeHours.toInt(),
      'confront_hours': _confrontHours.toInt(),
      'propose_hours': _proposeHours.toInt(),
    };
    intervention['stuckness'] = {
      'threshold': _stucknessSensitivity,
    };
    intervention['inactivity'] = {
      'threshold_hours': _inactivityHours.toInt(),
    };
    configMap['intervention'] = intervention;

    // Build minimal YAML output
    final buffer = StringBuffer();
    _writeYamlMap(buffer, configMap, 0);
    await file.writeAsString(buffer.toString());

    // Invalidate provider so services pick up new values
    ref.invalidate(interventionConfigProvider);
  }

  void _writeYamlMap(StringBuffer buffer, Map<String, dynamic> map, int indent) {
    final prefix = '  ' * indent;
    for (final entry in map.entries) {
      if (entry.value is Map) {
        buffer.writeln('$prefix${entry.key}:');
        _writeYamlMap(
          buffer,
          Map<String, dynamic>.from(entry.value as Map),
          indent + 1,
        );
      } else if (entry.value is List) {
        buffer.writeln('$prefix${entry.key}:');
        for (final item in entry.value as List) {
          buffer.writeln('$prefix  - $item');
        }
      } else {
        buffer.writeln('$prefix${entry.key}: ${entry.value}');
      }
    }
  }
}
