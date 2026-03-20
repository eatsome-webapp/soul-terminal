import 'package:flutter/material.dart';

/// Card displaying a cron job with toggle and delete actions (VES-05).
///
/// Uses Material 3 surface container styling with 16dp radius,
/// mono font for schedule expression per UI-SPEC.
class CronJobCard extends StatelessWidget {
  final String name;
  final String schedule;
  final bool isActive;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CronJobCard({
    super.key,
    required this.name,
    required this.schedule,
    required this.isActive,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: name + schedule
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule,
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ],
                ),
              ),
              // Active/paused toggle
              Switch(
                value: isActive,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _showDeleteConfirmation(context),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete cron job'),
        content: Text(
          "This will permanently remove '$name'. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
