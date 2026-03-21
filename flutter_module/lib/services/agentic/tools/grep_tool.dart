import 'dart:io';
import 'package:glob/glob.dart';
import '../agentic_tool.dart';

/// Searches file contents by regex pattern. Pure Dart implementation.
class GrepTool extends AgenticTool {
  static const int _maxResults = 200;

  @override
  String get name => 'Grep';

  @override
  String get description =>
      'Searches file contents for a regex pattern. '
      'Returns matching lines with file paths and line numbers. '
      'Limit: $_maxResults results.';

  @override
  Map<String, dynamic> get inputSchema => {
        'properties': {
          'pattern': {
            'type': 'string',
            'description': 'Regex pattern to search for',
          },
          'path': {
            'type': 'string',
            'description':
                'File or directory to search in. Defaults to project directory.',
          },
          'glob': {
            'type': 'string',
            'description':
                'Glob pattern to filter files (e.g., "*.dart")',
          },
          'case_sensitive': {
            'type': 'boolean',
            'description': 'Case sensitive search. Default: true',
          },
        },
        'required': ['pattern'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final pattern = input['pattern'] as String;
    final searchPath = input['path'] as String? ?? Directory.current.path;
    final fileGlob = input['glob'] as String?;
    final caseSensitive = (input['case_sensitive'] as bool?) ?? true;

    final regex = RegExp(pattern, caseSensitive: caseSensitive);
    final results = <String>[];

    final entity = FileSystemEntity.typeSync(searchPath);
    if (entity == FileSystemEntityType.file) {
      await _searchFile(File(searchPath), regex, results);
    } else if (entity == FileSystemEntityType.directory) {
      final globFilter = fileGlob != null ? Glob(fileGlob) : null;

      await for (final fsEntity
          in Directory(searchPath).list(recursive: true)) {
        if (results.length >= _maxResults) break;
        if (fsEntity is! File) continue;
        if (globFilter != null && !globFilter.matches(fsEntity.path)) continue;
        if (_isBinaryExtension(fsEntity.path)) continue;

        await _searchFile(fsEntity, regex, results);
      }
    } else {
      return 'Error: Path not found: $searchPath';
    }

    if (results.isEmpty) {
      return 'No matches found for pattern "$pattern"';
    }

    final truncated = results.length >= _maxResults
        ? '\n(results truncated at $_maxResults matches)'
        : '';
    return results.join('\n') + truncated;
  }

  Future<void> _searchFile(
      File file, RegExp regex, List<String> results) async {
    if (results.length >= _maxResults) return;
    try {
      final lines = await file.readAsLines();
      for (var i = 0; i < lines.length && results.length < _maxResults; i++) {
        if (regex.hasMatch(lines[i])) {
          results.add('${file.path}:${i + 1}: ${lines[i]}');
        }
      }
    } catch (_) {
      // Skip files that can't be read (binary, permissions, etc.)
    }
  }

  bool _isBinaryExtension(String path) {
    const binaryExts = {
      '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.webp',
      '.pdf', '.zip', '.tar', '.gz', '.7z', '.rar',
      '.exe', '.dll', '.so', '.dylib', '.o', '.a',
      '.mp3', '.mp4', '.avi', '.mov', '.wav', '.flac',
      '.ttf', '.otf', '.woff', '.woff2', '.eot',
      '.class', '.jar', '.dex', '.apk', '.aab',
    };
    final ext =
        path.contains('.') ? '.${path.split('.').last.toLowerCase()}' : '';
    return binaryExts.contains(ext);
  }
}
