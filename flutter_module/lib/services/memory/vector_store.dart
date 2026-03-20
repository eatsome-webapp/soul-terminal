import 'package:objectbox/objectbox.dart';
import '../../core/utils/logger.dart';
import '../../models/message_embedding.dart';
import '../../objectbox.g.dart';

/// Wrapper around ObjectBox for vector storage and HNSW nearest-neighbor search.
class VectorStore {
  final Store _store;
  late final Box<MessageEmbedding> _box;

  VectorStore({required Store store})
      : _store = store,
        _box = store.box<MessageEmbedding>();

  /// Stores an embedding for a message or decision.
  /// If an embedding for this sourceId already exists, it is replaced.
  Future<void> putEmbedding({
    required String sourceId,
    required String sourceType,
    required List<double> embedding,
    String? sourceText,
  }) async {
    // Check for existing
    final query =
        _box.query(MessageEmbedding_.sourceId.equals(sourceId)).build();
    final existing = query.findFirst();
    query.close();

    if (existing != null) {
      existing.embedding = embedding;
      existing.sourceText = sourceText;
      _box.put(existing);
    } else {
      _box.put(MessageEmbedding(
        sourceId: sourceId,
        sourceType: sourceType,
        sourceText: sourceText,
        embedding: embedding,
      ));
    }
  }

  /// Finds the nearest neighbors to the given query embedding.
  /// Returns a list of [VectorSearchResult] sorted by similarity.
  Future<List<VectorSearchResult>> findSimilar(
    List<double> queryEmbedding, {
    int maxResults = 5,
    String? filterSourceType,
  }) async {
    try {
      final condition = MessageEmbedding_.embedding.nearestNeighborsF32(
        queryEmbedding,
        maxResults,
      );

      final query = _box.query(condition).build();
      final results = query.findWithScores();
      query.close();

      final filtered = results
          .where((r) =>
              filterSourceType == null ||
              r.object.sourceType == filterSourceType)
          .map((r) => VectorSearchResult(
                sourceId: r.object.sourceId,
                sourceType: r.object.sourceType,
                sourceText: r.object.sourceText,
                score: r.score,
              ))
          .toList();

      return filtered;
    } catch (e) {
      log.e('Vector search failed: $e');
      return [];
    }
  }

  /// Returns the number of stored embeddings.
  int get count => _box.count();

  /// Removes an embedding by source ID.
  Future<void> removeEmbedding(String sourceId) async {
    final query =
        _box.query(MessageEmbedding_.sourceId.equals(sourceId)).build();
    final existing = query.findFirst();
    query.close();
    if (existing != null) {
      _box.remove(existing.obxId);
    }
  }
}

/// Result of a vector similarity search.
class VectorSearchResult {
  final String sourceId;
  final String sourceType;
  final String? sourceText;
  final double score;

  const VectorSearchResult({
    required this.sourceId,
    required this.sourceType,
    this.sourceText,
    required this.score,
  });
}
