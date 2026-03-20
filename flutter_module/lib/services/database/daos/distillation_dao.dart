import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'distillation_dao.g.dart';

@DriftAccessor(include: {'../tables/distilled_facts.drift'})
class DistillationDao extends DatabaseAccessor<SoulDatabase>
    with _$DistillationDaoMixin {
  DistillationDao(super.db);

  Future<void> insertFact({
    required String id,
    required String conversationId,
    required String category,
    String? factKey,
    required String factValue,
    required double confidence,
    required int distilledAt,
    String? sourceMessageRange,
  }) async {
    await into(distilledFacts).insert(DistilledFactsCompanion.insert(
      id: id,
      conversationId: conversationId,
      category: category,
      factKey: Value(factKey),
      factValue: factValue,
      confidence: Value(confidence),
      distilledAt: distilledAt,
      sourceMessageRange: Value(sourceMessageRange),
    ));
  }

  Future<List<DistilledFact>> getFactsForConversation(String conversationId) {
    return (select(distilledFacts)
          ..where((f) => f.conversationId.equals(conversationId)))
        .get();
  }

  Future<List<DistilledFact>> getAllFacts({int limit = 100}) {
    return (select(distilledFacts)
          ..orderBy([(f) => OrderingTerm.desc(f.distilledAt)])
          ..limit(limit))
        .get();
  }

  Future<List<DistilledFact>> getFactsByCategory(String category) {
    return (select(distilledFacts)
          ..where((f) => f.category.equals(category)))
        .get();
  }
}
