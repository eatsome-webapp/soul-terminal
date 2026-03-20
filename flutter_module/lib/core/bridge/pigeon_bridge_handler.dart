import 'package:logger/logger.dart';
import '../../generated/terminal_bridge.g.dart';

final _logger = Logger();

/// Handles incoming Pigeon calls from the Java host side.
///
/// Implements [SoulBridgeApi] to receive terminal output and session change
/// events from the Android terminal emulator. Call [init()] once at app startup
/// to register the handler with the Pigeon message channel.
class PigeonBridgeHandler implements SoulBridgeApi {
  /// Last received terminal output snapshot.
  String? lastOutput;

  /// Last session change event.
  SessionInfo? lastSession;

  /// Register this handler with the Pigeon bridge.
  ///
  /// Must be called before the Java host attempts to send events.
  /// Safe to call multiple times — subsequent calls re-register the handler.
  void init() {
    SoulBridgeApi.setUp(this);
    _logger.i('PigeonBridgeHandler registered with SoulBridgeApi');
  }

  /// Called by the Java host when terminal output changes (debounced, max 10/sec).
  @override
  void onTerminalOutput(String output) {
    lastOutput = output;
    _logger.d('Terminal output received: ${output.length} chars');
  }

  /// Called by the Java host when the active terminal session changes.
  @override
  void onSessionChanged(SessionInfo info) {
    lastSession = info;
    _logger.d('Session changed: id=${info.id} name=${info.name}');
  }
}
