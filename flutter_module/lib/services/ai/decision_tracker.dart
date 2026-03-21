import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../models/intervention.dart';
import '../database/daos/intervention_dao.dart';

/// Tool definition for Claude to track open questions or undecided matters.
final trackOpenQuestionTool = ToolDefinition.custom(
  Tool(
    name: 'track_open_question',
    description:
        'Track an open question or undecided matter from the conversation. '
        'Call when you notice the user is leaving an important question unanswered '
        'or deferring a decision that needs to be made.',
    inputSchema: InputSchema(
      properties: {
        'question': {
          'type': 'string',
          'description': 'The undecided question or topic',
        },
        'options': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Available options if known',
        },
        'proposed_default': {
          'type': 'string',
          'description':
              'What SOUL would recommend as default if user doesn\'t decide',
        },
        'domain': {
          'type': 'string',
          'enum': ['strategy', 'tech', 'design', 'marketing', 'finance'],
          'description': 'Primary domain of this question',
        },
      },
      required: ['question', 'domain'],
    ),
  ),
);

/// Tracks open questions and undecided matters with escalation timers.
///
/// Questions are stored as InterventionState of type decisionDelay.
/// Escalation: 4h nudge, 8h confrontation, 24h proposal.
class DecisionTracker {
  final InterventionDao _interventionDao;
  final Logger _logger = Logger();

  DecisionTracker({required InterventionDao interventionDao})
      : _interventionDao = interventionDao;

  /// Process a track_open_question tool call from Claude.
  Future<String> processToolUse({
    required String conversationId,
    required Map<String, dynamic> input,
  }) async {
    final question = input['question'] as String;
    final proposedDefault = input['proposed_default'] as String?;
    final domain = input['domain'] as String;

    _logger.i('DecisionTracker: open question — $question');

    final state = InterventionState(
      id: const Uuid().v4(),
      type: InterventionType.decisionDelay,
      level: InterventionLevel.detected,
      triggerDescription: question,
      proposedDefault: proposedDefault,
      detectedAt: DateTime.now(),
      relatedEntityId: conversationId,
    );

    await _interventionDao.upsertIntervention(state);

    return 'Open vraag geregistreerd: "$question". '
        'Timer loopt — ik kom hierop terug als je niet beslist.';
  }

  /// Get all currently open questions (for system prompt injection).
  Future<List<InterventionState>> getOpenQuestions() async {
    final all = await _interventionDao.getActiveInterventions();
    return all.where((i) => i.type == InterventionType.decisionDelay).toList();
  }

  /// Resolve an open question (user made a decision).
  Future<void> resolveQuestion(String interventionId) async {
    await _interventionDao.resolveIntervention(
        interventionId, DateTime.now());
  }
}
