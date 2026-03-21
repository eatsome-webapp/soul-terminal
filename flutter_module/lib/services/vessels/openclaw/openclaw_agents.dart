import 'openclaw_client.dart';

/// Orchestrates multiple OpenClaw agents (VES-07).
/// Uses sessions_spawn and sessions_send tools (must be allowed in OpenClaw config).
class OpenClawAgents {
  final OpenClawClient _client;

  const OpenClawAgents(this._client);

  /// Spawn a new agent with its own session.
  /// Note: sessions_spawn is denied by default in OpenClaw.
  /// User must configure tool policy to allow it.
  Future<Map<String, dynamic>> spawnAgent({
    required String agentId,
    String? sessionKey,
    String? systemPrompt,
  }) {
    return _client.invokeTool(
      tool: 'sessions_spawn',
      args: {
        'agentId': agentId,
        if (sessionKey != null) 'sessionKey': sessionKey,
        if (systemPrompt != null) 'systemPrompt': systemPrompt,
      },
    );
  }

  /// Send a message to a specific agent's session.
  /// Note: sessions_send is denied by default in OpenClaw.
  Future<Map<String, dynamic>> sendToAgent({
    required String sessionKey,
    required String message,
  }) {
    return _client.invokeTool(
      tool: 'sessions_send',
      args: {
        'sessionKey': sessionKey,
        'message': message,
      },
    );
  }

  /// Send a chat completion to a specific agent via agent ID header.
  /// This uses the standard /v1/chat/completions endpoint with agent routing.
  Stream<String> chatWithAgent({
    required String agentId,
    required List<Map<String, String>> messages,
    String? sessionKey,
  }) {
    return _client.streamCompletion(
      messages: messages,
      agentId: agentId,
      sessionKey: sessionKey ?? 'agent-$agentId',
    );
  }

  /// List all available sessions (can infer active agents).
  Future<List<Map<String, dynamic>>> listActiveSessions() {
    return _client.listSessions();
  }
}
