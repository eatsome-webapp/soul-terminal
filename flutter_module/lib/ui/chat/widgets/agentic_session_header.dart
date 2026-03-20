import 'package:flutter/material.dart';
import 'cost_badge.dart';

/// Status of the agentic session.
enum AgenticSessionStatus { running, complete, error, cancelled }

/// Status bar for agentic session: step count, cost, cancel button.
///
/// Inline in chat (not floating). Shows running/complete state.
class AgenticSessionHeader extends StatelessWidget {
  final AgenticSessionStatus status;
  final int stepCount;
  final double costUsd;
  final VoidCallback? onCancel;

  const AgenticSessionHeader({
    super.key,
    required this.status,
    required this.stepCount,
    required this.costUsd,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status indicator
          _buildStatusIcon(colorScheme),
          const SizedBox(width: 8),
          // Status text
          Expanded(
            child: Text(
              _statusText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Cost badge
          CostBadge(costUsd: costUsd),
          // Cancel button (only when running)
          if (status == AgenticSessionStatus.running && onCancel != null) ...[
            const SizedBox(width: 8),
            Semantics(
              label: 'Cancel current agentic task',
              child: TextButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    return switch (status) {
      AgenticSessionStatus.running => SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      AgenticSessionStatus.complete => Icon(
          Icons.check_circle,
          size: 16,
          color: colorScheme.primary,
        ),
      AgenticSessionStatus.error => Icon(
          Icons.error,
          size: 16,
          color: colorScheme.error,
        ),
      AgenticSessionStatus.cancelled => Icon(
          Icons.cancel,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
    };
  }

  String get _statusText => switch (status) {
        AgenticSessionStatus.running => 'Working... Step $stepCount',
        AgenticSessionStatus.complete => 'Done \u2014 $stepCount steps',
        AgenticSessionStatus.error => 'Error at step $stepCount',
        AgenticSessionStatus.cancelled => 'Cancelled at step $stepCount',
      };
}
