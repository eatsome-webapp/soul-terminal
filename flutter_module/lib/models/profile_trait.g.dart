// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_trait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileTrait _$ProfileTraitFromJson(Map<String, dynamic> json) =>
    _ProfileTrait(
      id: json['id'] as String,
      category: json['category'] as String,
      traitKey: json['traitKey'] as String,
      traitValue: json['traitValue'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      evidenceCount: (json['evidenceCount'] as num?)?.toInt() ?? 1,
      firstObserved: DateTime.parse(json['firstObserved'] as String),
      lastObserved: DateTime.parse(json['lastObserved'] as String),
    );

Map<String, dynamic> _$ProfileTraitToJson(_ProfileTrait instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'traitKey': instance.traitKey,
      'traitValue': instance.traitValue,
      'confidence': instance.confidence,
      'evidenceCount': instance.evidenceCount,
      'firstObserved': instance.firstObserved.toIso8601String(),
      'lastObserved': instance.lastObserved.toIso8601String(),
    };
