import 'package:uuid/uuid.dart';
import '../../core/utils/logger.dart';
import '../ai/claude_service.dart';
import '../database/daos/conversation_dao.dart';
import '../database/daos/distillation_dao.dart';
import '../memory/embedding_service.dart';
import '../memory/vector_store.dart';

/// Extracts structured facts from conversations every 100 messages.
///
/// Uses Haiku for cheap, fast classification. Dual-writes facts to
/// Drift (distilled_facts table) and VectorStore (for semantic search).
class DistillationService {
  final ClaudeService _claudeService;
  final ConversationDao _conversationDao;
  final DistillationDao _distillationDao;
  final EmbeddingService? _embeddingService;
  final VectorStore? _vectorStore;

  static const int defaultThreshold = 100;
  final Map<String, int> _messageCounters = {};

  DistillationService({
    required ClaudeService claudeService,
    required ConversationDao conversationDao,
    required DistillationDao distillationDao,
    EmbeddingService? embeddingService,
    VectorStore? vectorStore,
  })  : _claudeService = claudeService,
        _conversationDao = conversationDao,
        _distillationDao = distillationDao,
        _embeddingService = embeddingService,
        _vectorStore = vectorStore;

  void incrementCounter(String conversationId) {
    _messageCounters[conversationId] =
        (_messageCounters[conversationId] ?? 0) + 1;
  }

  bool shouldDistill(String conversationId,
      {int threshold = defaultThreshold}) {
    return (_messageCounters[conversationId] ?? 0) >= threshold;
  }

  Future<void> distill(String conversationId,
      {int threshold = defaultThreshold}) async {
    try {
      final messageCount = _messageCounters[conversationId] ?? 0;
      if (messageCount < threshold) return;

      final offset = messageCount - threshold;
      final messages = await _conversationDao.getMessagesInRange(
        conversationId,
        offset: offset > 0 ? offset : 0,
        limit: threshold,
      );
      if (messages.isEmpty) return;

      final conversationText =
          messages.map((m) => '[${m.role}]: ${m.content}').join('\n');

      final prompt =
          '''Analyze this conversation and extract structured information.
Return a JSON object with exactly these 4 categories:
{
  "facts": [{"key": "short_id", "value": "what is true", "confidence": 0.9}],
  "decisions": [{"title": "what was decided", "reasoning": "why", "domain": "tech/strategy/design/marketing/finance"}],
  "open_questions": ["question that remains unanswered"],
  "unvalidated_assumptions": ["assumption not yet tested"]
}

Only return valid JSON, nothing else.

Conversation:
$conversationText''';

      final result =
          await _claudeService.analyzeWithHaiku(prompt, maxTokens: 1024);
      final range = '${offset > 0 ? offset : 0}-${offset + messages.length}';
      final now = DateTime.now().millisecondsSinceEpoch;
      final uuid = const Uuid();

      // Store facts
      final facts = result['facts'] as List<dynamic>? ?? [];
      for (final fact in facts) {
        final map = fact as Map<String, dynamic>;
        final factId = uuid.v4();
        await _distillationDao.insertFact(
          id: factId,
          conversationId: conversationId,
          category: 'fact',
          factKey: map['key'] as String?,
          factValue: map['value'] as String? ?? '',
          confidence: (map['confidence'] as num?)?.toDouble() ?? 0.8,
          distilledAt: now,
          sourceMessageRange: range,
        );
        await _embedFact(factId, map['value'] as String? ?? '');
      }

      // Store open questions
      final questions = result['open_questions'] as List<dynamic>? ?? [];
      for (final q in questions) {
        final factId = uuid.v4();
        await _distillationDao.insertFact(
          id: factId,
          conversationId: conversationId,
          category: 'open_question',
          factValue: q as String,
          confidence: 0.7,
          distilledAt: now,
          sourceMessageRange: range,
        );
      }

      // Store assumptions
      final assumptions =
          result['unvalidated_assumptions'] as List<dynamic>? ?? [];
      for (final a in assumptions) {
        final factId = uuid.v4();
        await _distillationDao.insertFact(
          id: factId,
          conversationId: conversationId,
          category: 'assumption',
          factValue: a as String,
          confidence: 0.5,
          distilledAt: now,
          sourceMessageRange: range,
        );
      }

      // Reset counter
      _messageCounters[conversationId] = 0;
      log.i(
          'Distillation complete for $conversationId: ${facts.length} facts, ${questions.length} questions, ${assumptions.length} assumptions');
    } catch (e) {
      log.e('Distillation failed for $conversationId: $e');
      // Non-blocking: will retry on next check
    }
  }

  Future<void> _embedFact(String factId, String content) async {
    if (_embeddingService == null || _vectorStore == null) return;
    try {
      final embedding = await _embeddingService!.embed(content);
      if (embedding != null) {
        await _vectorStore!.putEmbedding(
          sourceId: factId,
          sourceType: 'distilled_fact',
          embedding: embedding,
          sourceText: content.length > 200
              ? '${content.substring(0, 200)}...'
              : content,
        );
      }
    } catch (e) {
      log.w('Fact embedding failed (non-critical): $e');
    }
  }
}
