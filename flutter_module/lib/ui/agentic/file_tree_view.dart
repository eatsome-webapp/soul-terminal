import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays a project file tree with indentation.
class FileTreeView extends StatelessWidget {
  final String fileTree;
  final int fileCount;

  const FileTreeView({
    super.key,
    required this.fileTree,
    this.fileCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Project file tree, $fileCount files',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            fileTree,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              height: 1.57,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
