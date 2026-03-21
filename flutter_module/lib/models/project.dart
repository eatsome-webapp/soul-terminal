import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    String? description,
    List<String>? techStack,
    List<String>? goals,
    DateTime? deadline,
    String? repoUrl,
    @Default('active') String status,
    required DateTime onboardedAt,
    required DateTime updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

@freezed
abstract class ProjectFact with _$ProjectFact {
  const factory ProjectFact({
    required String id,
    required String projectId,
    required String key,
    required String value,
    String? sourceMessageId,
    required DateTime createdAt,
  }) = _ProjectFact;

  factory ProjectFact.fromJson(Map<String, dynamic> json) =>
      _$ProjectFactFromJson(json);
}
