import 'package:flutter/material.dart';

import '../../../services/ai/trust_tier_classifier.dart';
import '../../../services/vessels/models/vessel_task.dart';
import 'soft_approval_card.dart';
import 'hard_approval_card.dart';
import 'task_progress_card.dart';
import 'task_result_card.dart';

/// Renders the appropriate vessel task card based on current task state.
///
/// Maps VesselTask sealed class variants to existing UI widgets.
/// ProposedTask renders SoftApprovalCard or HardApprovalCard based on tier.
/// ApprovedTask/ExecutingTask renders TaskProgressCard.
/// CompletedTask/FailedTask renders TaskResultCard.
/// RejectedTask renders nothing.
class VesselTaskCardBuilder extends StatelessWidget {
  final VesselTask task;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRetry;

  const VesselTaskCardBuilder({
    super.key,
    required this.task,
    this.onApprove,
    this.onReject,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (task) {
      ProposedTask(:final tier, :final toolName, :final description, :final targetVessel) =>
          tier == TrustTier.softApproval
          ? SoftApprovalCard(
              toolName: toolName,
              description: description,
              vesselName: targetVessel.name,
              onApprove: onApprove ?? () {},
              onReject: onReject ?? () {},
            )
          : HardApprovalCard(
              toolName: toolName,
              description: description,
              vesselName: targetVessel.name,
              impactDescription: _getImpactDescription(toolName),
              onApprove: onApprove ?? () {},
              onReject: onReject ?? () {},
            ),
      ApprovedTask() => Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Starting task...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ExecutingTask executingTask => TaskProgressCard(task: executingTask),
      CompletedTask completedTask => TaskResultCard(task: completedTask),
      FailedTask failedTask => TaskResultCard(
          task: failedTask,
          onRetry: onRetry,
        ),
      RejectedTask() => const SizedBox.shrink(),
    };
  }

  String _getImpactDescription(String toolName) {
    const impacts = {
      'deploy': 'Dit deployed code naar productie',
      'pr_merge': 'Dit merget een pull request',
      'message_send': 'Dit stuurt een bericht naar externe ontvangers',
    };
    return impacts[toolName] ?? 'Deze actie heeft externe impact';
  }
}
