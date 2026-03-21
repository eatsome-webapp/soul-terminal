import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Navigate away on completion
    if (state.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/chat/new');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Set up your project')),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: state.isComplete ? 1.0 : state.progress,
            backgroundColor: colorScheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.content,
                      style: textTheme.bodyLarge,
                    ),
                  ),
                );
              },
            ),
          ),
          // Skip button + input
          if (!state.isComplete &&
              state.currentStep != OnboardingStep.confirmation) ...[
            if (state.canSkip)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => notifier.skipStep(),
                    child: Text(
                      'Skip for now',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            _OnboardingInput(onSubmit: notifier.submitResponse),
          ],
          // Confirmation: show complete button
          if (state.currentStep == OnboardingStep.confirmation &&
              !state.isComplete)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => notifier.submitResponse('confirmed'),
                child: const Text('Start your first chat'),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingInput extends StatefulWidget {
  final void Function(String) onSubmit;
  const _OnboardingInput({required this.onSubmit});

  @override
  State<_OnboardingInput> createState() => _OnboardingInputState();
}

class _OnboardingInputState extends State<_OnboardingInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: 'Type your answer...'),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submit,
            icon: Icon(Icons.send, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
