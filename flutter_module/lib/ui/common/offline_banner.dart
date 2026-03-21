import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';

/// Persistent banner shown when the device is offline.
///
/// Watches [isOfflineProvider] and shows/hides with a 250ms animation.
/// Displays "You're offline. Browsing saved conversations."
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: isOffline
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              color: colorScheme.surfaceContainerHigh,
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You're offline. Browsing saved conversations.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
