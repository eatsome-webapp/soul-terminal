/// Maps raw OpenClaw tool names to high-level capability groups.
///
/// Max 7 groups for system prompt brevity (per 11-CONTEXT.md):
/// execute, browse, messaging, cron, webhooks, file, git
class CapabilityGrouper {
  static const _groupKeywords = <String, List<String>>{
    'execute': ['exec', 'bash', 'shell', 'command', 'run'],
    'browse': ['browser', 'screenshot', 'navigate', 'page', 'click'],
    'messaging': [
      'message',
      'send_message',
      'channel',
      'whatsapp',
      'telegram',
      'slack',
      'discord',
    ],
    'cron': ['cron'],
    'webhooks': ['hook', 'webhook'],
    'file': ['read', 'write', 'edit', 'file', 'directory', 'glob', 'grep'],
    'git': ['git'],
  };

  /// Classify a single tool name into a capability group.
  /// Returns 'other' if no keyword match found.
  static String classify(String toolName) {
    final lower = toolName.toLowerCase();
    for (final entry in _groupKeywords.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return 'other';
  }

  /// Group a list of tool maps into distinct capability groups.
  /// Returns sorted list of unique group names (max 7 + 'other').
  static List<String> groupTools(List<Map<String, dynamic>> tools) {
    final groups = <String>{};
    for (final tool in tools) {
      final name =
          tool['name'] as String? ?? tool['tool_name'] as String? ?? '';
      if (name.isEmpty) continue;
      groups.add(classify(name));
    }
    // Remove 'other' if we have enough real groups
    final sorted = groups.toList()..sort();
    return sorted;
  }
}
