// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Decision _$DecisionFromJson(Map<String, dynamic> json) => _Decision(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  messageId: json['messageId'] as String,
  title: json['title'] as String,
  reasoning: json['reasoning'] as String,
  domain: json['domain'] as String,
  alternativesConsidered: (json['alternativesConsidered'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  supersededBy: json['supersededBy'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  status: json['status'] as String? ?? 'active',
);

Map<String, dynamic> _$DecisionToJson(_Decision instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'messageId': instance.messageId,
  'title': instance.title,
  'reasoning': instance.reasoning,
  'domain': instance.domain,
  'alternativesConsidered': instance.alternativesConsidered,
  'createdAt': instance.createdAt.toIso8601String(),
  'supersededBy': instance.supersededBy,
  'isActive': instance.isActive,
  'status': instance.status,
};
