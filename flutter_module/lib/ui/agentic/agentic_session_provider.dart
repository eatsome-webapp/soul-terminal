import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as sdk;

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../services/agentic/agentic_engine.dart';
import '../../services/agentic/agentic_event.dart';
import '../../services/agentic/agentic_prompt_composer.dart';
import '../../services/agentic/project_context.dart';
import '../../services/agentic/tool_registry.dart';
import '../../services/agentic/tools/read_tool.dart';
import '../../services/agentic/tools/write_tool.dart';
import '../../services/agentic/tools/edit_tool.dart';
import '../../services/agentic/tools/glob_tool.dart';
import '../../services/agentic/tools/grep_tool.dart';
import '../../services/agentic/tools/bash_tool.dart';
import '../../services/agentic/tools/list_dir_tool.dart';
import '../../core/di/providers.dart';

part 'agentic_session_provider.g.dart';

/// A single tool step in the session history.
class ToolStep {
  final String toolId;
  final String toolName;
  final Map<String, dynamic> input;
  final String? output;
  final bool isError;
  final bool isComplete;

  const ToolStep({
    required this.toolId,
    required this.toolName,
    required this.input,
    this.output,
    this.isError = false,
    this.isComplete = false,
  });

  ToolStep copyWith({
    String? output,
    bool? isError,
    bool? isComplete,
  }) {
    return ToolStep(
      toolId: toolId,
      toolName: toolName,
      input: input,
      output: output ?? this.output,
      isError: isError ?? this.isError,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

/// State for the agentic session.
class AgenticSessionState {
  final bool isRunning;
  final bool isComplete;
  final String? errorMessage;
  final List<ToolStep> steps;
  final String textBuffer;
  final int totalInputTokens;
  final int totalOutputTokens;
  final int iterationCount;
  final double estimatedCostUsd;
  final ProjectContext? projectContext;

  const AgenticSessionState({
    this.isRunning = false,
    this.isComplete = false,
    this.errorMessage,
    this.steps = const [],
    this.textBuffer = '',
    this.totalInputTokens = 0,
    this.totalOutputTokens = 0,
    this.iterationCount = 0,
    this.estimatedCostUsd = 0.0,
    this.projectContext,
  });

  AgenticSessionState copyWith({
    bool? isRunning,
    bool? isComplete,
    String? errorMessage,
    List<ToolStep>? steps,
    String? textBuffer,
    int? totalInputTokens,
    int? totalOutputTokens,
    int? iterationCount,
    double? estimatedCostUsd,
    ProjectContext? projectContext,
  }) {
    return AgenticSessionState(
      isRunning: isRunning ?? this.isRunning,
      isComplete: isComplete ?? this.isComplete,
      errorMessage: errorMessage ?? this.errorMessage,
      steps: steps ?? this.steps,
      textBuffer: textBuffer ?? this.textBuffer,
      totalInputTokens: totalInputTokens ?? this.totalInputTokens,
      totalOutputTokens: totalOutputTokens ?? this.totalOutputTokens,
      iterationCount: iterationCount ?? this.iterationCount,
      estimatedCostUsd: estimatedCostUsd ?? this.estimatedCostUsd,
      projectContext: projectContext ?? this.projectContext,
    );
  }
}

@riverpod
class AgenticSession extends _$AgenticSession {
  AgenticEngine? _engine;

  @override
  AgenticSessionState build() => const AgenticSessionState();

  /// Set the project directory for agentic operations.
  Future<void> setProjectDirectory(String path) async {
    final context = await ProjectContext.scan(path);
    state = state.copyWith(projectContext: context);
    log.i('Project set: ${context.summary}');
  }

  /// Start an agentic task.
  Future<void> startTask(String task, {int maxIterations = 25}) async {
    if (state.isRunning) return;

    // Build tool registry with all built-in tools
    final registry = ToolRegistry();
    final projectDir = state.projectContext?.rootPath;

    registry.register(ReadTool());
    registry.register(WriteTool());
    registry.register(EditTool());
    registry.register(GlobTool());
    registry.register(GrepTool());
    registry.register(BashTool(workingDirectory: projectDir));
    registry.register(ListDirTool());

    // Register MCP tools from connected servers
    final mcpManager = ref.read(mcpManagerProvider);
    await mcpManager.registerTools(registry);

    // Create engine
    const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
    final client = sdk.AnthropicClient(
      config: sdk.AnthropicConfig(
        authProvider: sdk.ApiKeyProvider(apiKey),
      ),
    );
    _engine = AgenticEngine(client: client, toolRegistry: registry);

    // Compose system prompt
    final composer = AgenticPromptComposer();
    final systemPrompt = composer.compose(
      projectContext: state.projectContext,
    );

    // Reset state
    state = state.copyWith(
      isRunning: true,
      isComplete: false,
      errorMessage: null,
      steps: [],
      textBuffer: '',
      totalInputTokens: 0,
      totalOutputTokens: 0,
      iterationCount: 0,
      estimatedCostUsd: 0.0,
    );

    // Run agentic loop
    try {
      await for (final event in _engine!.run(
        task: task,
        systemPrompt: systemPrompt,
        config: AgenticConfig(maxIterations: maxIterations),
      )) {
        _handleEvent(event);
      }
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  void _handleEvent(AgentEvent event) {
    switch (event) {
      case AgentTextDelta(:final text):
        state = state.copyWith(
          textBuffer: state.textBuffer + text,
        );
      case AgentToolStart(:final toolName, :final toolId, :final input):
        state = state.copyWith(
          steps: [
            ...state.steps,
            ToolStep(toolId: toolId, toolName: toolName, input: input),
          ],
        );
      case AgentToolResult(:final toolId, :final output, :final isError):
        final updatedSteps = state.steps.map((step) {
          if (step.toolId == toolId) {
            return step.copyWith(
              output: output,
              isError: isError,
              isComplete: true,
            );
          }
          return step;
        }).toList();
        state = state.copyWith(steps: updatedSteps);
      case AgentComplete(
          :final totalInputTokens,
          :final totalOutputTokens,
          :final iterationCount,
          :final costUsd
        ):
        state = state.copyWith(
          isRunning: false,
          isComplete: true,
          totalInputTokens: totalInputTokens,
          totalOutputTokens: totalOutputTokens,
          iterationCount: iterationCount,
          estimatedCostUsd: costUsd,
        );
      case AgentWalEntry():
        break;
      case AgentError(:final message):
        state = state.copyWith(
          isRunning: false,
          errorMessage: message,
        );
    }
  }

  /// Cancel the running agentic session.
  void cancel() {
    _engine?.cancel();
  }
}
