import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/memory/memory_service.dart';

part 'prompt_context.freezed.dart';

/// Mood state detected from recent messages.
///
/// Populated by MoodAdapter (Plan 07-03). Null until then.
class MoodState {
  final int energy;
  final String emotion;
  final String intent;

  const MoodState({
    this.energy = 3,
    this.emotion = 'neutral',
    this.intent = 'action',
  });
}

/// Project state context for system prompt injection.
///
/// Populated when project tracking is active. Null until then.
class ProjectState {
  final String? phase;
  final String? deadline;
  final List<String> risks;
  final List<String> assumptions;

  const ProjectState({
    this.phase,
    this.deadline,
    this.risks = const [],
    this.assumptions = const [],
  });
}

/// Open question tracked by the DecisionTracker (Plan 07-03).
class OpenQuestion {
  final String question;
  final DateTime openSince;
  final String? proposedDefault;

  const OpenQuestion({
    required this.question,
    required this.openSince,
    this.proposedDefault,
  });

  /// Alias for backward compatibility with layers using createdAt.
  DateTime get createdAt => openSince;
}

/// Summary of a connected vessel's capabilities for the system prompt.
class VesselCapabilitySummary {
  final String vesselId;
  final String vesselName;
  final String status;
  final List<String> capabilityGroups;

  const VesselCapabilitySummary({
    required this.vesselId,
    required this.vesselName,
    required this.status,
    this.capabilityGroups = const [],
  });
}

/// Unified context object passed to all prompt layers.
///
/// Replaces separate `memoryContext` and `phoneContext` params
/// in [ClaudeService.streamMessage].
@freezed
abstract class PromptContext with _$PromptContext {
  const factory PromptContext({
    @Default(null) MemoryContext? memory,
    @Default(null) String? phoneContext,
    @Default(null) MoodState? moodState,
    @Default(null) ProjectState? projectState,
    @Default(null) List<OpenQuestion>? openQuestions,
    @Default('nl') String detectedLanguage,
    @Default(null) DateTime? firstInteractionDate,
    @Default(0) int totalConversationCount,
    @Default('') String distilledFacts,
    @Default(null) String? extractedProjectStatus,
    @Default(null) String? extractedRiskiestItem,
    @Default(null) String? extractedAssumptions,
    @Default(null) double? momentumScore,
    @Default(null) List<VesselCapabilitySummary>? connectedVessels,
    @Default(null) int? vesselBootstrapStep,
  }) = _PromptContext;
}
