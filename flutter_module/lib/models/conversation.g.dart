// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessagePreview: json['lastMessagePreview'] as String?,
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastMessagePreview': instance.lastMessagePreview,
    };

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  tokenCount: (json['tokenCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'role': _$MessageRoleEnumMap[instance.role]!,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'tokenCount': instance.tokenCount,
};

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
};
