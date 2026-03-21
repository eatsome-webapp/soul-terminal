import 'package:freezed_annotation/freezed_annotation.dart';

part 'decision.freezed.dart';
part 'decision.g.dart';

@freezed
abstract class Decision with _$Decision {
  const factory Decision({
    required String id,
    required String conversationId,
    required String messageId,
    required String title,
    required String reasoning,
    required String domain,
    List<String>? alternativesConsidered,
    required DateTime createdAt,
    String? supersededBy,
    @Default(true) bool isActive,
    @Default('active') String status, // 'active', 'superseded', 'deferred'
  }) = _Decision;

  factory Decision.fromJson(Map<String, dynamic> json) =>
      _$DecisionFromJson(json);
}
