import 'package:flutter/material.dart';
import 'package:flutter_module/generated/terminal_bridge.g.dart';
import 'package:flutter_module/generated/system_bridge.g.dart';

void main() => runApp(const SoulTerminalApp());

class SoulTerminalApp extends StatelessWidget {
  const SoulTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOUL Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        useMaterial3: true,
      ),
      home: const BridgeTestScreen(),
    );
  }
}

class BridgeTestScreen extends StatefulWidget {
  const BridgeTestScreen({super.key});

  @override
  State<BridgeTestScreen> createState() => _BridgeTestScreenState();
}

class _BridgeTestScreenState extends State<BridgeTestScreen>
    implements SoulBridgeApi {
  final TextEditingController _commandController = TextEditingController();
  final List<String> _outputLines = [];
  bool _bridgeConnected = false;

  final TerminalBridgeApi _terminalBridge = TerminalBridgeApi();
  final SystemBridgeApi _systemBridge = SystemBridgeApi();

  @override
  void initState() {
    super.initState();
    SoulBridgeApi.setUp(this);
    _checkBridgeConnection();
  }

  @override
  void dispose() {
    SoulBridgeApi.setUp(null);
    _commandController.dispose();
    super.dispose();
  }

  // SoulBridgeApi implementation — called from host (Java) side
  @override
  void onTerminalOutput(String output) {
    setState(() {
      _outputLines.clear();
      _outputLines.addAll(output.split('\n'));
    });
  }

  @override
  void onSessionChanged(SessionInfo info) {
    setState(() {
      _outputLines.add('[Session changed: ${info.name}]');
    });
  }

  Future<void> _checkBridgeConnection() async {
    try {
      await _systemBridge.getDeviceInfo();
      setState(() {
        _bridgeConnected = true;
      });
    } catch (e) {
      setState(() {
        _bridgeConnected = false;
      });
    }
  }

  Future<void> _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    setState(() {
      _outputLines.add('> $command');
    });
    _commandController.clear();

    try {
      await _terminalBridge.executeCommand(command);
    } catch (e) {
      setState(() {
        _outputLines.add('[Error: $e]');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOUL Bridge Test'),
        backgroundColor: const Color(0xFF1A1A2E),
        actions: [
          Icon(
            _bridgeConnected ? Icons.link : Icons.link_off,
            color: _bridgeConnected
                ? const Color(0xFF00D9FF)
                : Colors.grey,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _outputLines.length,
              itemBuilder: (context, index) {
                return Text(
                  _outputLines[index],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF16213E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter command...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _executeCommand(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _executeCommand,
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF6C63FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
