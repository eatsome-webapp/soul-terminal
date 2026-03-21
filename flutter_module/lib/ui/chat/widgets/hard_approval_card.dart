import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Two-tap confirmation card for tier 2 (hard approval) vessel actions.
///
/// First tap: button changes to "Weet je het zeker?" with error color.
/// Second tap within 5s: executes. Auto-reverts after 5s timeout.
class HardApprovalCard extends StatefulWidget {
  final String toolName;
  final String description;
  final String vesselName;
  final String impactDescription;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const HardApprovalCard({
    super.key,
    required this.toolName,
    required this.description,
    required this.vesselName,
    required this.impactDescription,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<HardApprovalCard> createState() => _HardApprovalCardState();
}

class _HardApprovalCardState extends State<HardApprovalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _confirmStep = false;
  Timer? _revertTimer;

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
    _revertTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onFirstTap() {
    setState(() => _confirmStep = true);
    _revertTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _confirmStep = false);
    });
  }

  void _onSecondTap() {
    _revertTimer?.cancel();
    widget.onApprove();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label: 'Actie met impact: ${widget.description}. '
            '${widget.impactDescription}. Goedkeuren of weigeren.',
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
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Actie met impact',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
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
                  'Bevestiging vereist',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                backgroundColor: colorScheme.errorContainer,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(height: 8),

              // Impact description
              Text(
                widget.impactDescription,
                style: textTheme.bodyMedium?.copyWith(
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
                  iconColor: colorScheme.onTertiaryContainer
                      .withValues(alpha: 0.7),
                  collapsedIconColor: colorScheme.onTertiaryContainer
                      .withValues(alpha: 0.7),
                  children: [
                    Text(
                      widget.toolName,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        color: colorScheme.onTertiaryContainer,
                      ),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: _confirmStep
                        ? FilledButton(
                            key: const ValueKey('confirm'),
                            onPressed: _onSecondTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                            ),
                            child: const Text('Weet je het zeker?'),
                          )
                        : FilledButton(
                            key: const ValueKey('approve'),
                            onPressed: _onFirstTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: const Text('Goedkeuren'),
                          ),
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
