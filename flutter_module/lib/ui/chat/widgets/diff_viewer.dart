import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays a visual diff for Edit tool results.
///
/// Deleted lines: errorContainer background, '- ' prefix.
/// Added lines: green tint background, '+ ' prefix.
/// Context lines: no highlight, onSurfaceVariant text.
class DiffViewer extends StatelessWidget {
  final String oldContent;
  final String newContent;

  const DiffViewer({
    super.key,
    required this.oldContent,
    required this.newContent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final lines = _computeSimpleDiff(oldContent, newContent);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: SelectableText.rich(
          TextSpan(
            children: lines.map((line) {
              Color? bgColor;
              Color textColor = colorScheme.onSurface;
              String prefix = '  ';

              switch (line.type) {
                case _DiffLineType.removed:
                  bgColor = colorScheme.errorContainer;
                  textColor = colorScheme.onErrorContainer;
                  prefix = '- ';
                case _DiffLineType.added:
                  bgColor = brightness == Brightness.dark
                      ? const Color(0xFF1B5E20).withOpacity(0.15)
                      : const Color(0xFFE8F5E9);
                  prefix = '+ ';
                case _DiffLineType.context:
                  textColor = colorScheme.onSurfaceVariant;
              }

              return TextSpan(
                text: '$prefix${line.text}\n',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  height: 1.57,
                  color: textColor,
                  backgroundColor: bgColor,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Simple line-based diff: split by newlines, compare.
  List<_DiffLine> _computeSimpleDiff(String oldText, String newText) {
    final oldLines = oldText.split('\n');
    final newLines = newText.split('\n');
    final result = <_DiffLine>[];

    // Simple approach: show all old lines as removed, all new lines as added
    // For targeted edits (old_string -> new_string), this gives clear output
    for (final line in oldLines) {
      result.add(_DiffLine(_DiffLineType.removed, line));
    }
    for (final line in newLines) {
      result.add(_DiffLine(_DiffLineType.added, line));
    }

    return result;
  }
}

enum _DiffLineType { removed, added, context }

class _DiffLine {
  final _DiffLineType type;
  final String text;
  const _DiffLine(this.type, this.text);
}
