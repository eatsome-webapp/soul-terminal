import 'package:flutter/material.dart';

/// Error card shown when a streaming response fails.
///
/// Supports 4 error types: network, apiKey, rateLimit, generic.
/// Each type has a specific user-friendly message.
class ErrorCard extends StatefulWidget {
  final String errorType;
  final VoidCallback onRetry;

  const ErrorCard({
    super.key,
    required this.errorType,
    required this.onRetry,
  });

  @override
  State<ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<ErrorCard>
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

  String get _errorMessage {
    switch (widget.errorType) {
      case 'network':
        return "Can't reach SOUL's brain right now. Check your connection and try again.";
      case 'apiKey':
        return 'I need your Claude API key to think. Tap to set it up.';
      case 'rateLimit':
        return 'Thinking too fast -- give me a moment.';
      default:
        return 'Something went wrong. Tap to retry.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onErrorContainer,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _errorMessage,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onErrorContainer,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 36),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
