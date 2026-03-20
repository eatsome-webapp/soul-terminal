import 'package:flutter/material.dart';

/// Card displaying an open decision/question with urgency timer.
///
/// Timer color shifts: <4h normal, 4-8h warning, >8h error.
/// Shows optional decision options as full-width buttons.
class DecisionTrackerCard extends StatefulWidget {
  final String question;
  final DateTime openSince;
  final String? proposedDefault;
  final List<String>? options;
  final void Function(String option) onDecide;
  final VoidCallback onDefer;

  const DecisionTrackerCard({
    super.key,
    required this.question,
    required this.openSince,
    this.proposedDefault,
    this.options,
    required this.onDecide,
    required this.onDefer,
  });

  @override
  State<DecisionTrackerCard> createState() => _DecisionTrackerCardState();
}

class _DecisionTrackerCardState extends State<DecisionTrackerCard>
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

  Color _getTimerColor(Duration elapsed, ColorScheme colorScheme) {
    if (elapsed.inHours >= 8) return colorScheme.error;
    if (elapsed.inHours >= 4) return colorScheme.tertiary;
    return colorScheme.onTertiaryContainer;
  }

  String _formatDuration(Duration elapsed) {
    if (elapsed.inHours >= 1) return 'Open sinds ${elapsed.inHours} uur';
    return 'Open sinds ${elapsed.inMinutes} minuten';
  }

  IconData _getIcon(Duration elapsed) {
    if (elapsed.inHours >= 4) return Icons.timer;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final elapsed = DateTime.now().difference(widget.openSince);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label: 'Open beslissing: ${widget.question}. '
            '${_formatDuration(elapsed)}.',
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
                    _getIcon(elapsed),
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Open beslissing',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Question
              Text(
                widget.question,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 8),

              // Timer display
              Text(
                _formatDuration(elapsed),
                style: textTheme.bodyMedium?.copyWith(
                  color: _getTimerColor(elapsed, colorScheme),
                ),
              ),

              // Proposed default
              if (widget.proposedDefault != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Voorstel: ${widget.proposedDefault}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Options
              if (widget.options != null && widget.options!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...widget.options!.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => widget.onDecide(option),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onTertiaryContainer,
                          side: BorderSide(
                            color: colorScheme.onTertiaryContainer
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(option),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Defer button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onDefer,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onTertiaryContainer
                        .withValues(alpha: 0.7),
                  ),
                  child: const Text('Later beslissen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
