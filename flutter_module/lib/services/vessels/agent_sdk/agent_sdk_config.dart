class AgentSdkConfig {
  final String relayUrl;
  final String token;

  const AgentSdkConfig({
    required this.relayUrl,
    required this.token,
  });

  Uri get tasksUrl => Uri.parse('$relayUrl/tasks');
  Uri taskUrl(String taskId) => Uri.parse('$relayUrl/tasks/$taskId');
  Uri get healthUrl => Uri.parse('$relayUrl/health');

  Map<String, String> get authHeaders => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
