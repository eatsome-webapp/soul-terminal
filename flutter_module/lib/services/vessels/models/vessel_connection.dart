import 'package:freezed_annotation/freezed_annotation.dart';

part 'vessel_connection.freezed.dart';
part 'vessel_connection.g.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

@freezed
abstract class VesselConnection with _$VesselConnection {
  const factory VesselConnection({
    required String vesselId,
    required String vesselName,
    required ConnectionStatus status,
    String? errorMessage,
    DateTime? connectedAt,
    DateTime? lastHealthCheck,
  }) = _VesselConnection;

  factory VesselConnection.fromJson(Map<String, dynamic> json) =>
      _$VesselConnectionFromJson(json);
}
