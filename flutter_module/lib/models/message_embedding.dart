import 'package:objectbox/objectbox.dart';

/// ObjectBox entity for storing message/decision vector embeddings.
/// Links to Drift data by message/decision ID (TEXT UUID).
/// Uses HNSW index for efficient nearest-neighbor search.
@Entity()
class MessageEmbedding {
  @Id()
  int obxId = 0;

  /// Links to Drift messages.id or decisions.id (TEXT UUID)
  @Unique()
  String sourceId;

  /// 'message' or 'decision' -- what type of content this embedding represents
  String sourceType;

  /// Text that was embedded (for display/debugging)
  String? sourceText;

  /// Voyage AI voyage-3-lite produces 512-dim vectors
  @HnswIndex(dimensions: 512, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  MessageEmbedding({
    required this.sourceId,
    required this.sourceType,
    this.sourceText,
    this.embedding,
  });
}
