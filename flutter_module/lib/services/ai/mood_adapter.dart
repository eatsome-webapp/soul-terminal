import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../models/mood_state.dart';
import '../database/daos/mood_dao.dart';
import 'claude_service.dart';
import 'intervention_config.dart';

/// Analyzes user mood via Haiku sidecar calls every N messages.
///
/// Returns energy (1-5), emotion (Plutchik primary), and intent
/// (action/reflection/vent). Persists mood state per session in Drift.
class MoodAdapter {
  final ClaudeService _claudeService;
  final MoodDao _moodDao;
  final Logger _logger = Logger();
  int _messageCounter = 0;
  MoodState? _currentMood;
  final int _analysisFrequency;

  MoodAdapter({
    required ClaudeService claudeService,
    required MoodDao moodDao,
    int analysisFrequency = 3,
  })  : _claudeService = claudeService,
        _moodDao = moodDao,
        _analysisFrequency = analysisFrequency;

  /// Current mood state (null if not yet analyzed).
  MoodState? get currentMood => _currentMood;

  /// Call after each user message. Triggers Haiku analysis every
  /// [_analysisFrequency] messages.
  ///
  /// [recentMessages] should contain the last 3-5 user messages as strings.
  /// [sessionId] is the current conversation/session ID.
  Future<MoodState?> onUserMessage({
    required List<String> recentMessages,
    required String sessionId,
  }) async {
    _messageCounter++;
    if (_messageCounter % _analysisFrequency != 0) return _currentMood;
    if (recentMessages.isEmpty) return _currentMood;

    try {
      final messagesToAnalyze = recentMessages.take(3).join('\n---\n');
      final prompt =
          '''Analyze these messages from a solo founder. Return JSON only, no other text.
Messages:
$messagesToAnalyze

Return: {"energy": N, "emotion": "E", "intent": "I"}
Rules:
- energy: 1=exhausted/frustrated, 2=low/tired, 3=neutral, 4=motivated, 5=energized/excited
- emotion: one of: joy, trust, fear, surprise, sadness, disgust, anger, anticipation
- intent: one of: action (wants to do something), reflection (thinking/exploring), vent (expressing frustration)''';

      final result = await _claudeService.analyzeWithHaiku(prompt);

      final energy = (result['energy'] as num?)?.toInt() ?? 3;
      final emotion = result['emotion'] as String? ?? 'anticipation';
      final intent = result['intent'] as String? ?? 'action';

      final mood = MoodState(
        id: const Uuid().v4(),
        sessionId: sessionId,
        energy: energy.clamp(1, 5),
        emotion: _validateEmotion(emotion),
        intent: _validateIntent(intent),
        analyzedAt: DateTime.now(),
        messageCount: _messageCounter,
      );

      await _moodDao.insertMoodEntry(
        id: mood.id,
        sessionId: mood.sessionId,
        energy: mood.energy,
        emotion: mood.emotion,
        intent: mood.intent,
        analyzedAt: mood.analyzedAt.millisecondsSinceEpoch,
        messageCount: mood.messageCount,
      );
      _currentMood = mood;

      _logger.i(
          'MoodAdapter: energy=$energy, emotion=$emotion, intent=$intent');
      return mood;
    } catch (e) {
      _logger.w('MoodAdapter analysis failed: $e');
      return _currentMood;
    }
  }

  /// Restore mood state for existing session.
  Future<void> restoreSessionMood(String sessionId) async {
    final row = await _moodDao.getLatestForSession(sessionId);
    if (row == null) return;
    _currentMood = MoodState(
      id: row.id,
      sessionId: row.sessionId,
      energy: row.energy,
      emotion: row.emotion,
      intent: row.intent,
      analyzedAt: DateTime.fromMillisecondsSinceEpoch(row.analyzedAt),
      messageCount: row.messageCount,
    );
  }

  String _validateEmotion(String emotion) {
    const valid = [
      'joy',
      'trust',
      'fear',
      'surprise',
      'sadness',
      'disgust',
      'anger',
      'anticipation',
    ];
    return valid.contains(emotion) ? emotion : 'anticipation';
  }

  String _validateIntent(String intent) {
    const valid = ['action', 'reflection', 'vent'];
    return valid.contains(intent) ? intent : 'action';
  }
}
