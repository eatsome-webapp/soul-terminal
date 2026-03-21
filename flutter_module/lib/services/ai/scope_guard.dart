import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../database/daos/decision_dao.dart';

/// Tool definition for Claude to flag scope creep or nice-to-have requests.
final flagScopeCreepTool = ToolDefinition.custom(
  Tool(
    name: 'flag_scope_creep',
    description: 'Flag a user request as scope creep or nice-to-have. '
        'Call when user requests something outside the current project plan.',
    inputSchema: InputSchema(
      properties: {
        'request': {
          'type': 'string',
          'description': 'What user requested',
        },
        'classification': {
          'type': 'string',
          'enum': ['mvp_critical', 'nice_to_have', 'scope_creep'],
          'description': 'Classification of the request',
        },
        'reason': {
          'type': 'string',
          'description': 'Why this classification',
        },
        'redirect_to': {
          'type': 'string',
          'description': 'What user should focus on instead',
        },
      },
      required: ['request', 'classification', 'reason'],
    ),
  ),
);

/// Detects and flags scope creep by processing flag_scope_creep tool calls.
/// Stores flagged items as deferred decisions in the decision log.
class ScopeGuard {
  final DecisionDao _decisionDao;
  final Logger _logger = Logger();

  ScopeGuard({required DecisionDao decisionDao})
      : _decisionDao = decisionDao;

  /// Process a flag_scope_creep tool call from Claude.
  /// Stores scope creep item as a deferred decision in the decision log.
  /// Returns a confirmation message for Claude to relay to user.
  Future<String> processToolUse({
    required String conversationId,
    required String messageId,
    required Map<String, dynamic> input,
  }) async {
    final request = input['request'] as String;
    final classification = input['classification'] as String;
    final reason = input['reason'] as String;
    final redirectTo = input['redirect_to'] as String?;

    _logger.i('ScopeGuard: $classification — $request');

    // Store as deferred decision
    await _decisionDao.insertDecision(
      id: const Uuid().v4(),
      conversationId: conversationId,
      messageId: messageId,
      title: '[Scope: $classification] $request',
      reasoning: reason,
      domain: 'strategy',
      status: 'deferred',
    );

    if (classification == 'scope_creep') {
      return 'Scope creep gedetecteerd: "$request". Reden: $reason. '
          '${redirectTo != null ? "Focus op: $redirectTo" : "Blijf bij het huidige plan."}';
    } else if (classification == 'nice_to_have') {
      return 'Nice-to-have genoteerd: "$request". Toegevoegd aan backlog. '
          '${redirectTo != null ? "Focus op: $redirectTo" : ""}';
    }
    return 'Verzoek geclassificeerd als MVP-critical: "$request".';
  }
}
