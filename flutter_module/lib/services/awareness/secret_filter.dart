/// Filters sensitive data from terminal output before storing in SOUL memory.
///
/// The terminal output itself is never modified — filtering only happens
/// on the path to SOUL memory/AI context.
class SecretFilter {
  static final List<RegExp> _sensitivePatterns = [
    // Anthropic API keys
    RegExp(r'sk-ant-[a-zA-Z0-9\-_]{20,}'),

    // OpenAI API keys
    RegExp(r'sk-[a-zA-Z0-9]{32,}'),

    // GitHub personal/server tokens
    RegExp(r'gh[ps]_[a-zA-Z0-9]{36,}'),

    // GitHub fine-grained PATs
    RegExp(r'github_pat_[a-zA-Z0-9_]{82}'),

    // Generic key=value assignments (API_KEY, TOKEN, SECRET, PASSWORD, etc.)
    RegExp(
      r'(?:API_KEY|TOKEN|SECRET|PASSWORD|ANTHROPIC_API_KEY)\s*=\s*\S{8,}',
      caseSensitive: false,
    ),

    // JWT Bearer tokens
    RegExp(
      r'Bearer\s+[a-zA-Z0-9\-_\.]+\.[a-zA-Z0-9\-_\.]+\.[a-zA-Z0-9\-_]+',
    ),

    // Basic auth headers
    RegExp(r'Authorization:\s*Basic\s+[a-zA-Z0-9+/=]{16,}'),
  ];

  /// Filter sensitive data from terminal output before storing in SOUL memory.
  /// Returns filtered string with secrets replaced by [FILTERED].
  static String filter(String output) {
    var result = output;
    for (final pattern in _sensitivePatterns) {
      result = result.replaceAll(pattern, '[FILTERED]');
    }
    return result;
  }

  /// Check if output contains any sensitive patterns.
  static bool containsSecrets(String output) {
    return _sensitivePatterns.any((pattern) => pattern.hasMatch(output));
  }
}
