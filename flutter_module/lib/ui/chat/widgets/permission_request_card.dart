import 'package:flutter/material.dart';

/// Inline permission request card in chat when SOUL needs access.
/// UI Spec: PermissionRequestCard component.
class PermissionRequestCard extends StatelessWidget {
  final String permissionName;
  final IconData permissionIcon;
  final String heading;
  final String body;
  final VoidCallback? onGrant;
  final VoidCallback? onDeny;
  final bool isGranted;

  const PermissionRequestCard({
    super.key,
    required this.permissionName,
    required this.permissionIcon,
    required this.heading,
    required this.body,
    this.onGrant,
    this.onDeny,
    this.isGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isGranted
            ? colorScheme.surfaceContainerHigh
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                permissionIcon,
                color: isGranted
                    ? colorScheme.primary
                    : colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: textTheme.titleMedium?.copyWith(
                    color: isGranted
                        ? colorScheme.onSurface
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              if (isGranted)
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: textTheme.bodyLarge?.copyWith(
              color: isGranted
                  ? colorScheme.onSurface
                  : colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All data stays on your phone.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (!isGranted) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDeny,
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onGrant,
                  child: const Text('Grant access'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
