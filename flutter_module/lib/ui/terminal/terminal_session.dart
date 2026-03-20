import 'package:xterm/xterm.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../services/vessels/models/vessel_task.dart';

enum TerminalSessionStatus { disconnected, connecting, connected, error }

class TerminalSession {
  final String id;
  final String label;
  final Terminal terminal;
  final VesselType? vesselType;
  TerminalSessionStatus status;
  WebSocketChannel? webSocketChannel;
  String? errorMessage;

  TerminalSession({
    required this.id,
    required this.label,
    Terminal? terminal,
    this.vesselType,
    this.status = TerminalSessionStatus.disconnected,
    this.webSocketChannel,
    this.errorMessage,
  }) : terminal = terminal ?? Terminal(maxLines: 10000);

  bool get isConnected => status == TerminalSessionStatus.connected;
}
