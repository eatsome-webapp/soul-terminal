---
phase: 3
plan: "03-B"
title: "Flutter Module Creation + Pigeon Schema"
wave: 1
depends_on: []
files_modified:
  - flutter_module/pubspec.yaml
  - flutter_module/lib/main.dart
  - flutter_module/pigeons/terminal_bridge.dart
  - flutter_module/pigeons/system_bridge.dart
  - flutter_module/lib/generated/terminal_bridge.g.dart
  - flutter_module/lib/generated/system_bridge.g.dart
  - app/src/main/java/com/termux/bridge/TerminalBridgeApi.java
  - app/src/main/java/com/termux/bridge/SystemBridgeApi.java
  - flutter_module/.gitignore
requirements_addressed: [FLUT-01, PIGB-01]
autonomous: true
---

# Plan 03-B: Flutter Module Creation + Pigeon Schema

<objective>
Create the Flutter module as a subdirectory, define the Pigeon schema for all three bridges (TerminalBridge, SoulBridge, SystemBridge), generate Java + Dart code from the schema, and create a minimal test UI.
</objective>

<task id="03-B-01">
<title>Create flutter_module directory structure</title>
<read_first>
- .planning/phases/03-flutter-integration/03-CONTEXT.md (Flutter Module Structure section)
- .planning/phases/03-flutter-integration/03-RESEARCH.md (Module structuur section)
</read_first>
<action>
Create the Flutter module directory structure manually (since `flutter create` cannot run in the Bash tool). Create these files:

1. `flutter_module/.gitignore` with contents:
```
.dart_tool/
.packages
.pub/
.android/
.ios/
build/
*.iml
.metadata
```

2. `flutter_module/pubspec.yaml` with contents:
```yaml
name: flutter_module
description: SOUL Terminal Flutter module
publish_to: 'none'
version: 1.0.0

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  pigeon: ^22.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true

module:
  androidX: true
  androidPackage: com.soul.terminal.flutter_module
  iosBundleIdentifier: com.soul.terminal.flutterModule
```

3. `flutter_module/lib/main.dart` — minimal test UI (see task 03-B-03 for contents)

4. `flutter_module/pigeons/` directory (see task 03-B-02 for schema files)

5. `flutter_module/lib/generated/` directory (placeholder, populated by Pigeon codegen)

6. `flutter_module/test/` directory with empty `.gitkeep`
</action>
<acceptance_criteria>
- File `flutter_module/pubspec.yaml` exists and contains `name: flutter_module`
- File `flutter_module/pubspec.yaml` contains `pigeon: ^22.7.0` in dependencies
- File `flutter_module/pubspec.yaml` contains `module:` section with `androidPackage: com.soul.terminal.flutter_module`
- File `flutter_module/.gitignore` exists and contains `.android/`
- Directory `flutter_module/pigeons/` exists
- Directory `flutter_module/lib/generated/` exists
</acceptance_criteria>
</task>

<task id="03-B-02">
<title>Define Pigeon schema files</title>
<read_first>
- .planning/phases/03-flutter-integration/03-CONTEXT.md (Pigeon API Surface section)
- .planning/phases/03-flutter-integration/03-RESEARCH.md (Pigeon Bridge Architecture section)
</read_first>
<action>
Create `flutter_module/pigeons/terminal_bridge.dart` with this exact content:

```dart
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
```

Create `flutter_module/pigeons/system_bridge.dart` with this exact content:

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/system_bridge.g.dart',
  javaOut: '../app/src/main/java/com/termux/bridge/SystemBridgeApi.java',
  javaOptions: JavaOptions(package: 'com.termux.bridge'),
))

/// Device hardware and OS information.
class DeviceInfo {
  DeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
    required this.sdkInt,
  });

  final String manufacturer;
  final String model;
  final String androidVersion;
  final int sdkInt;
}

/// App package and build information.
class PackageInfo {
  PackageInfo({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
  });

  final String packageName;
  final String versionName;
  final int versionCode;
}

/// Host API: Flutter calls these methods, Java implements them.
/// Provides device and app metadata.
@HostApi()
abstract class SystemBridgeApi {
  /// Get device hardware and OS information.
  DeviceInfo getDeviceInfo();

