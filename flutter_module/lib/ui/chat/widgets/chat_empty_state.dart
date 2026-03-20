import 'package:flutter/material.dart';

/// Empty state shown when a conversation has no messages.
///
/// Displays a heading, description, and 3 suggestion chips that
/// the user can tap to quickly start a conversation.
class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const ChatEmptyState({
    super.key,
    required this.onSuggestionTap,
  });

  static const _suggestions = [
    'Should I pivot my product?',
    'Review my tech stack',
    'Help me plan this week',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "What's on your mind?",
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me anything about your project -- strategy, tech, design, '
              'marketing, or finance. I think across all of them at once.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () => onSuggestionTap(suggestion),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
