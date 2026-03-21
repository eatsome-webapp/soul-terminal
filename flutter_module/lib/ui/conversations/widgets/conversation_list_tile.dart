import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A single conversation item in the conversation list.
///
/// Shows title, preview text, and relative timestamp.
/// Wrapped in [Dismissible] for swipe-to-delete with confirmation dialog.
class ConversationListTile extends StatelessWidget {
  final String title;
  final String? preview;
  final DateTime updatedAt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationListTile({
    super.key,
    required this.title,
    this.preview,
    required this.updatedAt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey('dismiss-$title-${updatedAt.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (_) => _showDeleteConfirmation(context),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium,
        ),
        subtitle: preview != null && preview!.isNotEmpty
            ? Text(
                preview!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Text(
          _formatRelativeTimestamp(updatedAt),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text(
          'This will permanently remove all messages. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Formats a [DateTime] into a relative timestamp string.
  ///
  /// - Less than 1 minute: "Just now"
  /// - Less than 1 hour: "{n}m ago"
  /// - Less than 24 hours: "{n}h ago"
  /// - Yesterday: "Yesterday"
  /// - Else: "MMM d" format (e.g., "Mar 14")
  String _formatRelativeTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (dateOnly == yesterday) {
      return 'Yesterday';
    }

    return DateFormat('MMM d').format(dateTime);
  }
}
