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

  /// Close a terminal session by index. Switches to adjacent session.
  void closeSession(int id);

  /// Switch to a terminal session by index.
  void switchSession(int id);

  /// Rename a terminal session by index.
  void renameSession(int id, String name);

  /// Run a structured command in a specific session (executable + args, never raw shell string).
  /// Security whitelist is checked before execution.
  void runCommand(int sessionId, String executable, List<String> args);

  /// Send raw text input to a specific terminal session.
  void sendInput(int sessionId, String text);

  /// Show or hide the native terminal overlay.
  /// When visible, terminal covers the Flutter body area (NavigationBar stays visible).
  void setTerminalVisible(bool visible);

  /// Create a dedicated SOUL awareness session. Returns session index.
  int createAwarenessSession();

  /// Write content to a file path (for shell config). Uses Java FileOutputStream — no shell escaping needed.
  void writeShellConfig(String filePath, String content);
}

/// Flutter API: Java calls these methods, Dart implements them.
/// Streams terminal output and session events to Flutter.
@FlutterApi()
abstract class SoulBridgeApi {
  /// Called when terminal output changes (debounced, max 10/sec).
  void onTerminalOutput(String output);

  /// Called when the active session changes.
  void onSessionChanged(SessionInfo info);

  /// Called when the session list changes (add/remove/rename).
  void onSessionListChanged(List<SessionInfo> sessions);

  /// Called when a command finishes (OSC 133 prompt marker detected).
  void onCommandCompleted(int sessionId);

  /// Called when the native terminal visibility changes (e.g. back press hides it).
  void onTerminalVisibilityChanged(bool visible);

  /// Called when a command is not found (OSC 777 soul-cnf escape sequence detected).
  void onCommandNotFound(String command);
}
