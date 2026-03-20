import 'package:flutter/material.dart';

/// Card for scope creep and nice-to-have detection.
///
/// Shown when SOUL's ScopeGuard classifies a request as outside
/// the current plan. Offers "Naar backlog" or "Toch doorgaan".
class ScopeGuardCard extends StatefulWidget {
  final String classification; // 'scope_creep' or 'nice_to_have'
  final String request;
  final String reason;
  final String? redirectTo;
  final VoidCallback onBacklog;
  final VoidCallback onOverride;

  const ScopeGuardCard({
    super.key,
    required this.classification,
    required this.request,
    required this.reason,
    this.redirectTo,
    required this.onBacklog,
    required this.onOverride,
  });

  @override
  State<ScopeGuardCard> createState() => _ScopeGuardCardState();
}

class _ScopeGuardCardState extends State<ScopeGuardCard>
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

  bool get _isScopeCreep => widget.classification == 'scope_creep';

  String get _header => _isScopeCreep
      ? 'Scope creep gedetecteerd'
      : 'Nice-to-have gedetecteerd';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label: '$_header: ${widget.reason}. Naar backlog of toch doorgaan.',
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
                    Icons.shield_outlined,
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
              const SizedBox(height: 8),

              // Classification badge
              Chip(
                label: Text(
                  _isScopeCreep ? 'Scope creep' : 'Nice-to-have',
                  style: textTheme.labelSmall?.copyWith(
                    color: _isScopeCreep
                        ? colorScheme.onErrorContainer
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
                backgroundColor: _isScopeCreep
                    ? colorScheme.errorContainer
                    : colorScheme.tertiaryContainer,
                side: _isScopeCreep
                    ? BorderSide.none
                    : BorderSide(
                        color: colorScheme.onTertiaryContainer
                            .withValues(alpha: 0.3),
                      ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(height: 12),

              // Body
              Text(
                'Dit valt buiten je huidige plan. Ik zet het in je backlog.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 8),

              // Reason
              Text(
                widget.reason,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onTertiaryContainer
                      .withValues(alpha: 0.7),
                ),
              ),

              // Redirect text
              if (widget.redirectTo != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Focus op: ${widget.redirectTo}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onOverride,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onTertiaryContainer,
                    ),
                    child: const Text('Toch doorgaan'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      widget.onBacklog();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Toegevoegd aan backlog'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Naar backlog'),
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
