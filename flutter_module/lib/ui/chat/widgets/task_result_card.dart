import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/vessels/models/vessel_task.dart';

/// Card showing completed or failed vessel task results (VES-11).
///
/// For completed tasks: shows summary, collapsible output/diff/screenshot
/// sections, and execution duration.
/// For failed tasks: shows error message with retry button.
class TaskResultCard extends StatelessWidget {
  final VesselTask task;
  final VoidCallback? onRetry;

  const TaskResultCard({
    super.key,
    required this.task,
    this.onRetry,
  });

  bool get _isCompleted => task is CompletedTask;
  bool get _isFailed => task is FailedTask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = _isFailed
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHigh;

    return Semantics(
      label: _isFailed
          ? 'Task failed: ${(task as FailedTask).error}'
          : 'Task complete: ${task.description}',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            _buildHeader(colorScheme, textTheme),
            const SizedBox(height: 12),

            if (_isCompleted) _buildCompletedContent(context),
            if (_isFailed) _buildFailedContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isFailed) {
      return Row(
        children: [
          Icon(
            Icons.error,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Task failed',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Task complete',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedContent(BuildContext context) {
    final completed = task as CompletedTask;
    final result = completed.result;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 14,
      height: 1.57,
      color: colorScheme.onSurface.withValues(alpha: 0.87),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        if (result.summary != null && result.summary!.isNotEmpty)
          Text(
            result.summary!,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),

        // Collapsible sections
        if (result.terminalOutput != null &&
            result.terminalOutput!.isNotEmpty)
          _buildCollapsibleSection(
            context,
            title: 'Output',
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(
                context,
                result.terminalOutput!,
              ),
              child: SelectableText(
                result.terminalOutput!,
                style: monoStyle,
              ),
            ),
          ),

        if (result.codeDiff != null && result.codeDiff!.isNotEmpty)
          _buildCollapsibleSection(
            context,
            title: 'Changes made',
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(
                context,
                result.codeDiff!,
              ),
              child: SelectableText(
                result.codeDiff!,
                style: monoStyle,
              ),
            ),
          ),

        if (result.screenshotBase64 != null &&
            result.screenshotBase64!.isNotEmpty)
          _buildCollapsibleSection(
            context,
            title: 'Screenshot',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(result.screenshotBase64!),
                fit: BoxFit.contain,
              ),
            ),
          ),

        if (result.links.isNotEmpty)
          _buildCollapsibleSection(
            context,
            title: 'Links',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.links.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => _openLink(link),
                    child: Text(
                      link,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Duration
        const SizedBox(height: 8),
        Text(
          _formatDuration(completed.duration),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFailedContent(BuildContext context) {
    final failed = task as FailedTask;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          failed.error,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onErrorContainer,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onErrorContainer,
              side: BorderSide(
                color:
                    colorScheme.onErrorContainer.withValues(alpha: 0.5),
              ),
              minimumSize: const Size(48, 48),
            ),
            child: const Text('Retry task'),
          ),
        ],
      ],
    );
  }

  Widget _buildCollapsibleSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
        expansionAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
        children: [child],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
