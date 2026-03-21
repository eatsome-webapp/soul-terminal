import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../models/conversation.dart' as models;
import '../../models/prompt_context.dart';
import 'cost_tracker.dart';
import 'decision_detector.dart';
import 'decision_tracker.dart';
import 'model_router.dart';
import 'prompt_composer.dart';
import 'scope_guard.dart';

/// Represents a parsed tool_use block from Claude's response.
class ToolUseBlock {
  final String id;
  final String name;
  final Map<String, dynamic> input;

  const ToolUseBlock({
    required this.id,
    required this.name,
    required this.input,
  });
}

/// Claude API service with streaming responses, prompt caching, and tool_use support.
///
/// This is the single point of contact for all Claude API communication.
/// Uses [PromptComposer] for 6-layer system prompts and
/// [ModelRouter] for Sonnet/Opus model selection.
/// Sends the log_decision tool and captures tool_use response blocks.
class ClaudeService {
  final AnthropicClient _client;
  final PromptComposer _composer;
  final ModelRouter _router;
  final CostTracker? _costTracker;
  ScopeGuard? _scopeGuard;
  DecisionTracker? _decisionTracker;

  /// Set the ScopeGuard processor for flag_scope_creep tool calls.
  void setScopeGuard(ScopeGuard guard) => _scopeGuard = guard;

  /// Set the DecisionTracker processor for track_open_question tool calls.
  void setDecisionTracker(DecisionTracker tracker) =>
      _decisionTracker = tracker;

  ClaudeService({
    required String apiKey,
    PromptComposer? composer,
    ModelRouter? router,
    CostTracker? costTracker,
  })  : _client = AnthropicClient(
          config: AnthropicConfig(
            authProvider: ApiKeyProvider(apiKey),
          ),
        ),
        _composer = composer ?? PromptComposer(),
        _router = router ?? ModelRouter(),
        _costTracker = costTracker;

  /// Streams a Claude response token-by-token.
  ///
  /// Returns a [Stream<String>] of text deltas for real-time UI updates.
  /// Accepts [PromptContext] for enriched 6-layer system prompts
  /// and includes the log_decision tool for decision extraction.
  ///
  /// Yields text deltas for real-time UI. Call [getLastToolCalls] after
  /// stream completes to process any tool_use blocks.
  ///
  /// [userText] - The user's message text.
  /// [conversationHistory] - Previous messages for context.
  /// [promptContext] - Optional context for 6-layer system prompt composition.
  ///
  /// Throws on API errors (caller should handle).
  Stream<String> streamMessage({
    required String userText,
    List<models.Message> conversationHistory = const [],
    PromptContext? promptContext,
  }) async* {
    final context = promptContext ?? const PromptContext();
    final systemPrompt = await _composer.compose(context);
    final model = _router.select(userText);

    log.i(
      'Sending message to $model (${userText.length} chars, '
      'memory: ${context.memory != null})',
    );

    // Build message list from conversation history + new message
    final messages = <InputMessage>[
      ...conversationHistory.map(
        (m) => m.role == models.MessageRole.user
            ? InputMessage.user(m.content)
            : InputMessage.assistant(m.content),
      ),
      InputMessage.user(userText),
    ];

    // Clear previous tool calls
    _lastToolCalls.clear();

    final stream = _client.messages.createStream(
      MessageCreateRequest(
        model: model,
        maxTokens: 4096,
        system: SystemPrompt.text(systemPrompt),
        messages: messages,
        tools: [
          logDecisionTool,
          flagScopeCreepTool,
          trackOpenQuestionTool,
        ],
      ),
    );

    String currentToolId = '';
    String currentToolName = '';
    final toolInputBuffer = StringBuffer();
    bool inToolUse = false;

    // Cost tracking variables
    int streamInputTokens = 0;
    int streamOutputTokens = 0;
    int streamCacheCreationTokens = 0;
    int streamCacheReadTokens = 0;

    await for (final event in stream) {
      if (event is MessageStartEvent) {
        final message = event.message;
        streamInputTokens = message.usage.inputTokens;
        streamCacheCreationTokens = message.usage.cacheCreationInputTokens ?? 0;
        streamCacheReadTokens = message.usage.cacheReadInputTokens ?? 0;
      } else if (event is MessageDeltaEvent) {
        streamOutputTokens = event.usage.outputTokens;
      } else if (event is ContentBlockStartEvent) {
        final block = event.contentBlock;
        if (block is ToolUseBlock) {
          final toolBlock = block as ToolUseBlock;
          inToolUse = true;
          currentToolId = toolBlock.id;
          currentToolName = toolBlock.name;
          toolInputBuffer.clear();
        }
      } else if (event is ContentBlockDeltaEvent) {
        final delta = event.delta;
        if (delta is TextDelta) {
          yield delta.text;
        } else if (delta is InputJsonDelta && inToolUse) {
          toolInputBuffer.write(delta.partialJson);
        }
      } else if (event is ContentBlockStopEvent) {
        if (inToolUse) {
          try {
            final input = jsonDecode(toolInputBuffer.toString())
                as Map<String, dynamic>;
            _lastToolCalls.add(ToolUseBlock(
              id: currentToolId,
              name: currentToolName,
              input: input,
            ));
          } catch (e) {
            log.w('Failed to parse tool input JSON: $e');
          }
          inToolUse = false;
        }
      }
    }

    // Record usage for cost tracking
    if (streamInputTokens > 0 || streamOutputTokens > 0) {
      await _costTracker?.recordUsage(
        model: model,
        inputTokens: streamInputTokens,
        outputTokens: streamOutputTokens,
        cacheCreationTokens: streamCacheCreationTokens,
        cacheReadTokens: streamCacheReadTokens,
      );
    }
  }

