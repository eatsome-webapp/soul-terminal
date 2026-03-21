import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/providers.dart';

enum OnboardingStep { name, description, techStack, goals, confirmation }

class OnboardingState {
  final OnboardingStep currentStep;
  final List<OnboardingMessage> messages;
  final String? projectName;
  final String? projectDescription;
  final String? techStack;
  final String? goals;
  final bool isComplete;

  const OnboardingState({
    this.currentStep = OnboardingStep.name,
    this.messages = const [],
    this.projectName,
    this.projectDescription,
    this.techStack,
    this.goals,
    this.isComplete = false,
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    List<OnboardingMessage>? messages,
    String? projectName,
    String? projectDescription,
    String? techStack,
    String? goals,
    bool? isComplete,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      messages: messages ?? this.messages,
      projectName: projectName ?? this.projectName,
      projectDescription: projectDescription ?? this.projectDescription,
      techStack: techStack ?? this.techStack,
      goals: goals ?? this.goals,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  double get progress {
    switch (currentStep) {
      case OnboardingStep.name:
        return 0.0;
      case OnboardingStep.description:
        return 0.2;
      case OnboardingStep.techStack:
        return 0.4;
      case OnboardingStep.goals:
        return 0.6;
      case OnboardingStep.confirmation:
        return 0.8;
    }
  }

  bool get canSkip =>
      currentStep == OnboardingStep.techStack ||
      currentStep == OnboardingStep.goals;
}

class OnboardingMessage {
  final String content;
  final bool isUser;
  OnboardingMessage({required this.content, required this.isUser});
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState(
      messages: [
        OnboardingMessage(
          content: "Let's get to know your project. What's it called?",
          isUser: false,
        ),
      ],
    );
  }

  void submitResponse(String text) {
    final currentMessages = [
      ...state.messages,
      OnboardingMessage(content: text, isUser: true),
    ];

    switch (state.currentStep) {
      case OnboardingStep.name:
        state = state.copyWith(
          projectName: text,
          currentStep: OnboardingStep.description,
          messages: [
            ...currentMessages,
            OnboardingMessage(
              content: 'Nice! Tell me about $text. What does it do?',
              isUser: false,
            ),
          ],
        );
      case OnboardingStep.description:
        state = state.copyWith(
          projectDescription: text,
          currentStep: OnboardingStep.techStack,
          messages: [
            ...currentMessages,
            OnboardingMessage(
              content:
                  'What tech stack are you using? (You can skip this for now)',
              isUser: false,
            ),
          ],
        );
      case OnboardingStep.techStack:
        state = state.copyWith(
          techStack: text,
          currentStep: OnboardingStep.goals,
          messages: [
            ...currentMessages,
            OnboardingMessage(
              content:
                  'What are your main goals for this project? (You can skip this too)',
              isUser: false,
            ),
          ],
        );
      case OnboardingStep.goals:
        state = state.copyWith(
          goals: text,
          currentStep: OnboardingStep.confirmation,
          messages: [
            ...currentMessages,
            OnboardingMessage(
              content: "Got it! Here's what I know:\n\n"
                  '**${state.projectName}**\n'
                  '${state.projectDescription ?? ""}\n'
                  '${state.techStack != null ? "Tech: ${state.techStack}\n" : ""}'
                  '${text.isNotEmpty ? "Goals: $text\n" : ""}\n'
                  'Ready to start?',
              isUser: false,
            ),
          ],
        );
      case OnboardingStep.confirmation:
        state = state.copyWith(
          messages: currentMessages,
          isComplete: true,
        );
        _persistProject();
    }
  }

  void skipStep() {
    if (!state.canSkip) return;
    submitResponse('');
  }

  Future<void> _persistProject() async {
    final projectDao = ref.read(projectDaoProvider);
    final projectId = const Uuid().v4();
    await projectDao.insertProject(
      id: projectId,
      name: state.projectName ?? 'Unnamed project',
      description: state.projectDescription,
      techStack: state.techStack != null && state.techStack!.isNotEmpty
          ? state.techStack!.split(',').map((s) => s.trim()).toList()
          : null,
      goals: state.goals != null && state.goals!.isNotEmpty
          ? state.goals!.split(',').map((s) => s.trim()).toList()
          : null,
    );
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
