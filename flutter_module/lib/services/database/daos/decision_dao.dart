import 'dart:convert';
import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'decision_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/decisions.drift',
    '../tables/conversations.drift',
    '../tables/messages.drift',
  },
)
class DecisionDao extends DatabaseAccessor<SoulDatabase>
    with _$DecisionDaoMixin {
  DecisionDao(super.db);

  Future<List<Decision>> getAllDecisions() => allDecisions().get();
  Stream<List<Decision>> watchAllDecisions() => allDecisions().watch();
  Future<Decision?> getDecision(String id) =>
      decisionById(id).getSingleOrNull();
  Future<List<Decision>> getDecisionsForConversation(String conversationId) =>
      decisionsForConversation(conversationId).get();
  Future<List<Decision>> searchDecisionContent(String query) =>
      searchDecisions(query).get();
  Future<List<Decision>> getRecentDecisions(int limit) =>
      recentDecisions(limit).get();

  Future<void> insertDecision({
    required String id,
    required String conversationId,
    required String messageId,
    required String title,
    required String reasoning,
    required String domain,
    List<String>? alternativesConsidered,
    String status = 'active',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(decisions).insert(
      DecisionsCompanion.insert(
        id: id,
        conversationId: conversationId,
        messageId: messageId,
        title: title,
        reasoning: reasoning,
        domain: domain,
        alternativesConsidered: Value(
          alternativesConsidered != null
              ? jsonEncode(alternativesConsidered)
              : null,
        ),
        createdAt: now,
        isActive: const Value(1),
        status: Value(status),
      ),
    );
  }

  Future<void> supersedeDecision(String oldId, String newId) {
    return (update(decisions)..where((d) => d.id.equals(oldId))).write(
      DecisionsCompanion(
        supersededBy: Value(newId),
        isActive: const Value(0),
      ),
    );
  }

  Future<int> deleteDecision(String id) =>
      (delete(decisions)..where((d) => d.id.equals(id))).go();
}