  /// Get app package and version information.
  PackageInfo getPackageInfo();
}
```
</action>
<acceptance_criteria>
- File `flutter_module/pigeons/terminal_bridge.dart` exists
- File contains `@HostApi()` before `abstract class TerminalBridgeApi`
- File contains `@FlutterApi()` before `abstract class SoulBridgeApi`
- File contains `void executeCommand(String command);`
- File contains `String getTerminalOutput(int lines);`
- File contains `int createSession();`
- File contains `List<SessionInfo> listSessions();`
- File contains `void onTerminalOutput(String output);`
- File contains `void onSessionChanged(SessionInfo info);`
- File `flutter_module/pigeons/system_bridge.dart` exists
- File contains `@HostApi()` before `abstract class SystemBridgeApi`
- File contains `DeviceInfo getDeviceInfo();`
- File contains `PackageInfo getPackageInfo();`
</acceptance_criteria>
</task>

<task id="03-B-03">
<title>Create minimal Flutter test UI</title>
<read_first>
- flutter_module/pigeons/terminal_bridge.dart
- .planning/phases/03-flutter-integration/03-CONTEXT.md (Flutter Module Structure section)
</read_first>
<action>
Create `flutter_module/lib/main.dart` with a minimal Material scaffold that will later connect to the Pigeon bridges. This is a test interface only — no Riverpod, no complex state.

```dart
import 'package:flutter/material.dart';

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

class _BridgeTestScreenState extends State<BridgeTestScreen> {
  final TextEditingController _commandController = TextEditingController();
  final List<String> _outputLines = [];
  bool _bridgeConnected = false;

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  void _executeCommand() {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    setState(() {
      _outputLines.add('> $command');
      _outputLines.add('[Bridge not yet connected]');
    });
    _commandController.clear();
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
```
</action>
<acceptance_criteria>
- File `flutter_module/lib/main.dart` exists
- File contains `void main() => runApp(const SoulTerminalApp());`
- File contains `class BridgeTestScreen extends StatefulWidget`
- File contains `TextEditingController _commandController`
- File contains `Color(0xFF6C63FF)` (SOUL primary color)
- File contains `Color(0xFF0F0F23)` (SOUL background color)
</acceptance_criteria>
</task>

<task id="03-B-04">
<title>Generate Pigeon Java and Dart code</title>
<read_first>
- flutter_module/pigeons/terminal_bridge.dart
- flutter_module/pigeons/system_bridge.dart
</read_first>
<action>
Run Pigeon code generation via cmd-proxy (or manually if proxy unavailable). The commands to run inside proot-distro Ubuntu:

```bash
cd /data/data/com.termux/files/home/soul-terminal/flutter_module
flutter pub get
dart run pigeon --input pigeons/terminal_bridge.dart
dart run pigeon --input pigeons/system_bridge.dart
```

This generates 4 files:
1. `flutter_module/lib/generated/terminal_bridge.g.dart` — Dart interfaces for TerminalBridgeApi, SoulBridgeApi, SessionInfo
2. `flutter_module/lib/generated/system_bridge.g.dart` — Dart interfaces for SystemBridgeApi, DeviceInfo, PackageInfo
3. `app/src/main/java/com/termux/bridge/TerminalBridgeApi.java` — Java interfaces for TerminalBridgeApi, SoulBridgeApi
4. `app/src/main/java/com/termux/bridge/SystemBridgeApi.java` — Java interfaces for SystemBridgeApi

If cmd-proxy is unavailable, push to GitHub and run Pigeon in a CI step. Alternatively, the generated files can be written manually based on the Pigeon schema — the generated code is deterministic.

All 4 generated files must be committed to the repository (they are source files, not build artifacts).
</action>
<acceptance_criteria>
- File `flutter_module/lib/generated/terminal_bridge.g.dart` exists and contains `class TerminalBridgeApi`
- File `flutter_module/lib/generated/system_bridge.g.dart` exists and contains `class SystemBridgeApi`
- File `app/src/main/java/com/termux/bridge/TerminalBridgeApi.java` exists and contains `package com.termux.bridge;`
- File `app/src/main/java/com/termux/bridge/SystemBridgeApi.java` exists and contains `package com.termux.bridge;`
- Java files contain `interface TerminalBridgeApi` or `interface SystemBridgeApi` (generated interfaces)
</acceptance_criteria>
</task>

<verification>
## Verification Criteria
- `flutter_module/pubspec.yaml` is valid YAML with `module:` section
- Pigeon schema files define all 3 APIs: TerminalBridgeApi, SoulBridgeApi, SystemBridgeApi
- Generated Java files compile (verified by Gradle build in Plan 03-A context)
- Generated Dart files have no syntax errors
- `flutter_module/lib/main.dart` contains a runnable Flutter app with bridge test UI
- `.gitignore` excludes `.android/` and `.ios/` generated directories
</verification>

<must_haves>
- Flutter module at `flutter_module/` with valid pubspec.yaml including `module:` section (FLUT-01)
- Pigeon schema defining TerminalBridgeApi, SoulBridgeApi, and SystemBridgeApi (PIGB-01)
- Generated Java code in `app/src/main/java/com/termux/bridge/`
- Generated Dart code in `flutter_module/lib/generated/`
- Minimal test UI in `flutter_module/lib/main.dart`
</must_haves>
