import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'conversation_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/conversations.drift',
    '../tables/messages.drift',
  },
)
class ConversationDao extends DatabaseAccessor<SoulDatabase>
    with _$ConversationDaoMixin {
  ConversationDao(super.db);

  // --- Conversations ---

  Future<List<Conversation>> getAllConversations() {
    return allConversations().get();
  }

  Stream<List<Conversation>> watchAllConversations() {
    return allConversations().watch();
  }

  Future<Conversation?> getConversation(String id) {
    return conversationById(id).getSingleOrNull();
  }

  Future<List<Conversation>> getConversationsForProject(String projectId) {
    return conversationsForProject(projectId).get();
  }

  Future<List<Conversation>> getConversationsWithoutProject() {
    return conversationsWithoutProject().get();
  }

  Future<void> createConversation({
    required String id,
    required String title,
    String? projectId,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(conversations).insert(
      ConversationsCompanion.insert(
        id: id,
        title: Value(title),
        projectId: Value(projectId),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateConversationTitle(String id, String title) {
    return (update(conversations)..where((c) => c.id.equals(id))).write(
      ConversationsCompanion(
        title: Value(title),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> updateConversationPreview(String id, String preview) {
    return (update(conversations)..where((c) => c.id.equals(id))).write(
      ConversationsCompanion(
        lastMessagePreview: Value(preview),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<int> deleteConversation(String id) {
    return (delete(conversations)..where((c) => c.id.equals(id))).go();
  }

  // --- Messages ---

  Future<List<Message>> getMessagesForConversation(String conversationId) {
    return messagesForConversation(conversationId).get();
  }

  Stream<List<Message>> watchMessagesForConversation(String conversationId) {
    return messagesForConversation(conversationId).watch();
  }

  Future<void> insertMessage({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    int? tokenCount,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(messages).insert(
      MessagesCompanion.insert(
        id: id,
        conversationId: conversationId,
        role: role,
        content: content,
        createdAt: now,
        tokenCount: Value(tokenCount),
      ),
    );
  }

  Future<void> updateMessageContent(String id, String content) {
    return (update(messages)..where((m) => m.id.equals(id))).write(
      MessagesCompanion(content: Value(content)),
    );
  }

  Future<List<Conversation>> getConversationsSince(int sinceMs) {
    return conversationsSince(sinceMs).get();
  }

  // --- Search ---

  Future<List<Message>> searchMessageContent(String query) {
    return searchMessages(query).get();
  }

  /// Count messages in a conversation.
  Future<int> getMessageCount(String conversationId) async {
    final count = await customSelect(
      'SELECT COUNT(*) AS cnt FROM messages WHERE conversation_id = ?',
      variables: [Variable.withString(conversationId)],
      readsFrom: {messages},
    ).getSingle();
    return count.read<int>('cnt');
  }

  /// Get messages older than a given timestamp (for cold migration).
  Future<List<Message>> getMessagesOlderThan(int epochMs, {int limit = 10}) {
    return (select(messages)
          ..where((m) => m.createdAt.isSmallerThanValue(epochMs))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Get messages for a conversation in a range (for distillation input).
  Future<List<Message>> getMessagesInRange(String conversationId, {int offset = 0, int limit = 100}) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Count messages matching a topic via FTS5, created after [sinceEpoch].
  Future<int> countMessagesMatchingTopic(String topic, int sinceEpoch) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS c FROM messages_fts '
      'WHERE messages_fts MATCH ? '
      'AND rowid IN (SELECT rowid FROM messages WHERE created_at > ?)',
      variables: [Variable.withString(topic), Variable.withInt(sinceEpoch)],
    ).getSingle();
    return result.read<int>('c');
  }

  /// Get the timestamp of the most recent user message.
  Future<int?> getLastMessageTimestamp() async {
    final result = await customSelect(
      "SELECT MAX(created_at) AS ts FROM messages WHERE role = 'user'",
    ).getSingleOrNull();
    return result?.readNullable<int>('ts');
  }
}
