import 'package:flutter/material.dart';

/// Proactive nudge card when SOUL detects the user is stuck.
/// UI Spec: NudgeCard component.
class NudgeCard extends StatelessWidget {
  final String topic;
  final String message;
  final VoidCallback? onAccept;
  final VoidCallback? onDismiss;

  const NudgeCard({
    super.key,
    required this.topic,
    required this.message,
    this.onAccept,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: colorScheme.onTertiaryContainer),
              const SizedBox(width: 8),
              Text(
                'I noticed something',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Dismiss',
                  style: TextStyle(color: colorScheme.onTertiaryContainer),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onAccept,
                child: const Text('Let\'s work on this'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
