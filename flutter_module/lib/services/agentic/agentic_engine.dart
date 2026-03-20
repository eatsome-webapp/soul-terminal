import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as sdk;

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../database/daos/wal_dao.dart';
import 'agentic_event.dart';
import 'tool_registry.dart';

/// Configuration for an agentic session.
class AgenticConfig {
  final int maxIterations;
  final String model;
  final double costLimitUsd;

  const AgenticConfig({
    this.maxIterations = 25,
    this.model = SoulConstants.defaultModel,
    this.costLimitUsd = 1.0,
  });
}

/// Core agentic engine that runs the tool_use loop.
///
/// Separate from ClaudeService -- this manages multi-turn tool execution.
/// ClaudeService continues to serve regular (non-agentic) chat.
///
/// Flow: user task -> Claude API -> tool_use blocks -> execute locally ->
///       tool_results back -> repeat until end_turn or max iterations.
class AgenticEngine {
  final sdk.AnthropicClient _client;
  final ToolRegistry _toolRegistry;
  final WalDao? _walDao;
  bool _cancelled = false;

  AgenticEngine({
    required sdk.AnthropicClient client,
    required ToolRegistry toolRegistry,
    WalDao? walDao,
  })  : _client = client,
        _toolRegistry = toolRegistry,
        _walDao = walDao;

  /// Cancel the currently running agentic session.
  /// Stops after the current tool execution completes.
  void cancel() {
    _cancelled = true;
    log.i('Agentic session cancel requested');
  }

  /// Run an agentic task. Yields AgentEvent stream for UI consumption.
  ///
  /// [task] -- The user's coding task description.
  /// [systemPrompt] -- System prompt (from AgenticPromptComposer).
  /// [config] -- Session configuration (max iterations, model).
  Stream<AgentEvent> run({
    required String task,
    required String systemPrompt,
    AgenticConfig config = const AgenticConfig(),
  }) async* {
    _cancelled = false;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    var totalInputTokens = 0;
    var totalOutputTokens = 0;
    var iteration = 0;

    // Build initial messages
    final messages = <sdk.InputMessage>[
      sdk.InputMessage.user(task),
    ];

    final tools = _toolRegistry.toAnthropicTools();
    if (tools.isEmpty) {
      yield const AgentError('No tools registered in ToolRegistry');
      return;
    }

    log.i('Starting agentic session: ${task.length} chars, '
        '${tools.length} tools, max ${config.maxIterations} iterations');

    while (!_cancelled && iteration < config.maxIterations) {
      iteration++;
      log.d('Agentic iteration $iteration/${config.maxIterations}');

      try {
        // Stream this round from Claude
        final stream = _client.messages.createStream(
          sdk.MessageCreateRequest(
            model: config.model,
            maxTokens: 4096,
            system: sdk.SystemPrompt.text(systemPrompt),
            messages: messages,
            tools: tools,
          ),
        );

        // Accumulate response content blocks for the next round
        final responseBlocks = <sdk.InputContentBlock>[];
        final toolUseBlocks = <_PendingToolUse>[];
        sdk.StopReason? stopReason;

        // Parse streaming events
        String currentToolId = '';
        String currentToolName = '';
        final toolInputBuffer = StringBuffer();
        final textBuffer = StringBuffer();
        bool inToolUse = false;

        await for (final event in stream) {
          if (_cancelled) break;

          if (event is sdk.MessageStartEvent) {
            final usage = event.message.usage;
            totalInputTokens += usage.inputTokens;
          } else if (event is sdk.ContentBlockStartEvent) {
            final block = event.contentBlock;
            if (block is sdk.ToolUseBlock) {
              // Flush accumulated text before tool use block
              if (textBuffer.isNotEmpty) {
                responseBlocks
                    .add(sdk.TextInputBlock(textBuffer.toString()));
                textBuffer.clear();
              }
              inToolUse = true;
              currentToolId = block.id;
              currentToolName = block.name;
              toolInputBuffer.clear();
            }
          } else if (event is sdk.ContentBlockDeltaEvent) {
            final delta = event.delta;
            if (delta is sdk.TextDelta) {
              yield AgentTextDelta(delta.text);
              textBuffer.write(delta.text);
            } else if (delta is sdk.InputJsonDelta && inToolUse) {
              toolInputBuffer.write(delta.partialJson);
            }
          } else if (event is sdk.ContentBlockStopEvent) {
            if (inToolUse) {
              try {
                final input = jsonDecode(toolInputBuffer.toString())
                    as Map<String, dynamic>;
                toolUseBlocks.add(_PendingToolUse(
                  id: currentToolId,
                  name: currentToolName,
                  input: input,
                ));
                responseBlocks.add(sdk.ToolUseInputBlock(
                  id: currentToolId,
                  name: currentToolName,
                  input: input,
                ));
              } catch (e) {
                log.w('Failed to parse tool input JSON: $e');
              }
              inToolUse = false;
            }
          } else if (event is sdk.MessageDeltaEvent) {
            stopReason = event.delta.stopReason;
            totalOutputTokens += event.usage.outputTokens;
          }
        }

        // Flush any remaining text
        if (textBuffer.isNotEmpty) {
          responseBlocks.add(sdk.TextInputBlock(textBuffer.toString()));
          textBuffer.clear();
        }

        if (_cancelled) {
          yield const AgentError('Cancelled by user');
          return;
        }

        // Check cost limit after each round
        final runningCost = _calculateCost(
            totalInputTokens, totalOutputTokens, config.model);
        if (runningCost >= config.costLimitUsd) {
          yield AgentError(
            'Cost limit reached (\$${runningCost.toStringAsFixed(2)} >= '
            '\$${config.costLimitUsd.toStringAsFixed(2)}). '
            'Increase the limit in settings or start a new session.',
          );
          return;
        }

        // If no tool calls, we're done (end_turn or max_tokens)
        if (toolUseBlocks.isEmpty) {
          yield AgentComplete(totalInputTokens, totalOutputTokens, iteration,
              _calculateCost(totalInputTokens, totalOutputTokens, config.model));
          return;
        }

        // Execute tool calls sequentially (so we can yield events in stream)
        final toolResultBlocks = <sdk.InputContentBlock>[];

        for (final toolUse in toolUseBlocks) {
          // Extract intention from accumulated text before tool use
          final intention = textBuffer.toString().trim();
          int? walId;
          if (_walDao != null) {
            walId = await _walDao!.insertEntry(
              sessionId: sessionId,
              iteration: iteration,
              intention: intention.isNotEmpty ? intention : 'Executing ${toolUse.name}',
              toolName: toolUse.name,
              toolArgs: jsonEncode(toolUse.input),
              startedAt: DateTime.now().millisecondsSinceEpoch,
            );
            yield AgentWalEntry(
              intention.isNotEmpty ? intention : 'Executing ${toolUse.name}',
              toolUse.name,
              walId,
            );
          }

          yield AgentToolStart(toolUse.name, toolUse.id, toolUse.input);

          if (_cancelled) {
            yield const AgentError('Cancelled by user');
            return;
          }

          final result = await _toolRegistry.executeTool(
            toolUse.name,
            toolUse.input,
          );

          final isError =
              result.startsWith('Error:') ||
              result.startsWith('Error executing');
          yield AgentToolResult(toolUse.id, toolUse.name, result,
              isError: isError);

          if (_walDao != null && walId != null) {
            final statusStr = isError ? 'failed' : 'completed';
            await _walDao!.updateStatus(
              walId,
              statusStr,
              resultSummary: result.length > 200 ? result.substring(0, 200) : result,
              completedAt: DateTime.now().millisecondsSinceEpoch,
            );
          }

          toolResultBlocks.add(sdk.ToolResultInputBlock(
            toolUseId: toolUse.id,
            content: [sdk.ToolResultTextContent(result)],
            isError: isError,
          ));
        }

        // Add Claude's response and tool results to message history
        messages.add(sdk.InputMessage.assistantBlocks(responseBlocks));
        messages.add(sdk.InputMessage.userBlocks(toolResultBlocks));

        // If stop_reason was end_turn (not tool_use), we're done
        if (stopReason == sdk.StopReason.endTurn) {
          yield AgentComplete(totalInputTokens, totalOutputTokens, iteration,
              _calculateCost(totalInputTokens, totalOutputTokens, config.model));
          return;
        }

        // Otherwise continue loop (stop_reason == 'tool_use')
      } catch (e, stackTrace) {
        log.e('Agentic loop error at iteration $iteration: $e');
        yield AgentError('Error at step $iteration: $e');
        return;
      }
    }

    // Reached max iterations or cancelled
    if (_cancelled) {
      yield const AgentError('Cancelled by user');
    } else {
      yield AgentError(
        'Reached maximum iterations (${config.maxIterations}). '
        'Task may be incomplete.',
      );
    }
  }

