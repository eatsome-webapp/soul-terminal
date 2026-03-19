import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/terminal_bridge.g.dart',
  javaOut: '../app/src/main/java/com/termux/bridge/TerminalBridgeApi.java',
  javaOptions: JavaOptions(package: 'com.termux.bridge'),
))

/// Data class for terminal session info.
class SessionInfo {
  SessionInfo({
    required this.id,
    required this.name,
    required this.isRunning,
  });

  final int id;
  final String name;
  final bool isRunning;
}

/// Host API: Flutter calls these methods, Java implements them.
/// Handles terminal command execution and session management.
@HostApi()
abstract class TerminalBridgeApi {
  /// Execute a command in the active terminal session.
  void executeCommand(String command);

  /// Get the last N lines of terminal output.
  String getTerminalOutput(int lines);

  /// Create a new terminal session. Returns the session index.
  int createSession();

  /// List all active terminal sessions.
  List<SessionInfo> listSessions();
}

/// Flutter API: Java calls these methods, Dart implements them.
/// Streams terminal output and session events to Flutter.
@FlutterApi()
abstract class SoulBridgeApi {
  /// Called when terminal output changes (debounced, max 10/sec).
  void onTerminalOutput(String output);

  /// Called when the active session changes.
  void onSessionChanged(SessionInfo info);
}
