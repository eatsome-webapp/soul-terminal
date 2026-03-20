import 'package:flutter/material.dart';

/// Row of action buttons (copy, share) for assistant messages.
///
/// Appears with a fade-in animation after streaming completes.
/// Parent controls visibility via [AnimatedOpacity].
class MessageActionRow extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const MessageActionRow({
    super.key,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onCopy,
            icon: Icon(
              Icons.copy_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Copy',
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onShare,
            icon: Icon(
              Icons.share_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Share',
          ),
        ),
      ],
    );
  }
}
