import 'dart:io';
import '../agentic_tool.dart';

/// Performs exact string replacement in files.
/// old_string must be unique in the file unless replace_all is true.
class EditTool extends AgenticTool {
  @override
  String get name => 'Edit';

  @override
  String get description =>
      'Performs exact string replacement in a file. '
      'old_string must be unique in the file (or use replace_all). '
      'old_string and new_string must be different.';

  @override
  Map<String, dynamic> get inputSchema => {
        'properties': {
          'file_path': {
            'type': 'string',
            'description': 'Absolute path to the file to edit',
          },
          'old_string': {
            'type': 'string',
            'description': 'The exact text to find and replace',
          },
          'new_string': {
            'type': 'string',
            'description': 'The replacement text',
          },
          'replace_all': {
            'type': 'boolean',
            'description': 'Replace all occurrences. Default: false',
          },
        },
        'required': ['file_path', 'old_string', 'new_string'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final filePath = input['file_path'] as String;
    final oldString = input['old_string'] as String;
    final newString = input['new_string'] as String;
    final replaceAll = (input['replace_all'] as bool?) ?? false;

    if (oldString == newString) {
      return 'Error: old_string and new_string are identical';
    }

    final file = File(filePath);
    if (!await file.exists()) {
      return 'Error: File not found: $filePath';
    }

    final content = await file.readAsString();
    final count = content.split(oldString).length - 1;

    if (count == 0) {
      return 'Error: old_string not found in $filePath';
    }

    if (!replaceAll && count > 1) {
      return 'Error: old_string found $count times in $filePath. '
          'Provide more context to make it unique, or set replace_all to true.';
    }

    final newContent = replaceAll
        ? content.replaceAll(oldString, newString)
        : content.replaceFirst(oldString, newString);

    await file.writeAsString(newContent);
    return 'Successfully replaced ${replaceAll ? "$count occurrences" : "1 occurrence"} in $filePath';
  }
}
