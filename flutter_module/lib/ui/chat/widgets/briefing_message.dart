import 'package:flutter/material.dart';

/// Morning briefing displayed as a structured message in chat.
/// UI Spec: BriefingMessage component.
class BriefingMessage extends StatelessWidget {
  final String content;
  final String? calendarSummary;
  final VoidCallback? onDiveIn;

  const BriefingMessage({
    super.key,
    required this.content,
    this.calendarSummary,
    this.onDiveIn,
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
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning! Here\'s your briefing for today.',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(content, style: textTheme.bodyLarge),
          if (calendarSummary != null) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text('Today\'s schedule', style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(calendarSummary!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          Text(
            'Want to dive into any of these?',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
