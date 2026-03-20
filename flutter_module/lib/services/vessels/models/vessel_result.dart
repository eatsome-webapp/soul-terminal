import 'package:freezed_annotation/freezed_annotation.dart';

part 'vessel_result.freezed.dart';
part 'vessel_result.g.dart';

@freezed
abstract class VesselResult with _$VesselResult {
  const factory VesselResult({
    required String taskId,
    String? terminalOutput,
    String? codeDiff,
    String? screenshotBase64,
    @Default([]) List<String> links,
    String? summary,
    @Default({}) Map<String, dynamic> rawResponse,
  }) = _VesselResult;

  factory VesselResult.fromJson(Map<String, dynamic> json) =>
      _$VesselResultFromJson(json);
}
