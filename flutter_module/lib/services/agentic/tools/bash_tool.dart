import 'dart:async';
import 'dart:io';
import '../agentic_tool.dart';

/// Executes shell commands via Process.run('sh', ['-c', command]).
///
/// Works on Android without root using toybox/toolbox commands.
/// Available: sh, ls, cat, cp, mv, rm, mkdir, grep, find, sed, diff, sort, etc.
/// NOT available without Termux: git, node, python, curl, wget.
class BashTool extends AgenticTool {
  /// Optional working directory override. If null, uses project directory.
  final String? workingDirectory;

  /// Timeout for command execution.
  final Duration timeout;

  BashTool({
    this.workingDirectory,
    this.timeout = const Duration(seconds: 30),
  });

  @override
  String get name => 'Bash';

  @override
  String get description =>
      'Executes a shell command and returns stdout/stderr. '
      'Available commands: sh, ls, cat, cp, mv, rm, mkdir, find, grep, wc, diff, sort, sed, head, tail, etc. '
      'git/node/python/curl are NOT available without Termux.';

  @override
  Map<String, dynamic> get inputSchema => {
    'properties': {
      'command': {
        'type': 'string',
        'description': 'The shell command to execute',
      },
    },
    'required': ['command'],
  };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final command = input['command'] as String;

    if (command.trim().isEmpty) {
      return 'Error: Empty command';
    }

    try {
      final result = await Process.run(
        'sh',
        ['-c', command],
        workingDirectory: workingDirectory,
      ).timeout(timeout);

      final stdout = (result.stdout as String).trim();
      final stderr = (result.stderr as String).trim();

      final buffer = StringBuffer();
      if (stdout.isNotEmpty) {
        buffer.writeln(stdout);
      }
      if (stderr.isNotEmpty) {
        buffer.writeln('[stderr] $stderr');
      }
      if (result.exitCode != 0) {
        buffer.writeln('[exit code: ${result.exitCode}]');
      }

      final output = buffer.toString().trim();
      return output.isEmpty ? '(no output)' : output;
    } on ProcessException catch (e) {
      return 'Error: Process failed: ${e.message}';
    } on TimeoutException {
      return 'Error: Command timed out after ${timeout.inSeconds}s';
    }
  }
}
