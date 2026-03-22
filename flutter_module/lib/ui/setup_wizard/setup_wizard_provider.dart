import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../generated/system_bridge.g.dart';
import '../../generated/terminal_bridge.g.dart';
import '../../services/auth/api_key_service.dart';
import '../../services/awareness/soul_awareness_service.dart';
import '../../services/database/daos/settings_dao.dart';
import '../../services/profile_pack/profile_pack_service.dart';

part 'setup_wizard_provider.g.dart';

enum SetupWizardStep {
  welcome, // ONBR-01: profile choice
  installing, // ONBR-02: package install progress
  apiKey, // ONBR-03: API key input (skippable)
  githubAuth, // ONBR-04: GitHub CLI auth (skippable)
  xiaomiBattery, // ONBR-05: HyperOS instructions (conditional)
  shellConfig, // ONBR-06: OSC 133 config
  complete, // ONBR-07: "Je omgeving is klaar"
}

enum SetupProfile { claudeCode, python, terminalOnly }

class SetupWizardState {
  final SetupWizardStep currentStep;
  final SetupProfile? selectedProfile;
  final List<String> installLog;
  final bool isInstalling;
  final bool installSuccess;
  final String? installError;
  final bool apiKeyValid;
  final bool apiKeySkipped;
  final bool githubSkipped;
  final bool isXiaomi;
  final bool shellConfigDone;
  final bool isLoading;

  const SetupWizardState({
    this.currentStep = SetupWizardStep.welcome,
    this.selectedProfile,
    this.installLog = const [],
    this.isInstalling = false,
    this.installSuccess = false,
    this.installError,
    this.apiKeyValid = false,
    this.apiKeySkipped = false,
    this.githubSkipped = false,
    this.isXiaomi = false,
    this.shellConfigDone = false,
    this.isLoading = false,
  });

