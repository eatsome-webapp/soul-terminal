import 'dart:io';
import '../agentic_tool.dart';

/// Reads file contents from the local filesystem.
/// Supports offset and limit parameters for large files.
class ReadTool extends AgenticTool {
  @override
  String get name => 'Read';

  @override
  String get description =>
      'Reads a file from the filesystem. Returns numbered lines. '
      'Use offset and limit for large files.';

  @override
  Map<String, dynamic> get inputSchema => {
        'properties': {
          'file_path': {
            'type': 'string',
            'description': 'Absolute path to the file to read',
          },
          'offset': {
            'type': 'integer',
            'description':
                'Line number to start reading from (1-based). Default: 1',
          },
          'limit': {
            'type': 'integer',
            'description': 'Max number of lines to read. Default: 2000',
          },
        },
        'required': ['file_path'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final filePath = input['file_path'] as String;
    final offset = (input['offset'] as int?) ?? 1;
    final limit = (input['limit'] as int?) ?? 2000;

    final file = File(filePath);
    if (!await file.exists()) {
      return 'Error: File not found: $filePath';
    }

    final lines = await file.readAsLines();
    final startIndex = (offset - 1).clamp(0, lines.length);
    final endIndex = (startIndex + limit).clamp(0, lines.length);

    final buffer = StringBuffer();
    for (var i = startIndex; i < endIndex; i++) {
      buffer.writeln('${(i + 1).toString().padLeft(6)}\t${lines[i]}');
    }

    if (buffer.isEmpty) return '(empty file)';
    return buffer.toString();
  }
}
