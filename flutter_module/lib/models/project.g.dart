// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  techStack: (json['techStack'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  goals: (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList(),
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  repoUrl: json['repoUrl'] as String?,
  status: json['status'] as String? ?? 'active',
  onboardedAt: DateTime.parse(json['onboardedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'techStack': instance.techStack,
  'goals': instance.goals,
  'deadline': instance.deadline?.toIso8601String(),
  'repoUrl': instance.repoUrl,
  'status': instance.status,
  'onboardedAt': instance.onboardedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_ProjectFact _$ProjectFactFromJson(Map<String, dynamic> json) => _ProjectFact(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  key: json['key'] as String,
  value: json['value'] as String,
  sourceMessageId: json['sourceMessageId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ProjectFactToJson(_ProjectFact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'key': instance.key,
      'value': instance.value,
      'sourceMessageId': instance.sourceMessageId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
