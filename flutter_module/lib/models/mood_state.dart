import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_state.freezed.dart';
part 'mood_state.g.dart';

@freezed
abstract class MoodState with _$MoodState {
  const factory MoodState({
    required String id,
    required String sessionId,
    required int energy, // 1-5
    required String
        emotion, // Plutchik: joy, trust, fear, surprise, sadness, disgust, anger, anticipation
    required String intent, // action, reflection, vent
    required DateTime analyzedAt,
    required int messageCount, // which message number triggered this analysis
  }) = _MoodState;

  factory MoodState.fromJson(Map<String, dynamic> json) =>
      _$MoodStateFromJson(json);
}
