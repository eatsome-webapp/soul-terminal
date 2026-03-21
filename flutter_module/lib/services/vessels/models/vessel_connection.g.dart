// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vessel_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VesselConnection _$VesselConnectionFromJson(Map<String, dynamic> json) =>
    _VesselConnection(
      vesselId: json['vesselId'] as String,
      vesselName: json['vesselName'] as String,
      status: $enumDecode(_$ConnectionStatusEnumMap, json['status']),
      errorMessage: json['errorMessage'] as String?,
      connectedAt: json['connectedAt'] == null
          ? null
          : DateTime.parse(json['connectedAt'] as String),
      lastHealthCheck: json['lastHealthCheck'] == null
          ? null
          : DateTime.parse(json['lastHealthCheck'] as String),
    );

Map<String, dynamic> _$VesselConnectionToJson(_VesselConnection instance) =>
    <String, dynamic>{
      'vesselId': instance.vesselId,
      'vesselName': instance.vesselName,
      'status': _$ConnectionStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'connectedAt': instance.connectedAt?.toIso8601String(),
      'lastHealthCheck': instance.lastHealthCheck?.toIso8601String(),
    };

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.disconnected: 'disconnected',
  ConnectionStatus.connecting: 'connecting',
  ConnectionStatus.connected: 'connected',
  ConnectionStatus.error: 'error',
};
