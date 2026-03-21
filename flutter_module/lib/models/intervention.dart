import 'package:freezed_annotation/freezed_annotation.dart';

part 'intervention.freezed.dart';
part 'intervention.g.dart';

enum InterventionLevel { inactive, detected, level1Sent, level2Sent, level3Sent, resolved }
enum InterventionType { stuckness, decisionDelay, inactivity, deadlineProximity, scopeCreep }

@freezed
abstract class InterventionState with _$InterventionState {
  const factory InterventionState({
    required String id,
    required InterventionType type,
    required InterventionLevel level,
    required String triggerDescription,
    String? proposedDefault,
    DateTime? proposalDeadlineAt,
    required DateTime detectedAt,
    DateTime? level1SentAt,
    DateTime? level2SentAt,
    DateTime? level3SentAt,
    DateTime? resolvedAt,
    String? relatedEntityId,
  }) = _InterventionState;

  factory InterventionState.fromJson(Map<String, dynamic> json) =>
      _$InterventionStateFromJson(json);
}
