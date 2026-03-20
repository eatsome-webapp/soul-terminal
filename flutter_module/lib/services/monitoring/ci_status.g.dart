// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ci_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CiStatus _$CiStatusFromJson(Map<String, dynamic> json) => _CiStatus(
  projectId: json['projectId'] as String,
  health: $enumDecode(_$CiHealthEnumMap, json['health']),
  lastWorkflowName: json['lastWorkflowName'] as String?,
  lastCommitSha: json['lastCommitSha'] as String?,
  lastRunAt: json['lastRunAt'] == null
      ? null
      : DateTime.parse(json['lastRunAt'] as String),
  openPrCount: (json['openPrCount'] as num?)?.toInt() ?? 0,
  stalePrCount: (json['stalePrCount'] as num?)?.toInt() ?? 0,
  recentCommitCount: (json['recentCommitCount'] as num?)?.toInt() ?? 0,
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
);

Map<String, dynamic> _$CiStatusToJson(_CiStatus instance) => <String, dynamic>{
  'projectId': instance.projectId,
  'health': _$CiHealthEnumMap[instance.health]!,
  'lastWorkflowName': instance.lastWorkflowName,
  'lastCommitSha': instance.lastCommitSha,
  'lastRunAt': instance.lastRunAt?.toIso8601String(),
  'openPrCount': instance.openPrCount,
  'stalePrCount': instance.stalePrCount,
  'recentCommitCount': instance.recentCommitCount,
  'checkedAt': instance.checkedAt?.toIso8601String(),
};

const _$CiHealthEnumMap = {
  CiHealth.passing: 'passing',
  CiHealth.failing: 'failing',
  CiHealth.unknown: 'unknown',
};
