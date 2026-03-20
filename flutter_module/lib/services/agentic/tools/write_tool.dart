import 'dart:io';
import '../agentic_tool.dart';

/// Writes content to a file, creating parent directories if needed.
class WriteTool extends AgenticTool {
  @override
  String get name => 'Write';

  @override
  String get description =>
      'Writes content to a file. Creates the file and parent directories if they do not exist. '
      'Overwrites existing content.';

  @override
  Map<String, dynamic> get inputSchema => {
        'properties': {
          'file_path': {
            'type': 'string',
            'description': 'Absolute path to the file to write',
          },
          'content': {
            'type': 'string',
            'description': 'The content to write to the file',
          },
        },
        'required': ['file_path', 'content'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final filePath = input['file_path'] as String;
    final content = input['content'] as String;

    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);

    final lineCount = content.split('\n').length;
    return 'Successfully wrote $lineCount lines to $filePath';
  }
}
