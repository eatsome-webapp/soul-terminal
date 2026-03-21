import 'package:flutter/material.dart';

/// Inline badge showing running session cost.
class CostBadge extends StatelessWidget {
  final double costUsd;

  const CostBadge({super.key, required this.costUsd});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Session cost: ${costUsd.toStringAsFixed(2)} dollars',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Text(
          '\$${costUsd.toStringAsFixed(2)}',
          key: ValueKey(costUsd.toStringAsFixed(2)),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
