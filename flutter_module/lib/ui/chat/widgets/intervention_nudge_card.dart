import 'package:flutter/material.dart';

import '../../../models/intervention.dart';

/// Inline chat card for intervention nudges with 3 escalation levels.
///
/// - L1: "Ik merk iets op" (observation, low urgency)
/// - L2: "We moeten praten" (confrontation, medium urgency)
/// - L3: "Beslissing nodig" (proposal with countdown, high urgency)
class InterventionNudgeCard extends StatefulWidget {
  final InterventionState intervention;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const InterventionNudgeCard({
    super.key,
    required this.intervention,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  State<InterventionNudgeCard> createState() => _InterventionNudgeCardState();
}

class _InterventionNudgeCardState extends State<InterventionNudgeCard>
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

  int get _level {
    return switch (widget.intervention.level) {
      InterventionLevel.level1Sent => 1,
      InterventionLevel.level2Sent => 2,
      InterventionLevel.level3Sent => 3,
      _ => 1,
    };
  }

  String get _header {
    return switch (_level) {
      1 => 'Ik merk iets op',
      2 => 'We moeten praten',
      3 => 'Beslissing nodig',
      _ => 'Ik merk iets op',
    };
  }

  IconData get _icon {
    return switch (_level) {
      1 => Icons.lightbulb_outline,
      2 => Icons.warning_amber_rounded,
      3 => Icons.timer,
      _ => Icons.lightbulb_outline,
    };
  }

  String get _acceptText {
    return _level == 3 ? 'Akkoord' : 'Aan de slag';
  }

  String get _dismissText {
    return _level == 3 ? 'Ik kies zelf' : 'Later';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label: 'Intervention: $_header. '
            '${widget.intervention.triggerDescription}. '
            'Accept or dismiss.',
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
                    _icon,
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _header,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Body
              Text(
                widget.intervention.triggerDescription,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),

              // L3 countdown text
              if (_level == 3 && widget.intervention.proposedDefault != null) ...[
                const SizedBox(height: 8),
                _buildCountdownText(colorScheme, textTheme),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_level == 3)
                    OutlinedButton(
                      onPressed: widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onTertiaryContainer,
                        side: BorderSide(
                          color: colorScheme.onTertiaryContainer
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(_dismissText),
                    )
                  else
                    TextButton(
                      onPressed: widget.onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onTertiaryContainer,
                      ),
                      child: Text(_dismissText),
                    ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: widget.onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(_acceptText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownText(ColorScheme colorScheme, TextTheme textTheme) {
    final deadline = widget.intervention.proposalDeadlineAt;
    final remaining = deadline != null
        ? deadline.difference(DateTime.now())
        : const Duration(hours: 1);
    final remainingText = remaining.inMinutes > 60
        ? '${remaining.inHours} uur'
        : '${remaining.inMinutes} minuten';

    return Text(
      'Ik kies ${widget.intervention.proposedDefault} over $remainingText tenzij je reageert',
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.tertiary,
      ),
    );
  }
}
