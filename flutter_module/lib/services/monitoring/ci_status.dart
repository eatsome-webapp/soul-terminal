import 'package:freezed_annotation/freezed_annotation.dart';

part 'ci_status.freezed.dart';
part 'ci_status.g.dart';

enum CiHealth { passing, failing, unknown }

@freezed
abstract class CiStatus with _$CiStatus {
  const factory CiStatus({
    required String projectId,
    required CiHealth health,
    String? lastWorkflowName,
    String? lastCommitSha,
    DateTime? lastRunAt,
    @Default(0) int openPrCount,
    @Default(0) int stalePrCount,
    @Default(0) int recentCommitCount,
    DateTime? checkedAt,
  }) = _CiStatus;

  factory CiStatus.fromJson(Map<String, dynamic> json) =>
      _$CiStatusFromJson(json);
}
