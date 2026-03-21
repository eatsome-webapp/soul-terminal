import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../generated/system_bridge.g.dart';
import '../../generated/terminal_bridge.g.dart';
import '../../services/auth/api_key_service.dart';
import '../../services/awareness/soul_awareness_service.dart';
import '../../services/database/daos/settings_dao.dart';

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
    if (profile == SetupProfile.terminalOnly) {
      // Skip installing step for terminal-only profile
      state = state.copyWith(currentStep: SetupWizardStep.apiKey);
    } else {
      state = state.copyWith(currentStep: SetupWizardStep.installing);
    }
  }

  Future<void> startInstallation() async {
    final profile = state.selectedProfile;
    if (profile == null) return;

    state = state.copyWith(
      isInstalling: true,
      installLog: ['Installatie starten...'],
      clearInstallError: true,
    );

    // Initialize awareness session for output streaming
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

    // Listen to output stream for real-time progress
    final subscription = awareness.outputStream.listen((line) {
      if (line.trim().isNotEmpty) {
        addInstallLog(line.trim());
      }
    });

    try {
      final bridge = TerminalBridgeApi();
      final sessionId = ref.read(soulAwarenessProvider).awarenessSessionId;

      if (profile == SetupProfile.claudeCode) {
        addInstallLog('Packages installeren: nodejs, git, gh...');
        await bridge.sendInput(sessionId!, 'pkg install -y nodejs git gh && echo "SOUL_PKG_DONE"\n');
        await _waitForMarker('SOUL_PKG_DONE', timeout: const Duration(minutes: 5));
        addInstallLog('Packages geïnstalleerd');

        addInstallLog('Claude Code installeren via npm...');
        await bridge.sendInput(sessionId, 'npm install -g @anthropic-ai/claude-code && echo "SOUL_NPM_DONE"\n');
        await _waitForMarker('SOUL_NPM_DONE', timeout: const Duration(minutes: 5));
        addInstallLog('Claude Code geïnstalleerd');
      } else if (profile == SetupProfile.python) {
        addInstallLog('Packages installeren: python, pip, git...');
        await bridge.sendInput(sessionId!, 'pkg install -y python pip git && echo "SOUL_PKG_DONE"\n');
        await _waitForMarker('SOUL_PKG_DONE', timeout: const Duration(minutes: 5));
        addInstallLog('Packages geïnstalleerd');
      }

      state = state.copyWith(isInstalling: false, installSuccess: true);
      addInstallLog('Installatie voltooid!');
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
      await terminalApi.openTerminalSheet();
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
    try {
      const oscConfig = '\n# SOUL Terminal: OSC 133 command tracking\n'
          'precmd() { printf "\\033]133;D\\007"; }\n'
          'preexec() { printf "\\033]133;C\\007"; }\n';

      final terminalApi = TerminalBridgeApi();

      final homeDir = '/data/data/com.termux/files/home';
      await terminalApi.writeShellConfig('$homeDir/.bashrc', oscConfig);
      await terminalApi.writeShellConfig('$homeDir/.zshrc', oscConfig);

      state = state.copyWith(shellConfigDone: true);
      _logger.i('Shell config written successfully');
      _advanceToNextStep();
    } catch (error) {
      _logger.e('Failed to write shell config: $error');
    }
  }

  Future<void> completeSetup() async {
    final profile = state.selectedProfile;
    final settingsDao = ref.read(settingsDaoProvider);

    await settingsDao.setBool(SettingsKeys.setupCompleted, true);

    if (profile != null) {
      final profileString = switch (profile) {
        SetupProfile.claudeCode => 'claude_code',
        SetupProfile.python => 'python',
        SetupProfile.terminalOnly => 'terminal_only',
      };
      await settingsDao.setString(SettingsKeys.setupProfile, profileString);
    }

    _logger.i('Setup completed with profile: ${state.selectedProfile}');
  }

  void _advanceToNextStep() {
    final currentStep = state.currentStep;
    final steps = SetupWizardStep.values;
    final currentIndex = steps.indexOf(currentStep);

    SetupWizardStep nextStep = currentStep;

    for (int i = currentIndex + 1; i < steps.length; i++) {
      final candidate = steps[i];

      // Skip xiaomiBattery if not a Xiaomi device
      if (candidate == SetupWizardStep.xiaomiBattery && !state.isXiaomi) {
        continue;
      }

      // Skip installing if terminalOnly profile
      if (candidate == SetupWizardStep.installing &&
          state.selectedProfile == SetupProfile.terminalOnly) {
        continue;
      }

      nextStep = candidate;
      break;
    }

    state = state.copyWith(currentStep: nextStep);
  }
}
