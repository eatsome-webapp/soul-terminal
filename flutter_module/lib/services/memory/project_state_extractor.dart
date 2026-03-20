import 'dart:convert';
import '../../core/utils/logger.dart';
import '../ai/claude_service.dart';
import '../database/daos/conversation_dao.dart';
import '../database/daos/project_dao.dart';
import '../database/daos/project_state_dao.dart';

class ProjectStateExtractor {
  final ClaudeService _claudeService;
  final ConversationDao _conversationDao;
  final ProjectDao _projectDao;
  final ProjectStateDao _projectStateDao;

  ProjectStateExtractor({
    required ClaudeService claudeService,
    required ConversationDao conversationDao,
    required ProjectDao projectDao,
    required ProjectStateDao projectStateDao,
  })  : _claudeService = claudeService,
        _conversationDao = conversationDao,
        _projectDao = projectDao,
        _projectStateDao = projectStateDao;

  Future<void> onConversationComplete(String conversationId) async {
    try {
      final project = await _projectDao.getActiveProject();
      if (project == null) {
        log.d('No active project, skipping state extraction');
        return;
      }

      final messages =
          await _conversationDao.getMessagesForConversation(conversationId);
      if (messages.isEmpty) return;

      // Take last 50 messages max to keep prompt reasonable
      final recentMessages = messages.length > 50
          ? messages.sublist(messages.length - 50)
          : messages;
      final conversationText = recentMessages
          .map((m) => '[${m.role}]: ${m.content}')
          .join('\n');

      final prompt =
          '''Analyze this conversation about the project "${project.name}" and extract the current project state.
Return a JSON object with exactly these fields:
{
  "current_status": "one sentence describing where the project stands now",
  "unvalidated_assumptions": ["assumption 1", "assumption 2"],
  "riskiest_item": "the single riskiest untested thing right now",
  "scope_creep_flags": ["any feature discussed that seems out of scope"]
}

Only return valid JSON, nothing else.

Conversation:
$conversationText''';

      final result =
          await _claudeService.analyzeWithHaiku(prompt, maxTokens: 512);

      final assumptions =
          result['unvalidated_assumptions'] as List<dynamic>? ?? [];
      final scopeFlags =
          result['scope_creep_flags'] as List<dynamic>? ?? [];

      await _projectStateDao.upsertState(
        projectId: project.id,
        currentStatus: result['current_status'] as String? ?? 'Unknown',
        unvalidatedAssumptions: jsonEncode(assumptions),
        riskiestItem: result['riskiest_item'] as String?,
        scopeCreepFlags: jsonEncode(scopeFlags),
        sourceConversationId: conversationId,
      );

      log.i(
          'Project state extracted for ${project.name}: ${result['current_status']}');
    } catch (e) {
      log.e('Project state extraction failed: $e');
    }
  }
}
