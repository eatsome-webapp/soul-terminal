import 'package:logger/logger.dart';
import '../database/daos/briefing_dao.dart';
import '../database/daos/conversation_dao.dart';
import '../database/daos/decision_dao.dart';
import '../platform/local_notification_service.dart';

/// Detects when the user is stuck (circling same topic without decisions)
/// and generates proactive nudges.
///
/// v1 approach: FTS5-based topic repetition counting.
/// Score = (conversationCount - decisionCount) / conversationCount when >= 3 conversations.
class StucknessDetector {
  final ConversationDao _conversationDao;
  final DecisionDao _decisionDao;
  final BriefingDao _briefingDao;
  final LocalNotificationService _notificationService;
  final Logger _logger = Logger();

  /// Stuckness score threshold (0.0 to 1.0). Above this triggers a nudge.
  double threshold = 0.6;

  /// Cooldown period in days for same-topic nudges.
  int cooldownDays = 7;

  StucknessDetector({
    required ConversationDao conversationDao,
    required DecisionDao decisionDao,
    required BriefingDao briefingDao,
    required LocalNotificationService notificationService,
    double threshold = 0.6,
    int cooldownDays = 7,
  })  : _conversationDao = conversationDao,
        _decisionDao = decisionDao,
        _briefingDao = briefingDao,
        _notificationService = notificationService,
        threshold = threshold,
        cooldownDays = cooldownDays;

  /// Run stuckness detection across recent conversations.
  /// Identifies topics with high conversation count and low decision count.
  /// Returns list of topics where user appears stuck.
  Future<List<StucknessResult>> detectStuckness() async {
    // Get recent conversation titles/topics (last 14 days)
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14)).millisecondsSinceEpoch;
    final recentConversations = await _conversationDao.getConversationsSince(twoWeeksAgo);

    if (recentConversations.isEmpty) return [];

    // Extract topics from conversation titles (simple keyword extraction)
    final topicCounts = <String, int>{};
    for (final conv in recentConversations) {
      final title = conv.title.toLowerCase();
      if (title.isEmpty) continue;

      // Simple topic extraction: use significant words (>3 chars)
      final words = title.split(RegExp(r'\s+'))
          .where((w) => w.length > 3)
          .where((w) => !_stopWords.contains(w));

      for (final word in words) {
        topicCounts[word] = (topicCounts[word] ?? 0) + 1;
      }
    }

    // Find topics with 3+ mentions
    final stuckTopics = <StucknessResult>[];
    for (final entry in topicCounts.entries) {
      if (entry.value < 3) continue;

      // Check decisions related to this topic
      final relatedDecisions = await _decisionDao.searchDecisionContent(entry.key);
      final decisionCount = relatedDecisions.length;

      // Check content-based mentions via FTS5
      final contentMentions = await _countTopicMentionsInContent(entry.key, twoWeeksAgo);
      final totalSignal = entry.value + (contentMentions > 5 ? contentMentions ~/ 3 : 0);

      // Score: higher = more stuck
      final score = (totalSignal - decisionCount) / totalSignal;
      if (score < 0) continue;

      stuckTopics.add(StucknessResult(
        topic: entry.key,
        conversationCount: entry.value,
        decisionCount: decisionCount,
        score: score.clamp(0.0, 1.0),
      ));

      // Store signal in database
      await _briefingDao.upsertStucknessSignal(
        topic: entry.key,
        conversationCount: entry.value,
        decisionCount: decisionCount,
        firstSeen: twoWeeksAgo,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
        score: score.clamp(0.0, 1.0),
      );
    }

    // Sort by score descending
    stuckTopics.sort((a, b) => b.score.compareTo(a.score));

    _logger.i('Stuckness detection found ${stuckTopics.length} potential stuck topics');
    return stuckTopics;
  }

  /// Generate and deliver a nudge for the highest-scoring stuck topic.
  /// Respects cooldown: won't nudge same topic within [cooldownDays].
  Future<String?> generateNudge() async {
    final activeSignals = await _briefingDao.getActiveSignals(threshold);
    if (activeSignals.isEmpty) return null;

    final topSignal = activeSignals.first;

    // Check cooldown
    final lastSeen = DateTime.fromMillisecondsSinceEpoch(topSignal.lastSeen);
    final daysSinceLastSeen = DateTime.now().difference(lastSeen).inDays;
    if (daysSinceLastSeen < cooldownDays && topSignal.nudgeSent != 0) {
      _logger.d('Nudge for "${topSignal.topic}" in cooldown');
      return null;
    }

    final nudgeMessage = 'You\'ve been thinking about "${topSignal.topic}" for a few days without landing on a decision. Want me to help you work through it?';

    // Show notification
    await _notificationService.showNudgeNotification(
      title: 'I noticed something',
      body: nudgeMessage,
      payload: 'nudge:${topSignal.topic}',
    );

    // Mark nudge as sent
    await _briefingDao.markNudgeSent(topSignal.id);

    _logger.i('Nudge sent for topic: ${topSignal.topic} (score: ${topSignal.score})');
    return nudgeMessage;
  }

  /// Search message content via FTS5 for topic repetition across conversations.
  /// Returns count of messages matching the topic in different conversations.
  Future<int> _countTopicMentionsInContent(String topic, int sinceMsEpoch) async {
    return await _conversationDao.countMessagesMatchingTopic(topic, sinceMsEpoch);
  }

  /// Check if user has been inactive beyond threshold.
  /// Returns true if last interaction was more than [thresholdHours] ago.
  Future<bool> detectInactivity(int thresholdHours) async {
    final lastMessage = await _conversationDao.getLastMessageTimestamp();
    if (lastMessage == null) return false;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastMessage),
    );
    return elapsed.inHours >= thresholdHours;
  }

  /// Common stop words to ignore in topic extraction.
  static const _stopWords = {
    'the', 'and', 'for', 'that', 'this', 'with', 'from', 'what',
    'how', 'about', 'have', 'been', 'would', 'could', 'should',
    'will', 'does', 'when', 'where', 'which', 'your', 'more',
    'some', 'also', 'just', 'like', 'into', 'than', 'them',
    'then', 'only', 'very', 'want', 'need', 'make', 'know',
  };
}

/// Result of stuckness detection for a single topic.
class StucknessResult {
  final String topic;
  final int conversationCount;
  final int decisionCount;
  final double score;

  const StucknessResult({
    required this.topic,
    required this.conversationCount,
    required this.decisionCount,
    required this.score,
  });
}