  /// Tool calls from the most recent streamMessage invocation.
  final List<ToolUseBlock> _lastToolCalls = [];

  /// Returns tool_use blocks from the last completed stream.
  /// Call after the stream is fully consumed.
  List<ToolUseBlock> getLastToolCalls() => List.unmodifiable(_lastToolCalls);

  /// Analyze text with Haiku for fast, cheap classification tasks.
  ///
  /// Used by MoodAdapter (Plan 07-03) for mood/energy detection.
  /// Returns parsed JSON response.
  Future<Map<String, dynamic>> analyzeWithHaiku(String prompt, {int maxTokens = 100}) async {
    final response = await _client.messages.create(
      MessageCreateRequest(
        model: 'claude-3-5-haiku-20241022',
        maxTokens: maxTokens,
        messages: [
          InputMessage.user(prompt),
        ],
      ),
    );

    // Record usage for cost tracking
    final usage = response.usage;
    await _costTracker?.recordUsage(
      model: SoulConstants.haikuModel,
      inputTokens: usage.inputTokens,
      outputTokens: usage.outputTokens,
      cacheCreationTokens: usage.cacheCreationInputTokens ?? 0,
      cacheReadTokens: usage.cacheReadInputTokens ?? 0,
    );

    final textBlock = response.content.firstWhere(
      (b) => b is TextBlock,
      orElse: () => const TextBlock(text: '{}'),
    ) as TextBlock;

    return jsonDecode(textBlock.text) as Map<String, dynamic>;
  }

  /// Send a single message and return the complete response text.
  /// Useful for non-streaming use cases like briefing generation.
  ///
  /// [prompt] - The user message to send.
  /// [useOpus] - If true, uses Opus model. Defaults to false (Sonnet).
  Future<String> sendSingleMessage(
    String prompt, {
    bool useOpus = false,
  }) async {
    final model = useOpus ? SoulConstants.complexModel : SoulConstants.defaultModel;
    final systemPrompt = await _composer.compose(const PromptContext());

    log.i('Sending single message to $model (${prompt.length} chars)');

    final response = await _client.messages.create(
      MessageCreateRequest(
        model: model,
        maxTokens: 4096,
        system: SystemPrompt.text(systemPrompt),
        messages: [InputMessage.user(prompt)],
      ),
    );

    // Record usage for cost tracking
    final usage = response.usage;
    await _costTracker?.recordUsage(
      model: model,
      inputTokens: usage.inputTokens,
      outputTokens: usage.outputTokens,
      cacheCreationTokens: usage.cacheCreationInputTokens ?? 0,
      cacheReadTokens: usage.cacheReadInputTokens ?? 0,
    );

    final textBlocks = response.content
        .whereType<TextBlock>()
        .map((block) => block.text)
        .join();

    return textBlocks;
  }

  /// Closes the HTTP client. Call when disposing.
  void close() {
    _client.close();
  }
}
