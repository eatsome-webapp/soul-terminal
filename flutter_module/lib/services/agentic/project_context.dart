import 'dart:io';
import '../../core/utils/logger.dart';

/// Represents a user's target project directory for agentic operations.
///
/// Scans the project on creation to build a file tree, detect the
/// language/framework, and load any project instruction file.
class ProjectContext {
  /// Absolute path to the project root directory.
  final String rootPath;

  /// File tree string (for system prompt injection).
  final String fileTree;

  /// Detected primary language (e.g., 'dart', 'typescript', 'python').
  final String? detectedLanguage;

  /// Detected framework (e.g., 'flutter', 'react', 'django').
  final String? detectedFramework;

  /// Contents of project instruction file (CLAUDE.md, .soul.md, etc.)
  final String? projectInstructions;

  /// Number of files in the project.
  final int fileCount;

  const ProjectContext({
    required this.rootPath,
    required this.fileTree,
    this.detectedLanguage,
    this.detectedFramework,
    this.projectInstructions,
    this.fileCount = 0,
  });

  /// Scan a project directory and build context.
  static Future<ProjectContext> scan(String rootPath) async {
    final dir = Directory(rootPath);
    if (!await dir.exists()) {
      throw ArgumentError('Project directory not found: $rootPath');
    }

    log.i('Scanning project at: $rootPath');

    // Build file tree
    final treeBuffer = StringBuffer();
    var fileCount = 0;
    await _buildTree(dir, treeBuffer, '', 4, 0, fileCount, (c) => fileCount = c);

    // Detect language and framework
    final detection = await _detectLanguageFramework(rootPath);

    // Load project instructions
    final instructions = await _loadProjectInstructions(rootPath);

    return ProjectContext(
      rootPath: rootPath,
      fileTree: treeBuffer.toString().trimRight(),
      detectedLanguage: detection.$1,
      detectedFramework: detection.$2,
      projectInstructions: instructions,
      fileCount: fileCount,
    );
  }

  static Future<(String?, String?)> _detectLanguageFramework(String rootPath) async {
    String? language;
    String? framework;

    // Check for language/framework indicator files
    final indicators = {
      'pubspec.yaml': ('dart', 'flutter'),
      'package.json': ('typescript', null),
      'Cargo.toml': ('rust', null),
      'go.mod': ('go', null),
      'requirements.txt': ('python', null),
      'pyproject.toml': ('python', null),
      'Gemfile': ('ruby', null),
      'build.gradle': ('kotlin', 'android'),
      'build.gradle.kts': ('kotlin', 'android'),
      'Podfile': ('swift', 'ios'),
    };

    for (final entry in indicators.entries) {
      if (await File('$rootPath/${entry.key}').exists()) {
        language = entry.value.$1;
        framework = entry.value.$2;
        break;
      }
    }

    // Refine: check for React/Next/Vue in package.json
    if (language == 'typescript') {
      try {
        final packageJson = await File('$rootPath/package.json').readAsString();
        if (packageJson.contains('"next"')) {
          framework = 'nextjs';
        } else if (packageJson.contains('"react"')) {
          framework = 'react';
        } else if (packageJson.contains('"vue"')) {
          framework = 'vue';
        } else if (packageJson.contains('"express"')) {
          framework = 'express';
        }
      } catch (_) {}
    }

    // Refine: check for Django/Flask
    if (language == 'python') {
      try {
        final reqs = await File('$rootPath/requirements.txt').readAsString();
        if (reqs.contains('django') || reqs.contains('Django')) {
          framework = 'django';
        } else if (reqs.contains('flask') || reqs.contains('Flask')) {
          framework = 'flask';
        } else if (reqs.contains('fastapi') || reqs.contains('FastAPI')) {
          framework = 'fastapi';
        }
      } catch (_) {}
    }

    return (language, framework);
  }

  static Future<String?> _loadProjectInstructions(String rootPath) async {
    // Check for common project instruction files (ordered by priority)
    final instructionFiles = [
      'CLAUDE.md',
      '.claude/CLAUDE.md',
      '.soul.md',
      'SOUL.md',
      '.cursorrules',
      '.github/copilot-instructions.md',
    ];

    for (final fileName in instructionFiles) {
      final file = File('$rootPath/$fileName');
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          log.d('Loaded project instructions from $fileName (${content.length} chars)');
          return content;
        } catch (e) {
          log.w('Failed to read project instructions $fileName: $e');
        }
      }
    }

    return null;
  }

  static Future<void> _buildTree(
    Directory dir,
    StringBuffer buffer,
    String prefix,
    int maxDepth,
    int currentDepth,
    int count,
    void Function(int) updateCount,
  ) async {
    if (currentDepth >= maxDepth || count >= 500) return;

    final entities = dir.listSync()
      ..sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
        return a.path.split('/').last.compareTo(b.path.split('/').last);
      });

    final filtered = entities.where((e) {
      final name = e.path.split('/').last;
      return !name.startsWith('.') &&
          name != 'node_modules' &&
          name != 'build' &&
          name != '__pycache__' &&
          name != '.dart_tool' &&
          name != 'target';
    }).toList();

    for (var i = 0; i < filtered.length; i++) {
      if (count >= 500) return;
      count++;
      updateCount(count);

      final entity = filtered[i];
      final isLast = i == filtered.length - 1;
      final connector = isLast ? '└── ' : '├── ';
      final name = entity.path.split('/').last;

      if (entity is Directory) {
        buffer.writeln('$prefix$connector$name/');
        final childPrefix = prefix + (isLast ? '    ' : '│   ');
        await _buildTree(
          entity, buffer, childPrefix, maxDepth,
          currentDepth + 1, count, updateCount,
        );
      } else {
        buffer.writeln('$prefix$connector$name');
      }
    }
  }

  /// Summary for display (e.g., "Flutter/Dart project, 142 files").
  String get summary {
    final parts = <String>[];
    if (detectedFramework != null) {
      parts.add(detectedFramework!);
    }
    if (detectedLanguage != null) {
      parts.add(detectedLanguage!);
    }
    if (parts.isEmpty) {
      parts.add('Unknown');
    }
    return '${parts.join("/")} project, $fileCount files';
  }
}
