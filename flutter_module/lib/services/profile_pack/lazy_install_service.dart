import 'dart:async';

import 'package:logger/logger.dart';

import 'profile_pack_service.dart';

/// Maps terminal commands to profile pack IDs.
/// When a command is not found, this service determines which
/// profile pack to suggest for installation.
class LazyInstallService {
  static const _commandToProfile = <String, String>{
    'claude': 'claude-code',
    'node': 'claude-code',
    'npm': 'claude-code',
    'npx': 'claude-code',
    'git': 'claude-code',
    'gh': 'claude-code',
    'python': 'python',
    'python3': 'python',
    'pip': 'python',
    'pip3': 'python',
  };

  final _logger = Logger();
  final _pendingPrompts = <String>{};

  /// Stream controller for command-not-found events.
  /// UI listens to this to show install prompts.
  final _cnfController = StreamController<CommandNotFoundEvent>.broadcast();
  Stream<CommandNotFoundEvent> get onCommandNotFound => _cnfController.stream;

  /// Called when terminal detects a command-not-found OSC 777 sequence.
  /// [command] is the missing command name (e.g., "claude", "node").
  void handleCommandNotFound(String command) {
    final profileId = _commandToProfile[command];
    if (profileId == null) {
      _logger.d('Unknown command "$command" — no profile mapping, ignoring');
      return;
    }

    // Avoid duplicate prompts for same command in quick succession
    if (_pendingPrompts.contains(command)) return;
    _pendingPrompts.add(command);

    // Clear pending after 10 seconds (allow re-prompt)
    Future.delayed(const Duration(seconds: 10), () {
      _pendingPrompts.remove(command);
    });

    _logger.i('Command not found: "$command" -> suggest profile "$profileId"');
    _cnfController.add(CommandNotFoundEvent(
      command: command,
      profileId: profileId,
    ));
  }

  /// Install a profile pack triggered by lazy install.
  /// Returns null on success, error message on failure.
  Future<String?> installProfile(String profileId, void Function(String) onLog) async {
    final packService = ProfilePackService();
    try {
      onLog('Manifest ophalen...');
      final manifest = await packService.fetchManifest();
      final profile = manifest.profiles.where((p) => p.id == profileId).firstOrNull;

      if (profile == null || !profile.isAvailable) {
        return 'Profiel "$profileId" niet beschikbaar als pack. Gebruik: pkg install <package>';
      }

      onLog('Downloaden (${profile.sizeMb} MB)...');
      final zipPath = await packService.downloadPack(profile, (progress) {
        final percent = (progress * 100).toStringAsFixed(0);
        onLog('Downloaden... $percent%');
      });

      onLog('Installeren...');
      await packService.installPack(profile, zipPath);
      onLog('Klaar! Probeer het commando opnieuw.');
      return null;
    } catch (e) {
      _logger.e('Lazy install failed for $profileId: $e');
      return 'Installatie mislukt: $e';
    }
  }

  void dispose() {
    _cnfController.close();
  }
}

/// Event emitted when a command is not found and a profile is available.
class CommandNotFoundEvent {
  final String command;
  final String profileId;

  const CommandNotFoundEvent({
    required this.command,
    required this.profileId,
  });
}
