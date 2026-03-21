import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';

/// Settings screen for agentic engine configuration.
///
/// - Max iterations slider (5-50, step 5)
/// - Cost limit slider ($0.10-$5.00, step $0.10)
/// - Default model selector (Sonnet/Opus)
class AgenticSettings extends ConsumerStatefulWidget {
  const AgenticSettings({super.key});

  @override
  ConsumerState<AgenticSettings> createState() => _AgenticSettingsState();
}

class _AgenticSettingsState extends ConsumerState<AgenticSettings> {
  int _maxIterations = SoulConstants.defaultMaxIterations;
  double _costLimit = SoulConstants.defaultCostLimitUsd;
  bool _useOpus = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Agentic Engine',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        // Max iterations
        ListTile(
          title: const Text('Max iterations per session'),
          subtitle: Text('$_maxIterations steps'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: _maxIterations.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              label: '$_maxIterations',
              onChanged: (value) {
                setState(() => _maxIterations = value.round());
              },
            ),
          ),
        ),
        // Cost limit
        ListTile(
          title: const Text('Session cost limit'),
          subtitle: Text('\$${_costLimit.toStringAsFixed(2)}'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: _costLimit,
              min: 0.10,
              max: 5.0,
              divisions: 49,
              label: '\$${_costLimit.toStringAsFixed(2)}',
              onChanged: (value) {
                setState(
                    () => _costLimit = double.parse(value.toStringAsFixed(2)));
              },
            ),
          ),
        ),
        // Model selection
        ListTile(
          title: const Text('Default model'),
          subtitle: Text(_useOpus
              ? 'Opus (deep reasoning, expensive)'
              : 'Sonnet (fast, cost-effective)'),
          trailing: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Sonnet')),
              ButtonSegment(value: true, label: Text('Opus')),
            ],
            selected: {_useOpus},
            onSelectionChanged: (selected) {
              setState(() => _useOpus = selected.first);
            },
          ),
        ),
      ],
    );
  }
}
