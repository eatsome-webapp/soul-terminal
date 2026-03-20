import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/vessels/models/vessel_task.dart';

/// Card shown during vessel task execution (VES-10).
///
/// Displays a progress indicator, current step description,
/// and optional streaming terminal output in mono font.
class TaskProgressCard extends StatelessWidget {
  final ExecutingTask task;
  final String? streamingOutput;

  const TaskProgressCard({
    super.key,
    required this.task,
    this.streamingOutput,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Announce step changes for screen readers
    SemanticsService.announce(
      'Task executing: ${task.currentStep}',
      TextDirection.ltr,
    );

    return Semantics(
      label: 'Task executing: ${task.currentStep}',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Working on it...',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Linear progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress > 0 ? task.progress : null,
                backgroundColor:
                    colorScheme.onSurface.withValues(alpha: 0.12),
                color: colorScheme.primary,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),

            // Current step
            Text(
              task.currentStep,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // Optional streaming output
            if (streamingOutput != null &&
                streamingOutput!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 160),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    streamingOutput!,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      height: 1.57,
                      color: colorScheme.onSurface.withValues(alpha: 0.87),
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
