class OpenClawConfig {
  final String host;
  final int port;
  final String token;
  final bool useTls;
  final String urlPrefix;

  const OpenClawConfig({
    required this.host,
    this.port = 18789,
    required this.token,
    this.useTls = false,
    this.urlPrefix = '',
  });

  String get baseUrl => '${useTls ? 'https' : 'http'}://$host:$port$urlPrefix';
  Uri get healthUrl => Uri.parse('$baseUrl/health');
  Uri get toolsInvokeUrl => Uri.parse('$baseUrl/tools/invoke');
  Uri get toolsListUrl => Uri.parse('$baseUrl/tools');
  Uri get chatCompletionsUrl => Uri.parse('$baseUrl/v1/chat/completions');
  Uri hooksUrl(String hookName) => Uri.parse('$baseUrl/hooks/$hookName');

  /// WebSocket URL for real-time terminal streaming (VES-12).
  /// Converts http(s) to ws(s) protocol.
  Uri wsUrl({String sessionKey = 'main'}) => Uri.parse(
      '${useTls ? 'wss' : 'ws'}://$host:$port$urlPrefix/ws?session=$sessionKey');

  Map<String, String> get authHeaders => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
