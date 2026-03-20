import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import '../agentic_tool.dart';

/// Finds files matching a glob pattern in a directory.
class GlobTool extends AgenticTool {
  @override
  String get name => 'Glob';

  @override
  String get description =>
      'Finds files matching a glob pattern (e.g., "**/*.dart", "src/**/*.ts"). '
      'Returns matching file paths sorted by path.';

  @override
  Map<String, dynamic> get inputSchema => {
        'properties': {
          'pattern': {
            'type': 'string',
            'description': 'Glob pattern to match files (e.g., "**/*.dart")',
          },
          'path': {
            'type': 'string',
            'description':
                'Root directory to search in. Defaults to project directory.',
          },
        },
        'required': ['pattern'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final pattern = input['pattern'] as String;
    final rootPath = input['path'] as String?;

    final glob = Glob(pattern);
    final root = rootPath ?? Directory.current.path;

    final entities = glob.listSync(root: root, followLinks: false);
    final paths = entities.whereType<File>().map((e) => e.path).toList()
      ..sort();

    if (paths.isEmpty) {
      return 'No files found matching pattern "$pattern" in $root';
    }

    return paths.join('\n');
  }
}
