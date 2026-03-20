import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// State of a tool step in the agentic session.
enum ToolStepState { running, complete, error }

/// Collapsible card showing one tool execution step in the agentic chat.
///
/// Shows tool icon, name, primary parameter in header.
/// Expandable body shows tool output in monospace font.
/// Running state: primaryContainer background with pulsing indicator.
/// Error state: errorContainer background.
class ToolStepCard extends StatefulWidget {
  final String toolName;
  final Map<String, dynamic> input;
  final String? output;
  final ToolStepState stepState;

  const ToolStepCard({
    super.key,
    required this.toolName,
    required this.input,
    this.output,
    this.stepState = ToolStepState.running,
  });

  @override
  State<ToolStepCard> createState() => _ToolStepCardState();
}

class _ToolStepCardState extends State<ToolStepCard> {
  bool _expanded = false;

  @override
  void didUpdateWidget(ToolStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-collapse when step completes (after showing briefly)
    if (oldWidget.stepState == ToolStepState.running &&
        widget.stepState == ToolStepState.complete) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _expanded = false);
      });
    }
    // Auto-expand on start
    if (widget.stepState == ToolStepState.running) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final containerColor = switch (widget.stepState) {
      ToolStepState.running => colorScheme.primaryContainer,
      ToolStepState.complete => colorScheme.surfaceContainerHigh,
      ToolStepState.error => colorScheme.errorContainer,
    };

    final icon = _toolIcon(widget.toolName);
    final primaryParam = _primaryParam(widget.toolName, widget.input);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.toolName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      primaryParam,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Expandable body
          if (_expanded && widget.output != null)
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: widget.output!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Output copied')),
                );
              },
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.output!,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      height: 1.57,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _toolIcon(String toolName) {
    return switch (toolName) {
      'Read' => Icons.description,
      'Write' => Icons.edit_document,
      'Edit' => Icons.find_replace,
      'Bash' => Icons.terminal,
      'Glob' => Icons.folder_open,
      'Grep' => Icons.search,
      'ListDir' => Icons.account_tree,
      _ => Icons.extension, // MCP tools
    };
  }

  String _primaryParam(String toolName, Map<String, dynamic> input) {
    return switch (toolName) {
      'Read' || 'Write' || 'Edit' => (input['file_path'] as String?) ?? '',
      'Bash' => _truncate((input['command'] as String?) ?? '', 40),
      'Glob' => (input['pattern'] as String?) ?? '',
      'Grep' => (input['pattern'] as String?) ?? '',
      'ListDir' => (input['path'] as String?) ?? '',
      _ => input.keys.firstOrNull ?? '',
    };
  }

  String _truncate(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }
}
