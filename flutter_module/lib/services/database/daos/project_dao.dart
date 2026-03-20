import 'dart:convert';
import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'project_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/projects.drift',
    '../tables/messages.drift',
  },
)
class ProjectDao extends DatabaseAccessor<SoulDatabase>
    with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<List<Project>> getAllProjects() => allProjects().get();
  Future<Project?> getProject(String id) =>
      projectById(id).getSingleOrNull();
  Future<Project?> getActiveProject() =>
      activeProject().getSingleOrNull();
  Future<List<ProjectFact>> getFactsForProject(String projectId) =>
      factsForProject(projectId).get();
  Future<List<Project>> getActiveProjects() => activeProjects().get();
  Future<List<Project>> getProjectsWithDeadlines() =>
      projectsWithDeadlines().get();

  Future<void> setActiveProject(String id) async {
    await customStatement(
        "UPDATE projects SET status = 'inactive' WHERE status = 'active'");
    await (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(
        status: const Value('active'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> insertProject({
    required String id,
    required String name,
    String? description,
    List<String>? techStack,
    List<String>? goals,
    DateTime? deadline,
    String? repoUrl,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(projects).insert(
      ProjectsCompanion.insert(
        id: id,
        name: name,
        description: Value(description),
        techStack: Value(techStack != null ? jsonEncode(techStack) : null),
        goals: Value(goals != null ? jsonEncode(goals) : null),
        deadline: Value(deadline?.millisecondsSinceEpoch),
        repoUrl: Value(repoUrl),
        onboardedAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateProject(
    String id, {
    String? name,
    String? description,
    List<String>? techStack,
    List<String>? goals,
    DateTime? deadline,
    String? repoUrl,
  }) {
    return (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        techStack: techStack != null
            ? Value(jsonEncode(techStack))
            : const Value.absent(),
        goals:
            goals != null ? Value(jsonEncode(goals)) : const Value.absent(),
        deadline: deadline != null
            ? Value(deadline.millisecondsSinceEpoch)
            : const Value.absent(),
        repoUrl: repoUrl != null ? Value(repoUrl) : const Value.absent(),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> insertFact({
    required String id,
    required String projectId,
    required String factKey,
    required String factValue,
    String? sourceMessageId,
  }) {
    return into(projectFacts).insert(
      ProjectFactsCompanion.insert(
        id: id,
        projectId: projectId,
        factKey: factKey,
        factValue: factValue,
        sourceMessageId: Value(sourceMessageId),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