  SetupWizardState copyWith({
    SetupWizardStep? currentStep,
    SetupProfile? selectedProfile,
    List<String>? installLog,
    bool? isInstalling,
    bool? installSuccess,
    String? installError,
    bool clearInstallError = false,
    bool? apiKeyValid,
    bool? apiKeySkipped,
    bool? githubSkipped,
    bool? isXiaomi,
    bool? shellConfigDone,
    bool? isLoading,
  }) {
    return SetupWizardState(
      currentStep: currentStep ?? this.currentStep,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      installLog: installLog ?? this.installLog,
      isInstalling: isInstalling ?? this.isInstalling,
      installSuccess: installSuccess ?? this.installSuccess,
      installError: clearInstallError ? null : (installError ?? this.installError),
      apiKeyValid: apiKeyValid ?? this.apiKeyValid,
      apiKeySkipped: apiKeySkipped ?? this.apiKeySkipped,
      githubSkipped: githubSkipped ?? this.githubSkipped,
      isXiaomi: isXiaomi ?? this.isXiaomi,
      shellConfigDone: shellConfigDone ?? this.shellConfigDone,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get progress {
    const steps = SetupWizardStep.values;
    final index = steps.indexOf(currentStep);
    return index / (steps.length - 1);
  }
}

@Riverpod(keepAlive: true)
class SetupWizard extends _$SetupWizard {
  final _logger = Logger();

  @override
  SetupWizardState build() {
    _detectDevice();
    return const SetupWizardState();
  }

  Future<void> _detectDevice() async {
    try {
      final deviceInfo = await SystemBridgeApi().getDeviceInfo();
      final isXiaomi = deviceInfo.manufacturer.toLowerCase() == 'xiaomi';
      state = state.copyWith(isXiaomi: isXiaomi);
      _logger.i('Device manufacturer: ${deviceInfo.manufacturer}, isXiaomi: $isXiaomi');
    } catch (error) {
      _logger.e('Failed to detect device: $error');
    }
  }

  void selectProfile(SetupProfile profile) {
    state = state.copyWith(selectedProfile: profile);
    _advanceToNextStep();
  }

  Future<void> startInstallation() async {
    final profile = state.selectedProfile;
    if (profile == null) return;

    state = state.copyWith(
      isInstalling: true,
      installLog: ['Installatie starten...'],
      clearInstallError: true,
    );

    // Try fast path: profile pack download
    final profileId = profile == SetupProfile.claudeCode ? 'claude-code' : 'python';
    try {
      await _installViaProfilePack(profileId);
      return;
    } catch (e) {
      _logger.w('Profile pack install failed, falling back to pkg: $e');
      addInstallLog('Snelle installatie niet beschikbaar');
      addInstallLog('Terugvallen op handmatige installatie via pkg...');
    }

    // Fallback: traditional pkg install
    await _installViaPkg(profile);
  }

  /// Fast path: download pre-built profile pack and extract.
  Future<void> _installViaProfilePack(String profileId) async {
    final packService = ProfilePackService();

    addInstallLog('Manifest ophalen...');
    final manifest = await packService.fetchManifest();
    final pack = manifest.profiles.where((p) => p.id == profileId).firstOrNull;

    if (pack == null || !pack.isAvailable) {
      throw Exception('Profiel "$profileId" niet beschikbaar als pack');
    }

    addInstallLog('Profile pack gevonden: ${pack.name} v${pack.version}');
    final stopwatch = Stopwatch()..start();
    addInstallLog('Downloaden (${pack.sizeMb} MB)...');
    final zipPath = await packService.downloadPack(pack, (progress) {
      // Update last log line with progress percentage
      final percent = (progress * 100).toStringAsFixed(0);
      final logs = [...state.installLog];
      if (logs.isNotEmpty) {
        logs[logs.length - 1] = 'Downloaden... $percent%';
      }
      state = state.copyWith(installLog: logs);
    });

    addInstallLog('Verificatie...');
    await packService.installPack(pack, zipPath);

    stopwatch.stop();
    final seconds = stopwatch.elapsed.inSeconds;
    addInstallLog('Installatie voltooid in ${seconds}s!');
    state = state.copyWith(isInstalling: false, installSuccess: true);
    _advanceToNextStep();
  }

  /// Fallback: install packages via pkg/npm in terminal.
  /// PROF-04: parallel where possible, time estimates, per-package progress.
  Future<void> _installViaPkg(SetupProfile profile) async {
    final awareness = ref.read(soulAwarenessProvider.notifier);
    try {
      await awareness.initialize();
      addInstallLog('Terminal sessie aangemaakt');
    } catch (e) {
      state = state.copyWith(
        isInstalling: false,
        installError: 'Kon terminal sessie niet aanmaken: $e',
      );
      return;
    }

    final subscription = awareness.outputStream.listen((line) {
      if (line.trim().isNotEmpty) {
        addInstallLog(line.trim());
      }
    });

    try {
      final bridge = TerminalBridgeApi();
      final sessionId = ref.read(soulAwarenessProvider).awarenessSessionId;
      final stopwatch = Stopwatch()..start();

      if (profile == SetupProfile.claudeCode) {
        // Estimated time: 8-12 min for pkg + npm on average mobile connection
        addInstallLog('Geschatte tijd: 8-12 minuten (afhankelijk van netwerksnelheid)');

        // Step 1: pkg install (packages can be installed in one command)
        addInstallLog('[1/2] Packages installeren: nodejs, git, gh...');
        await bridge.sendInput(sessionId!, 'pkg update -y && pkg install -y nodejs git gh && echo "SOUL_PKG_DONE"\n');
        await _waitForMarker('SOUL_PKG_DONE', timeout: const Duration(minutes: 10));
        addInstallLog('[1/2] Packages geinstalleerd');

        // Step 2: npm global install (largest part)
        addInstallLog('[2/2] Claude Code installeren via npm (dit duurt het langst)...');
        await bridge.sendInput(sessionId, 'npm install -g @anthropic-ai/claude-code && echo "SOUL_NPM_DONE"\n');
        await _waitForMarker('SOUL_NPM_DONE', timeout: const Duration(minutes: 10));
        addInstallLog('[2/2] Claude Code geinstalleerd');
      } else if (profile == SetupProfile.python) {
        // Estimated time: 3-5 min
        addInstallLog('Geschatte tijd: 3-5 minuten');

        addInstallLog('[1/1] Packages installeren: python, pip, git...');
        await bridge.sendInput(sessionId!, 'pkg update -y && pkg install -y python python-pip git && echo "SOUL_PKG_DONE"\n');
        await _waitForMarker('SOUL_PKG_DONE', timeout: const Duration(minutes: 10));
        addInstallLog('[1/1] Packages geinstalleerd');
      }

      stopwatch.stop();
      final minutes = stopwatch.elapsed.inMinutes;
      final seconds = stopwatch.elapsed.inSeconds % 60;
      state = state.copyWith(isInstalling: false, installSuccess: true);
      addInstallLog('Installatie voltooid in ${minutes}m ${seconds}s!');
      _advanceToNextStep();
    } catch (error) {
      _logger.e('Installation failed: $error');
      state = state.copyWith(
        isInstalling: false,
        installError: 'Installatie mislukt: $error',
      );
    } finally {
      await subscription.cancel();
    }
  }

  void retryInstallation() {
    state = state.copyWith(installError: null, installLog: []);
    startInstallation();
  }

  void proceedFromInstall() {
    _advanceToNextStep();
  }

  /// Wait for a marker string in the output stream, with timeout.
  /// Used instead of runCommand() because OSC 133 is not yet configured.
  Future<void> _waitForMarker(String marker, {Duration timeout = const Duration(minutes: 5)}) async {
    final completer = Completer<void>();
    final awareness = ref.read(soulAwarenessProvider.notifier);
    late final StreamSubscription<String> sub;
    sub = awareness.outputStream.listen((line) {
      if (line.contains(marker)) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });
    try {
      await completer.future.timeout(timeout, onTimeout: () {
        sub.cancel();
        addInstallLog('Installatie timeout — probeer later handmatig');
      });
    } catch (e) {
      sub.cancel();
      rethrow;
    }
  }

  void addInstallLog(String line) {
    state = state.copyWith(installLog: [...state.installLog, line]);
  }

  Future<String?> validateApiKey(String key) async {
    state = state.copyWith(isLoading: true);
    try {
      // Format check first
      if (!key.startsWith('sk-ant-') || key.length < 20) {
        state = state.copyWith(isLoading: false);
        return 'Ongeldig formaat — key moet beginnen met sk-ant-';
      }
      // Validate via API + save
      final apiKeyService = ApiKeyService();
      final error = await apiKeyService.validateAndSaveKey(key);
      if (error != null) {
        state = state.copyWith(isLoading: false);
        return error;
      }
      // Update the apiKeyNotifier so the rest of the app sees the key
      ref.read(apiKeyNotifierProvider.notifier).setKey(key);
      state = state.copyWith(apiKeyValid: true, isLoading: false);
      _advanceToNextStep();
      return null;
    } catch (error) {
      state = state.copyWith(isLoading: false);
      return 'Validatie mislukt: $error';
    }
  }

  void skipApiKey() {
    state = state.copyWith(apiKeySkipped: true);
    _advanceToNextStep();
  }

  void skipGithub() {
    state = state.copyWith(githubSkipped: true);
    _advanceToNextStep();
  }

  Future<void> openTerminalForGithub() async {
    try {
      final terminalApi = TerminalBridgeApi();
      await terminalApi.setTerminalVisible(true);
      // Get or create awareness session for gh auth
      final sessionId = await terminalApi.createAwarenessSession();
      await terminalApi.sendInput(sessionId, 'gh auth login --web\n');
    } catch (error) {
      _logger.e('Failed to open terminal for GitHub auth: $error');
    }
  }

  void confirmGithub() {
    _advanceToNextStep();
  }

  void confirmXiaomi() {
    _advanceToNextStep();
  }

  Future<void> writeShellConfig() async {
    state = state.copyWith(isLoading: true);
    final bridge = TerminalBridgeApi();
    const homePath = '/data/data/com.soul.terminal/files/home';

    try {
      // Bash: PROMPT_COMMAND for OSC 133 completion markers
      const bashConfig = '\n# SOUL Terminal: OSC 133 command completion markers\n'
          'PROMPT_COMMAND=\'printf "\\033]133;D\\007"\'\n';
      await bridge.writeShellConfig('$homePath/.bashrc', bashConfig);
      _logger.i('OSC 133 config written to .bashrc');

      // Zsh: precmd hook for OSC 133 completion markers
      const zshConfig = '\n# SOUL Terminal: OSC 133 command completion markers\n'
          'precmd() { printf "\\033]133;D\\007"; }\n';
      await bridge.writeShellConfig('$homePath/.zshrc', zshConfig);
      _logger.i('OSC 133 config written to .zshrc');

      // Lazy install: command_not_found_handle for SOUL profile pack prompt
      const bashCnfConfig = '\n# SOUL Terminal: command not found handler for lazy install\n'
          'command_not_found_handle() {\n'
          '  printf \'\\033]777;soul-cnf;%s\\007\' "\$1"\n'
          '  if [ -x "\$PREFIX/libexec/termux/command-not-found" ]; then\n'
          '    "\$PREFIX/libexec/termux/command-not-found" "\$1"\n'
          '  fi\n'
          '  return 127\n'
          '}\n';
      await bridge.writeShellConfig('$homePath/.bashrc', bashCnfConfig);
      _logger.i('command_not_found_handle written to .bashrc');

      // Lazy install: command_not_found_handler for zsh
      const zshCnfConfig = '\n# SOUL Terminal: command not found handler for lazy install\n'
          'command_not_found_handler() {\n'
          '  printf \'\\033]777;soul-cnf;%s\\007\' "\$1"\n'
          '  if [ -x "\$PREFIX/libexec/termux/command-not-found" ]; then\n'
          '    "\$PREFIX/libexec/termux/command-not-found" "\$1"\n'
          '  fi\n'
          '  return 127\n'
          '}\n';
      await bridge.writeShellConfig('$homePath/.zshrc', zshCnfConfig);
      _logger.i('command_not_found_handler written to .zshrc');

      state = state.copyWith(isLoading: false, shellConfigDone: true);
    } catch (error) {
      _logger.e('Failed to write shell config: $error');
      // Non-fatal: user can configure manually later
      state = state.copyWith(isLoading: false, shellConfigDone: true);
      addInstallLog('Shell configuratie kon niet automatisch geschreven worden. Voeg handmatig toe aan .bashrc: PROMPT_COMMAND=\'printf "\\033]133;D\\007"\'');
    }
  }

  void proceedFromShellConfig() {
    _advanceToNextStep();
  }

  /// Persists completion flag and profile to SettingsDao.
  /// Called from _advanceToNextStep when transitioning to the complete step.
  Future<void> _persistCompletion() async {
    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setBool(SettingsKeys.setupCompleted, true);

    // Store chosen profile for future reference
    if (state.selectedProfile != null) {
      await settingsDao.setString(
        SettingsKeys.setupProfile,
        state.selectedProfile!.name, // claudeCode, python, terminalOnly
      );
    }

    _logger.i('Setup wizard completed. Profile: ${state.selectedProfile?.name}');
  }

  /// Public method for the "Begin" button — only navigates, persistence already done.
  void completeSetup() {
    // No-op — persistence already happened in _persistCompletion().
    // This method exists so the UI has a clean notifier call before navigating.
  }

  void _advanceToNextStep() {
    final current = state.currentStep;
    SetupWizardStep? next;

    switch (current) {
      case SetupWizardStep.welcome:
        if (state.selectedProfile == SetupProfile.terminalOnly) {
          next = SetupWizardStep.apiKey; // Skip installation
        } else {
          next = SetupWizardStep.installing;
        }
      case SetupWizardStep.installing:
        next = SetupWizardStep.apiKey;
      case SetupWizardStep.apiKey:
        next = SetupWizardStep.githubAuth;
      case SetupWizardStep.githubAuth:
        if (state.isXiaomi) {
          next = SetupWizardStep.xiaomiBattery;
        } else {
          next = SetupWizardStep.shellConfig;
        }
      case SetupWizardStep.xiaomiBattery:
        next = SetupWizardStep.shellConfig;
      case SetupWizardStep.shellConfig:
        next = SetupWizardStep.complete;
        // Persist completion before showing the screen (async, no state update here)
        _persistCompletion();
      case SetupWizardStep.complete:
        return; // No next step
    }

    if (next != null) {
      state = state.copyWith(currentStep: next);
    }
  }
}
