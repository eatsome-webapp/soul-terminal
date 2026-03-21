import '../../core/utils/logger.dart';
import '../../services/database/daos/decision_dao.dart';
import '../../services/database/daos/distillation_dao.dart';
import '../../services/database/daos/project_dao.dart';
import '../../services/database/daos/profile_dao.dart';
import '../../services/database/soul_database.dart';
import '../memory/embedding_service.dart';
import '../memory/vector_store.dart';

/// Holds retrieved memory context for system prompt injection.
class MemoryContext {
  final String projectContext;
  final String relevantDecisions;
  final String profileTraits;
  final String distilledFacts;

  const MemoryContext({
    this.projectContext = '',
    this.relevantDecisions = '',
    this.profileTraits = '',
    this.distilledFacts = '',
  });

  bool get isEmpty =>
      projectContext.isEmpty &&
      relevantDecisions.isEmpty &&
      profileTraits.isEmpty &&
      distilledFacts.isEmpty;
}

/// Orchestrates context retrieval from all memory sources:
/// Drift DAOs (project, decisions, profile) + ObjectBox vector search.
class MemoryService {
  final DecisionDao _decisionDao;
  final ProjectDao _projectDao;
  final ProfileDao _profileDao;
  final DistillationDao? _distillationDao;
  final EmbeddingService? _embeddingService;
  final VectorStore? _vectorStore;

  MemoryService({
    required DecisionDao decisionDao,
    required ProjectDao projectDao,
    required ProfileDao profileDao,
    DistillationDao? distillationDao,
    EmbeddingService? embeddingService,
    VectorStore? vectorStore,
  })  : _decisionDao = decisionDao,
        _projectDao = projectDao,
        _profileDao = profileDao,
        _distillationDao = distillationDao,
        _embeddingService = embeddingService,
        _vectorStore = vectorStore;

  /// Retrieves relevant context for enriching the next Claude request.
  /// Combines: active project facts, FTS5 + vector decision search, profile traits.
  Future<MemoryContext> getContext(String userMessage,
      {String? projectId}) async {
    try {
      final results = await Future.wait([
        _getProjectContext(projectId: projectId),
        _getRelevantDecisions(userMessage),
        _getProfileTraits(),
        _getDistilledFacts(userMessage),
      ]);

      return MemoryContext(
        projectContext: results[0],
        relevantDecisions: results[1],
        profileTraits: results[2],
        distilledFacts: results[3],
      );
    } catch (e) {
      log.e('Memory context retrieval failed: $e');
      return const MemoryContext();
    }
  }

  Future<String> _getProjectContext({String? projectId}) async {
    try {
      final project = projectId != null
          ? await _projectDao.getProject(projectId)
          : await _projectDao.getActiveProject();
      if (project == null) return '';

      final facts = await _projectDao.getFactsForProject(project.id);

      final buffer = StringBuffer();
      buffer.writeln('Active Project: ${project.name}');
      if (project.description != null) {
        buffer.writeln('Description: ${project.description}');
      }
      if (project.techStack != null) {
        buffer.writeln('Tech Stack: ${project.techStack}');
      }
      if (project.goals != null) {
        buffer.writeln('Goals: ${project.goals}');
      }
      for (final fact in facts) {
        buffer.writeln('- ${fact.factKey}: ${fact.factValue}');
      }
      return buffer.toString().trim();
    } catch (e) {
      log.w('Project context retrieval failed: $e');
      return '';
    }
  }

  Future<String> _getRelevantDecisions(String userMessage) async {
    try {
      // 1. FTS5 keyword search
      final ftsResults =
          await _decisionDao.searchDecisionContent(userMessage);

      // 2. Vector similarity search (if available)
      final vectorIds = <String>{};
      if (_embeddingService != null && _vectorStore != null) {
        final queryEmbedding =
            await _embeddingService!.embedQuery(userMessage);
        if (queryEmbedding != null) {
          final vectorResults = await _vectorStore!.findSimilar(
            queryEmbedding,
            maxResults: 5,
            filterSourceType: 'decision',
          );
          vectorIds.addAll(vectorResults.map((r) => r.sourceId));
        }
      }

      // 3. Also get recent decisions (always relevant)
      final recentDecisions = await _decisionDao.getRecentDecisions(5);

      // 4. Merge and deduplicate, limit to 10
      final seen = <String>{};
      final merged = <Decision>[];

      for (final d in ftsResults) {
        if (seen.add(d.id)) merged.add(d);
      }
      for (final d in recentDecisions) {
        if (seen.add(d.id)) merged.add(d);
      }
      // Vector results are IDs -- load from DAO if not already included
      for (final id in vectorIds) {
        if (seen.add(id)) {
          final d = await _decisionDao.getDecision(id);
          if (d != null) merged.add(d);
        }
      }

      if (merged.isEmpty) return '';

      final buffer = StringBuffer();
      for (final d in merged.take(10)) {
        buffer.writeln('- [${d.domain}] ${d.title}: ${d.reasoning}');
      }
      return buffer.toString().trim();
    } catch (e) {
      log.w('Decision retrieval failed: $e');
      return '';
    }
  }

  Future<String> _getProfileTraits() async {
    try {
      final traits = await _profileDao.getHighConfidenceTraits();
      if (traits.isEmpty) return '';

      final buffer = StringBuffer();
      for (final t in traits) {
        buffer.writeln('- ${t.category}/${t.traitKey}: ${t.traitValue}');
      }
      return buffer.toString().trim();
    } catch (e) {
      log.w('Profile trait retrieval failed: $e');
      return '';
    }
  }

  Future<String> _getDistilledFacts(String userMessage) async {
    if (_distillationDao == null) return '';
    try {
      // Semantic search for distilled facts
      if (_embeddingService != null && _vectorStore != null) {
        final queryEmbedding =
            await _embeddingService!.embedQuery(userMessage);
        if (queryEmbedding != null) {
          final results = await _vectorStore!.findSimilar(
            queryEmbedding,
            maxResults: 5,
            filterSourceType: 'distilled_fact',
          );
          if (results.isNotEmpty) {
            final buffer = StringBuffer();
            for (final r in results) {
              buffer.writeln('- ${r.sourceText}');
            }
            return buffer.toString().trim();
          }
        }
      }

      // Fallback: recent facts from Drift
      final recent = await _distillationDao!.getAllFacts(limit: 10);
      if (recent.isEmpty) return '';
      final buffer = StringBuffer();
      for (final f in recent) {
        buffer.writeln('- [${f.category}] ${f.factValue}');
      }
      return buffer.toString().trim();
    } catch (e) {
      log.w('Distilled facts retrieval failed: $e');
      return '';
    }
  }

  /// Embeds a message asynchronously after persistence (fire-and-forget).
  Future<void> embedMessage(String messageId, String content) async {
    if (_embeddingService == null || _vectorStore == null) return;
    try {
      final embedding = await _embeddingService!.embed(content);
      if (embedding != null) {
        await _vectorStore!.putEmbedding(
          sourceId: messageId,
          sourceType: 'message',
          embedding: embedding,
          sourceText: content.length > 200
              ? '${content.substring(0, 200)}...'
              : content,
        );
      }
    } catch (e) {
      log.w('Message embedding failed (non-critical): $e');
    }
  }
}
