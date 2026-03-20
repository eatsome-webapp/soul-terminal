import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/vessels/models/vessel_task.dart';

/// Inline chat card for vessel task approval (VES-09).
///
/// Shows task description, collapsible details (vessel, tool, session),
/// and approve/reject actions. Uses `tertiaryContainer` background
/// to signal "needs attention".
class TaskProposalCard extends StatefulWidget {
  final ProposedTask task;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TaskProposalCard({
    super.key,
    required this.task,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<TaskProposalCard> createState() => _TaskProposalCardState();
}

class _TaskProposalCardState extends State<TaskProposalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  IconData _iconForTool(String toolName) {
    final lower = toolName.toLowerCase();
    if (lower.contains('exec') ||
        lower.contains('shell') ||
        lower.contains('command')) {
      return Icons.terminal;
    }
    if (lower.contains('browser') || lower.contains('web')) {
      return Icons.language;
    }
    if (lower.contains('read') ||
        lower.contains('write') ||
        lower.contains('file')) {
      return Icons.description;
    }
    return Icons.build;
  }

  String _vesselLabel(VesselType type) {
    return switch (type) {
      VesselType.openClaw => 'OpenClaw',
      VesselType.agentSdk => 'Agent SDK',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 14,
      height: 1.57,
      color: colorScheme.onTertiaryContainer,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label:
            'Vessel task proposal: ${widget.task.description}. Approve or reject.',
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(
                    _iconForTool(widget.task.toolName),
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I want to run a task',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      _vesselLabel(widget.task.targetVessel),
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    backgroundColor: colorScheme.tertiaryContainer,
                    side: BorderSide(
                      color: colorScheme.onTertiaryContainer
                          .withValues(alpha: 0.3),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                widget.task.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 8),

              // Collapsible details
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  title: Text(
                    'Details',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  iconColor:
                      colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
                  collapsedIconColor:
                      colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
                  expansionAnimationStyle: AnimationStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  ),
                  children: [
                    _detailRow(
                      'Vessel',
                      _vesselLabel(widget.task.targetVessel),
                      textTheme,
                      colorScheme,
                    ),
                    const SizedBox(height: 4),
                    _detailRow(
                      'Tool',
                      widget.task.toolName,
                      textTheme,
                      colorScheme,
                      mono: true,
                      monoStyle: monoStyle,
                    ),
                    if (widget.task.sessionKey != null) ...[
                      const SizedBox(height: 4),
                      _detailRow(
                        'Session',
                        widget.task.sessionKey!,
                        textTheme,
                        colorScheme,
                        mono: true,
                        monoStyle: monoStyle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: widget.onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onTertiaryContainer,
                      side: BorderSide(
                        color: colorScheme.onTertiaryContainer
                            .withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size(48, 48),
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: widget.onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(48, 48),
                    ),
                    child: const Text('Approve task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool mono = false,
    TextStyle? monoStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            '$label:',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: mono
                ? monoStyle
                : textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                  ),
          ),
        ),
      ],
    );
  }
}
