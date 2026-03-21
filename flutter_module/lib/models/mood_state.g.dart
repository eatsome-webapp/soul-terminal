// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoodState _$MoodStateFromJson(Map<String, dynamic> json) => _MoodState(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  energy: (json['energy'] as num).toInt(),
  emotion: json['emotion'] as String,
  intent: json['intent'] as String,
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
  messageCount: (json['messageCount'] as num).toInt(),
);

Map<String, dynamic> _$MoodStateToJson(_MoodState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'energy': instance.energy,
      'emotion': instance.emotion,
      'intent': instance.intent,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'messageCount': instance.messageCount,
    };
