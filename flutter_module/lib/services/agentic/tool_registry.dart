import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as sdk;
import '../../core/utils/logger.dart';
import 'agentic_tool.dart';

/// Registry of all available tools for the agentic engine.
///
/// Manages built-in tools and dynamically registered MCP tools.
/// Converts registered tools to Anthropic SDK format for API calls.
class ToolRegistry {
  final Map<String, AgenticTool> _tools = {};

  /// Register a tool. Overwrites if name already exists.
  void register(AgenticTool tool) {
    _tools[tool.name] = tool;
    log.d('Registered tool: ${tool.name}');
  }

  /// Unregister a tool by name.
  void unregister(String name) {
    _tools.remove(name);
  }

  /// Get a tool by name. Returns null if not found.
  AgenticTool? getTool(String name) => _tools[name];

  /// All registered tool names.
  List<String> get toolNames => _tools.keys.toList();

  /// Number of registered tools.
  int get count => _tools.length;

  /// Convert all registered tools to Anthropic SDK ToolDefinition list.
  List<sdk.ToolDefinition> toAnthropicTools() {
    return _tools.values
        .map((t) => sdk.ToolDefinition.custom(t.toAnthropicTool()))
        .toList();
  }

  /// Execute a tool by name. Returns result string.
  /// Returns error string if tool not found.
  Future<String> executeTool(String name, Map<String, dynamic> input) async {
    final tool = _tools[name];
    if (tool == null) {
      return 'Error: Unknown tool "$name". Available tools: ${toolNames.join(", ")}';
    }
    try {
      return await tool.execute(input);
    } catch (e) {
      log.e('Tool "$name" threw exception: $e');
      return 'Error executing tool "$name": $e';
    }
  }
}
