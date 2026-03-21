import 'package:freezed_annotation/freezed_annotation.dart';

import '../../ai/trust_tier_classifier.dart';
import 'vessel_result.dart';

part 'vessel_task.freezed.dart';

enum VesselType { openClaw, agentSdk }

@freezed
sealed class VesselTask with _$VesselTask {
  const factory VesselTask.proposed({
    required String id,
    required String description,
    required VesselType targetVessel,
    required String toolName,
    required Map<String, dynamic> toolArgs,
    required DateTime proposedAt,
    String? sessionKey,
    @Default(TrustTier.hardApproval) TrustTier tier,
  }) = ProposedTask;

  const factory VesselTask.approved({
    required String id,
    required String description,
    required VesselType targetVessel,
    required String toolName,
    required Map<String, dynamic> toolArgs,
    required DateTime approvedAt,
    String? sessionKey,
    @Default(TrustTier.hardApproval) TrustTier tier,
  }) = ApprovedTask;

  const factory VesselTask.executing({
    required String id,
    required String description,
    required VesselType targetVessel,
    required double progress,
    required String currentStep,
    required DateTime startedAt,
    String? sessionKey,
    @Default(TrustTier.hardApproval) TrustTier tier,
  }) = ExecutingTask;

  const factory VesselTask.completed({
    required String id,
    required String description,
    required VesselType targetVessel,
    required VesselResult result,
    required DateTime completedAt,
    required Duration duration,
    @Default(TrustTier.hardApproval) TrustTier tier,
  }) = CompletedTask;

  const factory VesselTask.failed({
    required String id,
    required String description,
    required VesselType targetVessel,
    required String error,
    required DateTime failedAt,
    @Default(TrustTier.hardApproval) TrustTier tier,
  }) = FailedTask;

  const factory VesselTask.rejected({
    required String id,
    required String description,
    required VesselType targetVessel,
    required DateTime rejectedAt,
    @Default(TrustTier.hardApproval) TrustTier tier,
  }) = RejectedTask;
}
