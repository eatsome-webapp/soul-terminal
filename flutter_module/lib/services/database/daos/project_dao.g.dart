// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dao.dart';

// ignore_for_file: type=lint
mixin _$ProjectDaoMixin on DatabaseAccessor<SoulDatabase> {
  Messages get messages => attachedDatabase.messages;
  Projects get projects => attachedDatabase.projects;
  ProjectFacts get projectFacts => attachedDatabase.projectFacts;
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

  Selectable<Project> allProjects() {
    return customSelect(
      'SELECT * FROM projects ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Project> projectById(String id) {
    return customSelect(
      'SELECT * FROM projects WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Project> activeProject() {
    return customSelect(
      'SELECT * FROM projects WHERE status = \'active\' ORDER BY updated_at DESC LIMIT 1',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<ProjectFact> factsForProject(String projectId) {
    return customSelect(
      'SELECT * FROM project_facts WHERE project_id = ?1 ORDER BY created_at ASC',
      variables: [Variable<String>(projectId)],
      readsFrom: {projectFacts},
    ).asyncMap(projectFacts.mapFromRow);
  }

  Selectable<Project> activeProjects() {
    return customSelect(
      'SELECT * FROM projects WHERE status = \'active\' ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Project> projectsWithDeadlines() {
    return customSelect(
      'SELECT * FROM projects WHERE deadline IS NOT NULL AND status = \'active\' ORDER BY deadline ASC',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  ProjectDaoManager get managers => ProjectDaoManager(this);
}

class ProjectDaoManager {
  final _$ProjectDaoMixin _db;
  ProjectDaoManager(this._db);
  $MessagesTableManager get messages =>
      $MessagesTableManager(_db.attachedDatabase, _db.messages);
  $ProjectsTableManager get projects =>
      $ProjectsTableManager(_db.attachedDatabase, _db.projects);
  $ProjectFactsTableManager get projectFacts =>
      $ProjectFactsTableManager(_db.attachedDatabase, _db.projectFacts);
}
