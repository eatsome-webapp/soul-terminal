import 'package:mcp_dart/mcp_dart.dart' as mcp;
import '../agentic_tool.dart';

/// Adapts an MCP tool to the AgenticTool interface.
///
/// MCP tools are prefixed with 'mcp_{serverName}_' to avoid name conflicts
/// with built-in tools.
class McpToolAdapter extends AgenticTool {
  final String serverName;
  final mcp.Tool mcpTool;
  final mcp.Client mcpClient;

  McpToolAdapter({
    required this.serverName,
    required this.mcpTool,
    required this.mcpClient,
  });

  @override
  String get name => 'mcp_${serverName}_${mcpTool.name}';

  @override
  String get description => mcpTool.description ?? 'MCP tool: ${mcpTool.name}';

  @override
  Map<String, dynamic> get inputSchema {
    // MCP tool inputSchema is a JsonSchema object — serialize to map first
    final schemaMap = mcpTool.inputSchema.toJson();
    return {
      'properties': schemaMap['properties'] ?? {},
      'required': schemaMap['required'] ?? [],
    };
  }

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    try {
      final result = await mcpClient.callTool(
        mcp.CallToolRequest(
          name: mcpTool.name,
          arguments: input,
        ),
      );

      // Combine all content items into a single string
      final buffer = StringBuffer();
      for (final content in result.content) {
        if (content is mcp.TextContent) {
          buffer.writeln(content.text);
        } else {
          buffer.writeln('[non-text content: ${content.runtimeType}]');
        }
      }

      final output = buffer.toString().trim();
      return output.isEmpty ? '(no output)' : output;
    } catch (e) {
      return 'Error calling MCP tool ${mcpTool.name}: $e';
    }
  }
}
