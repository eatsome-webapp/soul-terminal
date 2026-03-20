// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_dao.dart';

// ignore_for_file: type=lint
mixin _$ConversationDaoMixin on DatabaseAccessor<SoulDatabase> {
  Messages get messages => attachedDatabase.messages;
  Conversations get conversations => attachedDatabase.conversations;
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

  ConversationDaoManager get managers => ConversationDaoManager(this);
}

class ConversationDaoManager {
  final _$ConversationDaoMixin _db;
  ConversationDaoManager(this._db);
  $MessagesTableManager get messages =>
      $MessagesTableManager(_db.attachedDatabase, _db.messages);
  $ConversationsTableManager get conversations =>
      $ConversationsTableManager(_db.attachedDatabase, _db.conversations);
}
