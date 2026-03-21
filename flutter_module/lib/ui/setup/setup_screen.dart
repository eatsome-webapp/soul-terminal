import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/providers.dart';
import '../../services/auth/api_key_service.dart';

/// First-run screen for entering the Anthropic API key.
///
/// Shown when no API key is stored yet. After saving, navigates to onboarding.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _keyLooksValid {
    final text = _controller.text.trim();
    return text.startsWith('sk-ant-') && text.length > 20;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final key = _controller.text.trim();
    final service = ApiKeyService();
    await service.saveAnthropicKey(key);

    ref.read(apiKeyNotifierProvider.notifier).setKey(key);

    if (mounted) {
      context.go('/onboarding');
    }
  }

  Future<void> _openConsole() async {
    final uri = Uri.parse('https://console.anthropic.com/settings/keys');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Icon(
                    Icons.auto_awesome,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Welcome to SOUL',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your AI mastermind needs a Claude API key to think.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // API key field
                  TextFormField(
                    controller: _controller,
                    obscureText: _obscure,
                    autofocus: true,
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      labelText: 'Anthropic API key',
                      hintText: 'sk-ant-api03-...',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility : Icons.visibility_off,
                            ),
                            tooltip: _obscure ? 'Show' : 'Hide',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          IconButton(
                            icon: const Icon(Icons.paste_outlined),
                            tooltip: 'Paste',
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (data?.text != null) {
                                _controller.text = data!.text!.trim();
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Enter your API key';
                      if (!text.startsWith('sk-ant-')) {
                        return 'Must start with sk-ant-';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Get key link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _openConsole,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Get your API key at console.anthropic.com'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Continue button
                  FilledButton(
                    onPressed: _isSaving || !_keyLooksValid ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
