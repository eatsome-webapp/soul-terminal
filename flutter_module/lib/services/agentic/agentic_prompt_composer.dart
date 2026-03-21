import '../memory/memory_service.dart';
import 'project_context.dart';

/// Composes the system prompt for agentic coding sessions.
///
/// Unlike the regular PromptComposer (multi-domain reasoning), this
/// focuses on coding task execution with project context and tool usage.
class AgenticPromptComposer {
  /// Compose the agentic system prompt.
  ///
  /// [projectContext] — The user's target project (file tree, language, instructions).
  /// [memory] — Optional memory context for project history.
  String compose({
    ProjectContext? projectContext,
    MemoryContext? memory,
  }) {
    final sections = <String>[
      _coreIdentity(),
      _toolUsageInstructions(),
    ];

    if (projectContext != null) {
      sections.add(_projectSection(projectContext));

      if (projectContext.projectInstructions != null) {
        sections.add(_section(
          'PROJECT INSTRUCTIONS',
          projectContext.projectInstructions!,
        ));
      }
    }

    if (memory != null && !memory.isEmpty) {
      if (memory.projectContext.isNotEmpty) {
        sections.add(_section('PROJECT MEMORY', memory.projectContext));
      }
      if (memory.relevantDecisions.isNotEmpty) {
        sections.add(_section('RELEVANT DECISIONS', memory.relevantDecisions));
      }
    }

    sections.add(_codingGuidelines());

    return sections.join('\n\n');
  }

  String _coreIdentity() {
    return '''## IDENTITY
You are SOUL, an agentic coding assistant running natively on the user's Android device. You have direct access to the filesystem and shell. You autonomously read files, make edits, run commands, and iterate until the task is complete.

You are one unified entity — not a separate "coding mode". You bring the same strategic, technical, and practical thinking to coding tasks.''';
  }

  String _toolUsageInstructions() {
    return '''## TOOL USAGE
You have access to these tools for working with the project:

- **Read**: Read file contents (supports offset/limit for large files)
- **Write**: Create or overwrite files (creates parent directories automatically)
- **Edit**: Find-and-replace in files (old_string must be unique unless replace_all is set)
- **Bash**: Execute shell commands (Android toybox: ls, cat, grep, find, diff, sort, sed, etc. No git/node/python)
- **Glob**: Find files by glob pattern (e.g., "**/*.dart")
- **Grep**: Search file contents by regex pattern
- **ListDir**: List directory tree structure

### Guidelines:
1. Always read a file before editing it — understand context first.
2. Use Edit for targeted changes. Use Write only for new files or complete rewrites.
3. Make changes incrementally — don't rewrite entire files when a small edit suffices.
4. After making changes, verify them (re-read the file, run relevant commands).
5. If a task requires multiple steps, plan them first, then execute.
6. Return error details when a tool fails — don't silently skip.
7. When editing, provide enough context in old_string to make it unique.''';
  }

  String _projectSection(ProjectContext context) {
    final buffer = StringBuffer();
    buffer.writeln('## PROJECT');
    buffer.writeln('Root: ${context.rootPath}');
    if (context.detectedLanguage != null) {
      buffer.writeln('Language: ${context.detectedLanguage}');
    }
    if (context.detectedFramework != null) {
      buffer.writeln('Framework: ${context.detectedFramework}');
    }
    buffer.writeln('Files: ${context.fileCount}');
    buffer.writeln();
    buffer.writeln('### File Tree');
    buffer.writeln('```');
    buffer.writeln(context.fileTree);
    buffer.writeln('```');
    return buffer.toString().trimRight();
  }

  String _codingGuidelines() {
    return '''## CODING GUIDELINES
- Prefer clean, minimal code — no over-engineering.
- Descriptive variable names, no single-letter variables except loops.
- Early returns over nested conditionals.
- When in doubt, read more files for context before making changes.
- Never create documentation files unless explicitly asked.
- Only modify files relevant to the task.''';
  }

  String _section(String title, String content) {
    return '## $title\n$content';
  }
}
