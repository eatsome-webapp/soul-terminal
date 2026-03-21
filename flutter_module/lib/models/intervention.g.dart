// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InterventionState _$InterventionStateFromJson(Map<String, dynamic> json) =>
    _InterventionState(
      id: json['id'] as String,
      type: $enumDecode(_$InterventionTypeEnumMap, json['type']),
      level: $enumDecode(_$InterventionLevelEnumMap, json['level']),
      triggerDescription: json['triggerDescription'] as String,
      proposedDefault: json['proposedDefault'] as String?,
      proposalDeadlineAt: json['proposalDeadlineAt'] == null
          ? null
          : DateTime.parse(json['proposalDeadlineAt'] as String),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      level1SentAt: json['level1SentAt'] == null
          ? null
          : DateTime.parse(json['level1SentAt'] as String),
      level2SentAt: json['level2SentAt'] == null
          ? null
          : DateTime.parse(json['level2SentAt'] as String),
      level3SentAt: json['level3SentAt'] == null
          ? null
          : DateTime.parse(json['level3SentAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      relatedEntityId: json['relatedEntityId'] as String?,
    );

Map<String, dynamic> _$InterventionStateToJson(_InterventionState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InterventionTypeEnumMap[instance.type]!,
      'level': _$InterventionLevelEnumMap[instance.level]!,
      'triggerDescription': instance.triggerDescription,
      'proposedDefault': instance.proposedDefault,
      'proposalDeadlineAt': instance.proposalDeadlineAt?.toIso8601String(),
      'detectedAt': instance.detectedAt.toIso8601String(),
      'level1SentAt': instance.level1SentAt?.toIso8601String(),
      'level2SentAt': instance.level2SentAt?.toIso8601String(),
      'level3SentAt': instance.level3SentAt?.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'relatedEntityId': instance.relatedEntityId,
    };

const _$InterventionTypeEnumMap = {
  InterventionType.stuckness: 'stuckness',
  InterventionType.decisionDelay: 'decisionDelay',
  InterventionType.inactivity: 'inactivity',
  InterventionType.deadlineProximity: 'deadlineProximity',
  InterventionType.scopeCreep: 'scopeCreep',
};

const _$InterventionLevelEnumMap = {
  InterventionLevel.inactive: 'inactive',
  InterventionLevel.detected: 'detected',
  InterventionLevel.level1Sent: 'level1Sent',
  InterventionLevel.level2Sent: 'level2Sent',
  InterventionLevel.level3Sent: 'level3Sent',
  InterventionLevel.resolved: 'resolved',
};
