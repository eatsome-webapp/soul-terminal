// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_dao.dart';

// ignore_for_file: type=lint
mixin _$DecisionDaoMixin on DatabaseAccessor<SoulDatabase> {
  Messages get messages => attachedDatabase.messages;
  Conversations get conversations => attachedDatabase.conversations;
  Decisions get decisions => attachedDatabase.decisions;
  Selectable<Message> messagesForConversation(String conversationId) {
    return customSelect(
      'SELECT * FROM messages WHERE conversation_id = ?1 ORDER BY created_at ASC',
      variables: [Variable<String>(conversationId)],
      readsFrom: {messages},
    ).asyncMap(messages.mapFromRow);
  }

  Selectable<Message> searchMessages(String query) {
    return customSelect(
      'SELECT m.* FROM messages AS m INNER JOIN messages_fts AS f ON m."rowid" = f."rowid" WHERE messages_fts MATCH ?1 ORDER BY rank',
      variables: [Variable<String>(query)],
      readsFrom: {messages},
    ).asyncMap(messages.mapFromRow);
  }

  Selectable<Conversation> allConversations() {
    return customSelect(
      'SELECT * FROM conversations ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationById(String id) {
    return customSelect(
      'SELECT * FROM conversations WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationsSince(int sinceMs) {
    return customSelect(
      'SELECT * FROM conversations WHERE created_at >= ?1 ORDER BY created_at DESC',
      variables: [Variable<int>(sinceMs)],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationsForProject(String? projectId) {
    return customSelect(
      'SELECT * FROM conversations WHERE project_id = ?1 ORDER BY updated_at DESC',
      variables: [Variable<String>(projectId)],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationsWithoutProject() {
    return customSelect(
      'SELECT * FROM conversations WHERE project_id IS NULL ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Decision> allDecisions() {
    return customSelect(
      'SELECT * FROM decisions WHERE is_active = 1 ORDER BY created_at DESC',
      variables: [],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> decisionById(String id) {
    return customSelect(
      'SELECT * FROM decisions WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> decisionsForConversation(String conversationId) {
    return customSelect(
      'SELECT * FROM decisions WHERE conversation_id = ?1 ORDER BY created_at ASC',
      variables: [Variable<String>(conversationId)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> searchDecisions(String query) {
    return customSelect(
      'SELECT d.* FROM decisions AS d INNER JOIN decisions_fts AS f ON d."rowid" = f."rowid" WHERE decisions_fts MATCH ?1 AND d.is_active = 1 ORDER BY rank',
      variables: [Variable<String>(query)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> recentDecisions(int limit) {
    return customSelect(
      'SELECT * FROM decisions WHERE is_active = 1 ORDER BY created_at DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  DecisionDaoManager get managers => DecisionDaoManager(this);
}

class DecisionDaoManager {
  final _$DecisionDaoMixin _db;
  DecisionDaoManager(this._db);
  $MessagesTableManager get messages =>
      $MessagesTableManager(_db.attachedDatabase, _db.messages);
  $ConversationsTableManager get conversations =>
      $ConversationsTableManager(_db.attachedDatabase, _db.conversations);
  $DecisionsTableManager get decisions =>
      $DecisionsTableManager(_db.attachedDatabase, _db.decisions);
}
