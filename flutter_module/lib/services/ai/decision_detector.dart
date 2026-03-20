import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/logger.dart';
import '../../services/database/daos/decision_dao.dart';
import '../../services/memory/embedding_service.dart';
import '../../services/memory/vector_store.dart';

/// Tool definition for Claude to call when it detects a strategic decision.
final logDecisionTool = ToolDefinition.custom(
  Tool(
    name: 'log_decision',
    description: 'Log a strategic decision made during this conversation. '
        'Call this whenever the user makes or confirms a significant decision '
        'about their project, strategy, technology, design, or business.',
    inputSchema: InputSchema(
      properties: {
        'title': {
          'type': 'string',
          'description':
              'Brief decision title (e.g., "Use Stripe for payments")',
        },
        'reasoning': {
          'type': 'string',
          'description': 'Why this was decided, including key factors',
        },
        'domain': {
          'type': 'string',
          'enum': ['strategy', 'tech', 'design', 'marketing', 'finance'],
          'description': 'Primary domain of this decision',
        },
        'alternatives_considered': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'What alternatives were discussed before deciding',
        },
      },
      required: ['title', 'reasoning', 'domain'],
    ),
  ),
);

/// Processes tool_use blocks from Claude responses and persists decisions.
class DecisionDetector {
  final DecisionDao _decisionDao;
  final EmbeddingService? _embeddingService;
  final VectorStore? _vectorStore;

  DecisionDetector({
    required DecisionDao decisionDao,
    EmbeddingService? embeddingService,
    VectorStore? vectorStore,
  })  : _decisionDao = decisionDao,
        _embeddingService = embeddingService,
        _vectorStore = vectorStore;

  /// Processes a tool_use input map from Claude's response.
  /// Returns the decision title for snackbar display, or null if processing fails.
  Future<String?> processToolUse({
    required String conversationId,
    required String messageId,
    required Map<String, dynamic> input,
  }) async {
    try {
      final title = input['title'] as String;
      final reasoning = input['reasoning'] as String;
      final domain = input['domain'] as String;
      final alternatives = input['alternatives_considered'] != null
          ? List<String>.from(input['alternatives_considered'] as List)
          : null;

      final decisionId = const Uuid().v4();

      await _decisionDao.insertDecision(
        id: decisionId,
        conversationId: conversationId,
        messageId: messageId,
        title: title,
        reasoning: reasoning,
        domain: domain,
        alternativesConsidered: alternatives,
      );

      log.i('Decision logged: $title ($domain)');

      // Embed the decision async (non-blocking)
      _embedDecision(decisionId, title, reasoning);

      return title;
    } catch (e) {
      log.e('Failed to process decision tool_use: $e');
      return null;
    }
  }

  /// Generates and stores an embedding for a decision (fire-and-forget).
  Future<void> _embedDecision(
    String decisionId,
    String title,
    String reasoning,
  ) async {
    if (_embeddingService == null || _vectorStore == null) return;
    try {
      final text = '$title\n$reasoning';
      final embedding = await _embeddingService!.embed(text);
      if (embedding != null) {
        await _vectorStore!.putEmbedding(
          sourceId: decisionId,
          sourceType: 'decision',
          embedding: embedding,
          sourceText: title,
        );
      }
    } catch (e) {
      log.w('Decision embedding failed (non-critical): $e');
    }
  }
}
