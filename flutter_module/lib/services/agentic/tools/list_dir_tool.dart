import 'dart:io';
import '../agentic_tool.dart';

/// Lists directory contents as an indented tree.
class ListDirTool extends AgenticTool {
  static const int _defaultMaxDepth = 4;
  static const int _maxEntries = 500;

  @override
  String get name => 'ListDir';

  @override
  String get description =>
      'Lists directory contents as an indented file tree. '
      'Max depth: $_defaultMaxDepth levels. Max entries: $_maxEntries.';

  @override
  Map<String, dynamic> get inputSchema => {
    'properties': {
      'path': {
        'type': 'string',
        'description': 'Directory path to list',
      },
      'max_depth': {
        'type': 'integer',
        'description': 'Maximum directory depth. Default: $_defaultMaxDepth',
      },
    },
    'required': ['path'],
  };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final path = input['path'] as String;
    final maxDepth = (input['max_depth'] as int?) ?? _defaultMaxDepth;

    final dir = Directory(path);
    if (!await dir.exists()) {
      return 'Error: Directory not found: $path';
    }

    final buffer = StringBuffer();
    var count = 0;
    await _walkTree(dir, buffer, '', maxDepth, 0, count, (c) => count = c);

    if (buffer.isEmpty) return '(empty directory)';
    if (count >= _maxEntries) {
      buffer.writeln('... (truncated at $_maxEntries entries)');
    }
    return buffer.toString().trimRight();
  }

  Future<void> _walkTree(
    Directory dir,
    StringBuffer buffer,
    String prefix,
    int maxDepth,
    int currentDepth,
    int count,
    void Function(int) updateCount,
  ) async {
    if (currentDepth >= maxDepth || count >= _maxEntries) return;

    final entities = dir.listSync()
      ..sort((a, b) {
        // Directories first, then alphabetical
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
        return a.path.split('/').last.compareTo(b.path.split('/').last);
      });

    // Filter hidden dirs and common noise
    final filtered = entities.where((e) {
      final name = e.path.split('/').last;
      return !name.startsWith('.') &&
          name != 'node_modules' &&
          name != 'build' &&
          name != '.dart_tool';
    }).toList();

    for (var i = 0; i < filtered.length; i++) {
      if (count >= _maxEntries) return;
      count++;
      updateCount(count);

      final entity = filtered[i];
      final isLast = i == filtered.length - 1;
      final connector = isLast ? '└── ' : '├── ';
      final name = entity.path.split('/').last;

      if (entity is Directory) {
        buffer.writeln('$prefix$connector$name/');
        final childPrefix = prefix + (isLast ? '    ' : '│   ');
        await _walkTree(
          entity, buffer, childPrefix, maxDepth,
          currentDepth + 1, count, updateCount,
        );
      } else {
        buffer.writeln('$prefix$connector$name');
      }
    }
  }
}
