import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single-tap approval card for tier 1 (soft approval) vessel actions.
///
/// Shows tool name, description, vessel chip, and single-tap
/// "Goedkeuren" button. Lower friction than [HardApprovalCard].
class SoftApprovalCard extends StatefulWidget {
  final String toolName;
  final String description;
  final String vesselName;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const SoftApprovalCard({
    super.key,
    required this.toolName,
    required this.description,
    required this.vesselName,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<SoftApprovalCard> createState() => _SoftApprovalCardState();
}

class _SoftApprovalCardState extends State<SoftApprovalCard>
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 14,
      color: colorScheme.onTertiaryContainer,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label: 'Actie uitvoeren: ${widget.description}. Goedkeuren of weigeren.',
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
                    Icons.play_circle_outline,
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Actie uitvoeren',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      widget.vesselName,
                      style: textTheme.labelSmall?.copyWith(
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
                widget.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 8),

              // Tier badge
              Chip(
                label: Text(
                  'Soft approval',
                  style: textTheme.labelSmall?.copyWith(
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
                  iconColor: colorScheme.onTertiaryContainer
                      .withValues(alpha: 0.7),
                  collapsedIconColor: colorScheme.onTertiaryContainer
                      .withValues(alpha: 0.7),
                  children: [
                    Text(
                      widget.toolName,
                      style: monoStyle,
                    ),
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
                    ),
                    child: const Text('Weigeren'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: widget.onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Goedkeuren'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
