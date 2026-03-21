import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../generated/terminal_bridge.g.dart';
import 'ansi_stripper.dart';
import 'command_whitelist.dart';
import 'secret_filter.dart';

part 'soul_awareness_service.g.dart';

enum AwarenessState { idle, executing, waitingForCompletion }

class CommandResult {
  final String command;
  final String output;
  final bool completed;

  CommandResult({
    required this.command,
    required this.output,
    required this.completed,
  });
}

class AwarenessData {
  final AwarenessState state;
  final String? currentCommand;
  final int? awarenessSessionId;

  const AwarenessData({
    this.state = AwarenessState.idle,
    this.currentCommand,
    this.awarenessSessionId,
  });

  AwarenessData copyWith({
    AwarenessState? state,
    String? currentCommand,
    int? awarenessSessionId,
  }) {
    return AwarenessData(
      state: state ?? this.state,
      currentCommand: currentCommand ?? this.currentCommand,
      awarenessSessionId: awarenessSessionId ?? this.awarenessSessionId,
    );
  }
}

@Riverpod(keepAlive: true)
class SoulAwareness extends _$SoulAwareness {
  final _logger = Logger();
  final _outputController = StreamController<String>.broadcast();
  Completer<void>? _commandCompleter;
  final StringBuffer _outputBuffer = StringBuffer();

  @override
  AwarenessData build() {
    ref.onDispose(() {
      _outputController.close();
    });
    return const AwarenessData();
  }

  /// Stream of cleaned terminal output (ANSI-stripped, secret-filtered).
  Stream<String> get outputStream => _outputController.stream;

  /// Initialize the awareness service by creating a dedicated session.
  Future<void> initialize() async {
    final bridge = TerminalBridgeApi();
    final sessionId = await bridge.createAwarenessSession();
    state = state.copyWith(awarenessSessionId: sessionId);
    _logger.i('SOUL awareness session created: $sessionId');
  }

  /// Run a structured command in the awareness session.
  Future<CommandResult> runCommand(String executable, List<String> args) async {
    final sessionId = state.awarenessSessionId;
    if (sessionId == null || sessionId < 0) {
      _logger.e('No awareness session available');
      return CommandResult(
        command: '$executable ${args.join(' ')}',
        output: 'ERROR: No awareness session',
        completed: false,
      );
    }

    // Dart-side double check (Java is primary gate)
    if (CommandWhitelist.isDestructive(executable, args)) {
      final reason = CommandWhitelist.getDestructiveReason(executable, args);
      _logger.w('Destructive command detected: $reason');
    }

    final commandString = '$executable ${args.join(' ')}';
    state = state.copyWith(
      state: AwarenessState.executing,
      currentCommand: commandString,
    );
    _outputBuffer.clear();

    _commandCompleter = Completer<void>();

    try {
      final bridge = TerminalBridgeApi();
      await bridge.runCommand(sessionId, executable, args);
      state = state.copyWith(state: AwarenessState.waitingForCompletion);

      // Wait for onCommandCompleted or timeout
      await _commandCompleter!.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('Command timed out: $commandString');
        },
      );
    } catch (error) {
      _logger.e('Command execution error: $error');
    } finally {
      _commandCompleter = null;
      state = state.copyWith(
        state: AwarenessState.idle,
        currentCommand: null,
      );
    }

    return CommandResult(
      command: commandString,
      output: _outputBuffer.toString(),
      completed: state.state == AwarenessState.idle,
    );
  }

  /// Called from SoulApp when terminal output is received.
  void onTerminalOutput(String rawOutput) {
    final stripped = AnsiStripper.strip(rawOutput);
    final filtered = SecretFilter.filter(stripped);
    _outputController.add(filtered);
    _outputBuffer.writeln(filtered);
  }

  /// Called from SoulApp when a command finishes (OSC 133;D).
  void onCommandCompleted(int sessionId) {
    if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
      _commandCompleter!.complete();
    }
    state = state.copyWith(state: AwarenessState.idle);
  }
}
