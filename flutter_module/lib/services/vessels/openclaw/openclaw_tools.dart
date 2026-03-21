import 'openclaw_client.dart';

/// Convenience methods for common OpenClaw tool invocations.
/// All methods delegate to [OpenClawClient.invokeTool].
class OpenClawTools {
  final OpenClawClient _client;

  const OpenClawTools(this._client);

  /// Execute a shell command (VES-02).
  Future<Map<String, dynamic>> exec({
    required String command,
    String sessionKey = 'main',
    int timeoutSeconds = 30,
  }) {
    return _client.invokeTool(
      tool: 'exec',
      args: {'command': command, 'timeout': timeoutSeconds},
      sessionKey: sessionKey,
    );
  }

  /// Read a file (VES-02).
  Future<Map<String, dynamic>> readFile({
    required String path,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'read',
      args: {'path': path},
      sessionKey: sessionKey,
    );
  }

  /// Write a file (VES-02).
  Future<Map<String, dynamic>> writeFile({
    required String path,
    required String content,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'write',
      args: {'path': path, 'content': content},
      sessionKey: sessionKey,
    );
  }

  /// Search files (VES-02).
  Future<Map<String, dynamic>> search({
    required String query,
    String? path,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'search',
      args: {'query': query, if (path != null) 'path': path},
      sessionKey: sessionKey,
    );
  }

  /// Browser automation (VES-08).
  Future<Map<String, dynamic>> browser({
    required String action,
    Map<String, dynamic> args = const {},
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'browser',
      args: {'action': action, ...args},
      sessionKey: sessionKey,
    );
  }

  /// Take a browser screenshot (VES-08).
  Future<Map<String, dynamic>> browserScreenshot({
    String sessionKey = 'main',
  }) {
    return browser(action: 'screenshot', sessionKey: sessionKey);
  }

  /// Web search (VES-02).
  Future<Map<String, dynamic>> webSearch({
    required String query,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'web_search',
      args: {'query': query},
      sessionKey: sessionKey,
    );
  }

  /// Web fetch (VES-02).
  Future<Map<String, dynamic>> webFetch({
    required String url,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'web_fetch',
      args: {'url': url},
      sessionKey: sessionKey,
    );
  }

  /// Python execution (VES-02).
  Future<Map<String, dynamic>> python({
    required String code,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'python',
      args: {'code': code},
      sessionKey: sessionKey,
    );
  }

  /// Node.js execution (VES-02).
  Future<Map<String, dynamic>> node({
    required String code,
    String sessionKey = 'main',
  }) {
    return _client.invokeTool(
      tool: 'node',
      args: {'code': code},
      sessionKey: sessionKey,
    );
  }
}
