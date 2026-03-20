import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_trait.freezed.dart';
part 'profile_trait.g.dart';

@freezed
abstract class ProfileTrait with _$ProfileTrait {
  const factory ProfileTrait({
    required String id,
    required String category,
    required String traitKey,
    required String traitValue,
    @Default(0.5) double confidence,
    @Default(1) int evidenceCount,
    required DateTime firstObserved,
    required DateTime lastObserved,
  }) = _ProfileTrait;

  factory ProfileTrait.fromJson(Map<String, dynamic> json) =>
      _$ProfileTraitFromJson(json);
}
