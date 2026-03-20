import 'models/vessel_connection.dart';
import 'models/vessel_result.dart';

/// Abstract interface that all vessels (OpenClaw, Agent SDK) implement.
///
/// Provides connection management, task execution, and progress streaming.
/// Implementations handle HTTP communication with their specific backend.
abstract class VesselInterface {
  /// Unique identifier for this vessel type.
  String get vesselId;

  /// Human-readable name.
  String get vesselName;

  /// Connect to the vessel backend. Returns connection state.
  Future<VesselConnection> connect();

  /// Disconnect and clean up resources.
  Future<void> disconnect();

  /// Stream of connection status changes.
  Stream<VesselConnection> get connectionStatus;

  /// Stream of raw output data for terminal display (VES-10, VES-12).
  /// Emits strings that should be written directly to the terminal widget.
  Stream<String> get outputStream;

  /// Check if the vessel backend is reachable.
  /// Returns null if healthy, or an error message string if not.
  Future<String?> checkHealth();

  /// Execute a tool/task and return the result.
  /// Only call this AFTER user approval (VES-09).
  Future<VesselResult> execute({
    required String taskId,
    required String tool,
    required Map<String, dynamic> args,
    String? sessionKey,
  });

  /// Stream chat completions (for agent conversations).
  Stream<String> streamCompletion({
    required List<Map<String, String>> messages,
    String? agentId,
    String? sessionKey,
  });

  /// Cancel a running task.
  Future<void> cancel(String taskId);
}
