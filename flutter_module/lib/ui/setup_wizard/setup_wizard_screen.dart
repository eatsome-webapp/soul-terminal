import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'setup_wizard_provider.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  static const Color _background = Color(0xFF0F0F23);
  static const Color _cardBackground = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _textPrimary = Color(0xFFE0E0E0);
  static const Color _textSecondary = Color(0xFF9E9E9E);
  static const Color _errorColor = Color(0xFFFF5252);
  static const Color _progressBackground = Color(0xFF1A1A2E);

  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  String? _apiKeyError;
  bool _shellConfigStarted = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    // Auto-trigger shell config on step enter
    if (state.currentStep == SetupWizardStep.shellConfig && !_shellConfigStarted) {
      _shellConfigStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.writeShellConfig();
      });
    }

    return PopScope(
      canPop: !state.isInstalling,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: state.progress,
                color: _accent,
                backgroundColor: _progressBackground,
                minHeight: 3,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey(state.currentStep),
                    child: _buildCurrentStep(state, notifier),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(SetupWizardState state, SetupWizard notifier) {
    return switch (state.currentStep) {
      SetupWizardStep.welcome => _buildWelcomeStep(notifier),
      SetupWizardStep.installing => _buildInstallingStep(state, notifier),
      SetupWizardStep.apiKey => _buildApiKeyStep(state, notifier),
      SetupWizardStep.githubAuth => _buildGithubStep(notifier),
      SetupWizardStep.xiaomiBattery => _buildXiaomiStep(notifier),
      SetupWizardStep.shellConfig => _buildShellConfigStep(state),
      SetupWizardStep.complete => _buildCompleteStep(notifier),
    };
  }

  Widget _buildWelcomeStep(SetupWizard notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(
            Icons.terminal,
            size: 64,
            color: _accent,
          ),
          const SizedBox(height: 16),
          const Text(
            'Welkom bij SOUL Terminal',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Kies je setup:',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildProfileCard(
            icon: Icons.psychology,
            title: 'Claude Code',
            subtitle: 'Installeert Node.js, Git, GitHub CLI en Claude Code npm package. Volledig AI-gestuurde terminal.',
            profile: SetupProfile.claudeCode,
            notifier: notifier,
          ),
          const SizedBox(height: 12),
          _buildProfileCard(
            icon: Icons.code,
            title: 'Python',
            subtitle: 'Installeert Python en Git. Voor data science en scripting workflows.',
            profile: SetupProfile.python,
            notifier: notifier,
          ),
          const SizedBox(height: 12),
          _buildProfileCard(
            icon: Icons.terminal,
            title: 'Alleen terminal',
            subtitle: 'Geen extra pakketten. Gebruik SOUL Terminal als standalone terminal emulator.',
            profile: SetupProfile.terminalOnly,
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required SetupProfile profile,
    required SetupWizard notifier,
  }) {
    return Card(
      color: _cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A4A)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => notifier.selectProfile(profile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: _accent, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: _textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstallingStep(SetupWizardState state, SetupWizard notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Installatie...',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: state.installLog.isEmpty
                  ? const Center(
                      child: Text(
                        'Klaar om te starten...',
                        style: TextStyle(color: _textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.installLog.length,
                      itemBuilder: (context, index) {
                        return Text(
                          state.installLog[index],
                          style: const TextStyle(
                            color: _textPrimary,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.isInstalling) ...[
            const Center(
              child: CircularProgressIndicator(color: _accent),
            ),
            const SizedBox(height: 8),
            const Text(
              'Even geduld...',
              style: TextStyle(color: _textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (state.installError != null) ...[
            Text(
              state.installError!,
              style: const TextStyle(color: _errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: notifier.startInstallation,
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              child: const Text('Opnieuw proberen'),
            ),
          ],
          if (!state.isInstalling && state.installError == null && !state.installSuccess)
            ElevatedButton(
              onPressed: notifier.startInstallation,
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              child: const Text('Start installatie'),
            ),
        ],
      ),
    );
  }

  Widget _buildApiKeyStep(SetupWizardState state, SetupWizard notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.key, size: 48, color: _accent),
          const SizedBox(height: 16),
          const Text(
            'Anthropic API Key',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Voer je Anthropic API key in om Claude Code te gebruiken. Je kunt dit ook later instellen.',
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            style: const TextStyle(color: _textPrimary, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: 'sk-ant-api03-...',
              hintStyle: const TextStyle(color: _textSecondary),
              filled: true,
              fillColor: _cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _accent),
              ),
              errorText: _apiKeyError,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                      color: _textSecondary,
                    ),
                    onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.paste, color: _textSecondary),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _apiKeyController.text = data!.text!;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    setState(() => _apiKeyError = null);
                    final key = _apiKeyController.text.trim();
                    final error = await notifier.validateApiKey(key);
                    if (error != null && mounted) {
                      setState(() => _apiKeyError = error);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Valideren', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: notifier.skipApiKey,
            child: const Text('Overslaan', style: TextStyle(color: _textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildGithubStep(SetupWizard notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.hub, size: 48, color: _accent),
          const SizedBox(height: 16),
          const Text(
            'GitHub CLI',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Log in bij GitHub zodat Claude Code repositories kan beheren en pull requests kan aanmaken.',
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: notifier.openTerminalForGithub,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open terminal (gh auth login)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: notifier.confirmGithub,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A4A),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Ik heb ingelogd',
              style: TextStyle(color: _textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: notifier.skipGithub,
            child: const Text('Overslaan', style: TextStyle(color: _textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildXiaomiStep(SetupWizard notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.battery_saver, size: 48, color: _accent),
          const SizedBox(height: 16),
          const Text(
            'Battery-instellingen',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'HyperOS beperkt achtergrondprocessen. Stel dit in om te voorkomen dat SOUL Terminal wordt gestopt.',
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildInstructionItem(1, 'Ga naar Instellingen > Apps > Autostart'),
          _buildInstructionItem(2, 'Zoek SOUL Terminal en schakel autostart in'),
          _buildInstructionItem(
            3,
            'Ga naar Battery > App battery saver > SOUL Terminal > Geen restricties',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: notifier.confirmXiaomi,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Ik heb dit gedaan',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(color: _textPrimary, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShellConfigStep(SetupWizardState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.settings_suggest, size: 64, color: _accent),
          const SizedBox(height: 24),
          const Text(
            'Shell configuratie',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'OSC 133 markers worden toegevoegd aan je shell config. Dit is nodig voor commando-detectie.',
            style: TextStyle(color: _textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!state.shellConfigDone)
            const Center(child: CircularProgressIndicator(color: _accent))
          else ...[
            const Icon(Icons.check_circle, size: 48, color: Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            const Text(
              'Shell config bijgewerkt',
              style: TextStyle(color: _textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompleteStep(SetupWizard notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF4CAF50)),
          const SizedBox(height: 24),
          const Text(
            'Je omgeving is klaar!',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'SOUL Terminal is geconfigureerd en klaar voor gebruik.',
            style: TextStyle(color: _textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              await notifier.completeSetup();
              if (mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Begin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
