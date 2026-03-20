// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vessel_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VesselResult _$VesselResultFromJson(Map<String, dynamic> json) =>
    _VesselResult(
      taskId: json['taskId'] as String,
      terminalOutput: json['terminalOutput'] as String?,
      codeDiff: json['codeDiff'] as String?,
      screenshotBase64: json['screenshotBase64'] as String?,
      links:
          (json['links'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      summary: json['summary'] as String?,
      rawResponse: json['rawResponse'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VesselResultToJson(_VesselResult instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'terminalOutput': instance.terminalOutput,
      'codeDiff': instance.codeDiff,
      'screenshotBase64': instance.screenshotBase64,
      'links': instance.links,
      'summary': instance.summary,
      'rawResponse': instance.rawResponse,
    };
