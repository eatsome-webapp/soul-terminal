import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/di/providers.dart';
import '../../models/conversation.dart';
import '../../models/intervention.dart';
import '../../services/ai/trust_tier_classifier.dart';
import '../../services/vessels/models/vessel_task.dart';
import '../../services/vessels/vessel_manager.dart';
import 'chat_provider.dart';
import 'widgets/autonomous_session_indicator.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/decision_tracker_card.dart';
import 'widgets/error_card.dart';
import 'widgets/hard_approval_card.dart';
import 'widgets/intervention_nudge_card.dart';
import 'widgets/kill_switch_fab.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/scope_guard_card.dart';
import 'widgets/soft_approval_card.dart';
import 'widgets/streaming_indicator.dart';
import 'widgets/task_progress_card.dart';
import 'widgets/task_result_card.dart';
import 'widgets/terminal_command_indicator.dart';
import '../../services/awareness/soul_awareness_service.dart';
import 'widgets/vessel_task_stream_builder.dart';
import 'widgets/agentic_session_header.dart';
import 'widgets/tool_step_card.dart';
import '../agentic/agentic_session_provider.dart';
import '../agentic/project_picker_sheet.dart';

/// Main chat screen where the user talks to SOUL.
///
/// Manages message list display, streaming state, copy/share actions,
/// intervention cards, kill switch, and auto-scroll behavior.
class ChatScreen extends ConsumerStatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final List<InterventionState> _pendingInterventions = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(
          milliseconds: SoulConstants.scrollAnimationDuration,
        ),
        curve: Curves.easeOut,
      );
    }
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareMessage(String content) {
    Share.share(content);
  }

  Future<void> _pickProject(BuildContext context) async {
    final path = await ProjectPickerSheet.show(context);
    if (path != null) {
      await ref.read(agenticSessionProvider.notifier).setProjectDirectory(path);
    }
  }

  void _handleInterventionAccept(InterventionState intervention) {
    setState(() {
      _pendingInterventions.removeWhere((i) => i.id == intervention.id);
    });
    // Resolve the intervention via the engine
    ref.read(vesselManagerProvider);
  }

  void _handleInterventionDismiss(InterventionState intervention) {
    setState(() {
      _pendingInterventions.removeWhere((i) => i.id == intervention.id);
    });
  }

  /// Build a tool result card for intervention-related tool calls.
  Widget? _buildToolResultCard(String toolName, Map<String, dynamic> args) {
    switch (toolName) {
      case 'flag_scope_creep':
        return ScopeGuardCard(
          classification: args['classification'] as String? ?? 'scope_creep',
          request: args['request'] as String? ?? '',
          reason: args['reason'] as String? ?? '',
          redirectTo: args['redirect_to'] as String?,
          onBacklog: () {},
          onOverride: () {},
        );
      case 'track_open_question':
        return DecisionTrackerCard(
          question: args['question'] as String? ?? '',
          openSince: DateTime.now(),
          proposedDefault: args['proposed_default'] as String?,
          options: (args['options'] as List<dynamic>?)
              ?.map((option) => option.toString())
              .toList(),
          onDecide: (_) {},
          onDefer: () {},
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(apiKeyNotifierProvider);
    final hasApiKey = apiKey.isNotEmpty;
    final chatState = ref.watch(
      chatProvider(widget.conversationId),
    );
    final chatNotifier = ref.read(
      chatProvider(widget.conversationId).notifier,
    );
    final claudeService = ref.read(claudeServiceProvider);
    final agenticState = ref.watch(agenticSessionProvider);
    final vesselManager = ref.watch(vesselManagerProvider);
    // Watch awareness state for terminal command indicator
    final awarenessState = ref.watch(soulAwarenessProvider);

    // Auto-scroll when streaming
    ref.listen(chatProvider(widget.conversationId), (prev, next) {
      if (next.status == ChatStatus.streaming ||
          (prev != null && next.messages.length > prev.messages.length)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    // Decision detection SnackBar
    ref.listen<ChatState>(
      chatProvider(widget.conversationId),
      (previous, next) {
        if (next.lastDecisionTitle != null &&
            previous?.lastDecisionTitle != next.lastDecisionTitle) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Decision logged: ${next.lastDecisionTitle}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text(
          'SOUL',
          style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Autonomous session indicator
          StreamBuilder<AutonomousSessionState>(
            stream: vesselManager.autonomousSessionStream,
            builder: (context, snapshot) {
              if (snapshot.data?.status != AutonomousSessionStatus.running) {
                return const SizedBox.shrink();
              }
              return AutonomousSessionIndicator(
                startedAt: snapshot.data!.startedAt,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Select project directory',
            onPressed: () => _pickProject(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasApiKey && chatState.demoExhausted)
            MaterialBanner(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              leading: Icon(
                Icons.key,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              content: Text(
                'Verbind je API key voor de volledige SOUL-ervaring',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.push('/settings'),
                  child: const Text('API Key instellen'),
                ),
              ],
            ),
          Expanded(
            child: Stack(
              children: [
                // Chat content
                chatState.messages.isEmpty &&
                        chatState.status == ChatStatus.idle
                    ? ChatEmptyState(
                        onSuggestionTap: (suggestion) {
                          chatNotifier.sendMessage(suggestion, claudeService);
                        },
                      )
                    : _buildMessageList(chatState),
                // Kill switch FAB (bottom-right, above input)
                Positioned(
                  right: 16,
                  bottom: 80,
                  child: StreamBuilder<AutonomousSessionState>(
                    stream: vesselManager.autonomousSessionStream,
                    builder: (context, snapshot) {
                      final isActive = snapshot.data?.status ==
                          AutonomousSessionStatus.running;
                      return KillSwitchFAB(
                        visible: isActive,
                        onTap: () => vesselManager.killAutonomousSession(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Agentic session header and tool steps
          if (agenticState.isRunning || agenticState.isComplete || agenticState.errorMessage != null) ...[
            AgenticSessionHeader(
              status: agenticState.isRunning
                  ? AgenticSessionStatus.running
                  : agenticState.errorMessage != null
                      ? AgenticSessionStatus.error
                      : AgenticSessionStatus.complete,
              stepCount: agenticState.steps.length,
              costUsd: agenticState.estimatedCostUsd,
              onCancel: agenticState.isRunning
                  ? () => ref.read(agenticSessionProvider.notifier).cancel()
                  : null,
            ),
            ...agenticState.steps.map((step) => ToolStepCard(
                  toolName: step.toolName,
                  input: step.input,
                  output: step.output,
                  stepState: step.isComplete
                      ? (step.isError
                          ? ToolStepState.error
                          : ToolStepState.complete)
                      : ToolStepState.running,
                )),
          ],
          if (chatState.status == ChatStatus.error &&
              chatState.errorType != null)
            ErrorCard(
              errorType: chatState.errorType!,
              onRetry: () => chatNotifier.retryLastMessage(claudeService),
            ),
          if (awarenessState.state != AwarenessState.idle)
            TerminalCommandIndicator(
              commandName: awarenessState.currentCommand ?? '',
            ),
          MessageInput(
            onSend: (text) {
              if (agenticState.projectContext != null) {
                ref.read(agenticSessionProvider.notifier).startTask(text);
              } else {
                chatNotifier.sendMessage(text, claudeService);
              }
            },
            onStop: agenticState.isRunning
                ? () => ref.read(agenticSessionProvider.notifier).cancel()
                : chatNotifier.stopStreaming,
            isStreaming: chatState.status == ChatStatus.streaming || agenticState.isRunning,
            enabled: chatState.status != ChatStatus.streaming && !agenticState.isRunning,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    final chatNotifier = ref.read(
      chatProvider(widget.conversationId).notifier,
    );
    final messages = chatState.messages;
    // Reversed list for chat pattern (newest at bottom)
    final reversedMessages = messages.reversed.toList();

    // Build vessel task cards (reversed so newest appears at bottom)
    final taskCards = _buildVesselTaskCards(chatState, chatNotifier);
    final taskCardCount = taskCards.length;

    // Pending intervention cards count
    final interventionCount = _pendingInterventions.isNotEmpty ? 1 : 0;

    final extraItemCount =
        _streamingIndicatorCount(chatState) + taskCardCount + interventionCount;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: reversedMessages.length + extraItemCount,
      itemBuilder: (context, index) {
        // Intervention card at position 0 (bottom-most when reversed)
        if (index < interventionCount) {
          return InterventionNudgeCard(
            intervention: _pendingInterventions.first,
            onAccept: () =>
                _handleInterventionAccept(_pendingInterventions.first),
            onDismiss: () =>
                _handleInterventionDismiss(_pendingInterventions.first),
          );
        }

        final afterInterventionIndex = index - interventionCount;

        // Items at position 0..taskCardCount-1 are vessel task cards (bottom)
        if (afterInterventionIndex < taskCardCount) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: taskCards[afterInterventionIndex],
            ),
          );
        }

        final afterTaskIndex = afterInterventionIndex - taskCardCount;

        // Streaming indicator sits right after task cards
        if (afterTaskIndex == 0 && _showStreamingIndicator(chatState)) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: StreamingIndicator(),
          );
        }

        final adjustedIndex = _showStreamingIndicator(chatState)
            ? afterTaskIndex - 1
            : afterTaskIndex;
        final message = reversedMessages[adjustedIndex];
        final isStreaming = chatState.status == ChatStatus.streaming &&
            adjustedIndex == 0 &&
            message.role == MessageRole.assistant;

        // Determine if we should show the SOUL label (first assistant msg in group)
        final originalIndex = messages.length - 1 - adjustedIndex;
        final showSoulLabel = message.role == MessageRole.assistant &&
            (originalIndex == 0 ||
                messages[originalIndex - 1].role != MessageRole.assistant);

        // Spacing between messages
        final prevOriginalIndex = originalIndex + 1;
        final hasDifferentSender = prevOriginalIndex < messages.length &&
            messages[prevOriginalIndex].role != message.role;

        return Padding(
          padding: EdgeInsets.only(
            top: hasDifferentSender ? 24 : 8,
          ),
          child: MessageBubble(
            message: message,
            isStreaming: isStreaming,
            showSoulLabel: showSoulLabel,
            onCopy: message.role == MessageRole.assistant
                ? () => _copyMessage(message.content)
                : null,
            onShare: message.role == MessageRole.assistant
                ? () => _shareMessage(message.content)
                : null,
          ),
        );
      },
    );
  }

  /// Build vessel task card widgets based on current task states.
  /// Returns cards in reversed order (newest first) for the reversed ListView.
  /// Uses VesselTaskCardBuilder for tier-aware rendering: autonomous shows
  /// minimal text, softApproval shows SoftApprovalCard, hardApproval shows
  /// HardApprovalCard. Completed/failed tasks show TaskResultCard (VES-11).
  List<Widget> _buildVesselTaskCards(
    ChatState chatState,
    ChatNotifier notifier,
  ) {
    final tasks = chatState.vesselTasks.values.toList();
    if (tasks.isEmpty) return [];

    final cards = <Widget>[];
    var hasActiveProposal = false;

    for (final task in tasks.reversed) {
      // Skip rejected tasks
      if (task is RejectedTask) continue;

      // Only show one active proposal at a time
      if (task is ProposedTask) {
        if (hasActiveProposal) continue;
        hasActiveProposal = true;

        // Autonomous tier: show minimal indicator instead of approval card
        if (task.tier == TrustTier.autonomous) {
          cards.add(_buildAutonomousActionIndicator(task));
          continue;
        }
      }

      cards.add(
        VesselTaskCardBuilder(
          key: ValueKey('vessel-${task.id}'),
          task: task,
          onApprove: () => notifier.approveVesselTask(task.id),
          onReject: () => notifier.rejectVesselTask(task.id),
          onRetry: task is FailedTask
              ? () => notifier.retryVesselTask(task.id)
              : null,
        ),
      );
    }

    return cards;
  }

  Widget _buildAutonomousActionIndicator(VesselTask task) {
    final toolName = task is ProposedTask ? task.toolName : 'unknown';
    return Padding(
      key: ValueKey('auto-${task.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        '$toolName uitgevoerd (autonoom)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }

  bool _showStreamingIndicator(ChatState chatState) {
    if (chatState.status != ChatStatus.streaming) return false;
    if (chatState.messages.isEmpty) return false;
    final lastMessage = chatState.messages.last;
    return lastMessage.role == MessageRole.assistant &&
        lastMessage.content.isEmpty;
  }

  int _streamingIndicatorCount(ChatState chatState) {
    return _showStreamingIndicator(chatState) ? 1 : 0;
  }
}
