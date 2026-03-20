import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/soul_database.dart' show Project;
import '../../../services/monitoring/ci_status.dart';

/// Card displaying a project's name, status, CI health, and deadline proximity.
class ProjectCard extends ConsumerWidget {
  final Project project;
  final CiStatus? ciStatus;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.ciStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with CI health indicator
              Row(
                children: [
                  _buildCiHealthDot(colorScheme),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      project.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (ciStatus != null && ciStatus!.openPrCount > 0)
                    _buildPrBadge(colorScheme, textTheme),
                ],
              ),

              // Description
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  project.description!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // Bottom row: last activity + deadline
              Row(
                children: [
                  // Last activity
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatLastActivity(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Deadline proximity
                  if (project.deadline != null) _buildDeadline(colorScheme, textTheme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCiHealthDot(ColorScheme colorScheme) {
    final Color dotColor;
    switch (ciStatus?.health) {
      case CiHealth.passing:
        dotColor = Colors.green;
        break;
      case CiHealth.failing:
        dotColor = Colors.red;
        break;
      case CiHealth.unknown:
      case null:
        dotColor = Colors.grey;
        break;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPrBadge(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${ciStatus!.openPrCount} PR${ciStatus!.openPrCount == 1 ? '' : 's'}',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildDeadline(ColorScheme colorScheme, TextTheme textTheme) {
    final deadlineDate = DateTime.fromMillisecondsSinceEpoch(project.deadline!);
    final daysLeft = deadlineDate.difference(DateTime.now()).inDays;
    final Color deadlineColor;
    if (daysLeft < 3) {
      deadlineColor = Colors.red;
    } else if (daysLeft < 7) {
      deadlineColor = Colors.orange;
    } else {
      deadlineColor = Colors.green;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag, size: 14, color: deadlineColor),
        const SizedBox(width: 4),
        Text(
          '$daysLeft dagen',
          style: textTheme.labelSmall?.copyWith(color: deadlineColor),
        ),
      ],
    );
  }

  String _formatLastActivity() {
    final lastRun = ciStatus?.lastRunAt;
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(project.updatedAt);
    final referenceTime = lastRun ?? updatedAt;
    final elapsed = DateTime.now().difference(referenceTime);

    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes}m geleden';
    } else if (elapsed.inHours < 24) {
      return '${elapsed.inHours}u geleden';
    } else {
      return '${elapsed.inDays}d geleden';
    }
  }
}
