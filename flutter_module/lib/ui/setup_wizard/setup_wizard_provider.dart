import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../generated/system_bridge.g.dart';
import '../../generated/terminal_bridge.g.dart';
import '../../services/auth/api_key_service.dart';
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
      installLog: [],
      clearInstallError: true,
    );

    try {
      final terminalApi = TerminalBridgeApi();

      // Create a session to install in
      final sessionId = await terminalApi.createSession();
      _logger.i('Created install session: $sessionId');

      if (profile == SetupProfile.claudeCode) {
        // Step 1: Install dependencies via pkg
        addInstallLog('Installeren: nodejs git gh...');
        await terminalApi.runCommand(sessionId, 'pkg', ['install', '-y', 'nodejs', 'git', 'gh']);

        // Wait a moment for pkg to start
        await Future.delayed(const Duration(seconds: 2));

        // Step 2: Install Claude Code via npm
        addInstallLog('Installeren: @anthropic-ai/claude-code...');
        await terminalApi.runCommand(sessionId, 'npm', ['install', '-g', '@anthropic-ai/claude-code']);
      } else if (profile == SetupProfile.python) {
        addInstallLog('Installeren: python git...');
        await terminalApi.runCommand(sessionId, 'pkg', ['install', '-y', 'python', 'git']);
      }

      addInstallLog('Installatie voltooid.');
      state = state.copyWith(isInstalling: false, installSuccess: true);
      _advanceToNextStep();
    } catch (error) {
      _logger.e('Installation failed: $error');
      state = state.copyWith(
        isInstalling: false,
        installError: 'Installatie mislukt: $error',
      );
    }
  }

  void addInstallLog(String line) {
    state = state.copyWith(installLog: [...state.installLog, line]);
  }

  Future<String?> validateApiKey(String key) async {
    state = state.copyWith(isLoading: true);
    try {
      final error = await ApiKeyService().validateAndSaveKey(key);
      if (error != null) {
        return error;
      }
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
