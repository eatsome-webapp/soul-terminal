import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as sdk;

/// Abstract base class for all agentic tools (built-in and MCP).
abstract class AgenticTool {
  /// Tool name as sent to Claude API (e.g., 'Read', 'Write', 'Bash').
  String get name;

  /// Human-readable description for Claude.
  String get description;

  /// JSON Schema for tool input parameters.
  Map<String, dynamic> get inputSchema;

  /// Execute the tool with given input. Returns result string.
  /// Throws on unrecoverable errors; return error string for recoverable ones.
  Future<String> execute(Map<String, dynamic> input);

  /// Convert to Anthropic SDK Tool definition.
  sdk.Tool toAnthropicTool() {
    return sdk.Tool(
      name: name,
      description: description,
      inputSchema: sdk.InputSchema(
        properties: inputSchema['properties'] as Map<String, dynamic>? ?? {},
        required:
            (inputSchema['required'] as List<dynamic>?)?.cast<String>() ?? [],
      ),
    );
  }
}