  /// Check for incomplete WAL entries from a previous interrupted session.
  /// Returns recovery context string for self-correction, or null if clean.
  Future<String?> getRecoveryContext() async {
    if (_walDao == null) return null;
    final incomplete = await _walDao!.getIncompleteEntries();
    if (incomplete.isEmpty) return null;

    final buffer = StringBuffer();
    buffer.writeln('Previous session was interrupted. These actions were incomplete:');
    for (final entry in incomplete) {
      buffer.writeln('- [${entry.status}] ${entry.toolName}: ${entry.intention}');
    }
    return buffer.toString();
  }

  /// Calculate running cost based on token usage and model.
  double _calculateCost(int inputTokens, int outputTokens, String model) {
    final isOpus = model.contains('opus');
    final inputRate = isOpus
        ? SoulConstants.opusInputCostPerMTok
        : SoulConstants.sonnetInputCostPerMTok;
    final outputRate = isOpus
        ? SoulConstants.opusOutputCostPerMTok
        : SoulConstants.sonnetOutputCostPerMTok;
    return (inputTokens * inputRate / 1000000) +
        (outputTokens * outputRate / 1000000);
  }

  /// Dispose the engine and close HTTP client.
  void dispose() {
    _cancelled = true;
    _client.close();
  }
}

/// Internal class for pending tool execution.
class _PendingToolUse {
  final String id;
  final String name;
  final Map<String, dynamic> input;

  const _PendingToolUse({
    required this.id,
    required this.name,
    required this.input,
  });
}
