import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet for selecting a project directory.
///
/// Allows browsing the filesystem and selecting a root directory
/// for agentic operations.
class ProjectPickerSheet extends StatefulWidget {
  final String initialPath;
  final ValueChanged<String> onSelected;

  const ProjectPickerSheet({
    super.key,
    this.initialPath = '/storage/emulated/0',
    required this.onSelected,
  });

  @override
  State<ProjectPickerSheet> createState() => _ProjectPickerSheetState();

  /// Show the project picker as a modal bottom sheet.
  static Future<String?> show(BuildContext context, {String? initialPath}) {
    return showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ProjectPickerSheet(
          initialPath: initialPath ?? '/storage/emulated/0',
          onSelected: (path) => Navigator.of(context).pop(path),
        ),
      ),
    );
  }
}

class _ProjectPickerSheetState extends State<ProjectPickerSheet> {
  late String _currentPath;
  List<FileSystemEntity> _entries = [];

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
    _loadDirectory();
  }

  void _loadDirectory() {
    final dir = Directory(_currentPath);
    if (!dir.existsSync()) return;

    setState(() {
      _entries = dir.listSync()
        ..sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
          return a.path.split('/').last.compareTo(b.path.split('/').last);
        });
      // Filter hidden entries
      _entries = _entries.where((entity) {
        final name = entity.path.split('/').last;
        return !name.startsWith('.');
      }).toList();
    });
  }

  void _navigateTo(String path) {
    _currentPath = path;
    _loadDirectory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Select project',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // Breadcrumb
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (_currentPath != '/')
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {
                    final parent = Directory(_currentPath).parent.path;
                    _navigateTo(parent);
                  },
                  tooltip: 'Parent directory',
                ),
              Expanded(
                child: Text(
                  _currentPath,
                  style: GoogleFonts.jetBrainsMono(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // Directory listing
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entity = _entries[index];
              final name = entity.path.split('/').last;
              final isDir = entity is Directory;

              return ListTile(
                leading: Icon(
                  isDir ? Icons.folder : Icons.insert_drive_file,
                  color: isDir
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                title: Text(name),
                onTap: isDir ? () => _navigateTo(entity.path) : null,
              );
            },
          ),
        ),
        // Select button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => widget.onSelected(_currentPath),
              icon: const Icon(Icons.check),
              label: const Text('Use this directory'),
            ),
          ),
        ),
      ],
    );
  }
}
