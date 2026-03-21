import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/providers.dart';
import '../../core/utils/logger.dart';
import '../../models/conversation.dart';
import '../../models/prompt_context.dart';
import '../../services/ai/claude_service.dart';
import '../../services/ai/context_injector.dart';
import '../../services/chat/offline_message_queue.dart';
import '../../services/demo/demo_mode_service.dart';
import '../../services/demo/demo_templates.dart';
import '../../services/memory/memory_service.dart';
import '../../services/success/celebration_service.dart';
import '../../services/success/momentum_calculator.dart';
import '../../services/demo/feature_discovery_service.dart';
import '../../services/platform/permission_service.dart';
import '../../services/database/daos/settings_dao.dart';
import '../../services/vessels/models/vessel_task.dart';
import '../../services/vessels/vessel_manager.dart';

part 'chat_provider.g.dart';

enum ChatStatus { idle, streaming, error, queued }

/// Immutable state for a chat conversation.
class ChatState {
  final List<Message> messages;
  final ChatStatus status;
  final String? errorType;
  final String? lastDecisionTitle;
  final Map<String, VesselTask> vesselTasks;
  final bool demoExhausted;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.errorType,
    this.lastDecisionTitle,
    this.vesselTasks = const {},
    this.demoExhausted = false,
  });

  ChatState copyWith({
    List<Message>? messages,
    ChatStatus? status,
    String? errorType,
    String? lastDecisionTitle,
    Map<String, VesselTask>? vesselTasks,
    bool? demoExhausted,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorType: errorType,
      lastDecisionTitle: lastDecisionTitle,
      vesselTasks: vesselTasks ?? this.vesselTasks,
      demoExhausted: demoExhausted ?? this.demoExhausted,
    );
  }
}

/// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
///
/// Handles sending messages, streaming responses from Claude,
/// error classification, stop/retry actions, and database persistence.
@riverpod
class ChatNotifier extends _$ChatNotifier {
  StreamSubscription<String>? _streamSubscription;
  StreamSubscription<VesselTask>? _vesselTaskSubscription;
  String? _activeConversationId;

  @override
  ChatState build(String? conversationId) {
    if (conversationId != null) {
      _activeConversationId = conversationId;
      _loadMessages(conversationId);
    }

    // Subscribe to all vessel task updates globally
    final vesselManager = ref.read(vesselManagerProvider);
    _vesselTaskSubscription?.cancel();
    _vesselTaskSubscription = vesselManager.taskUpdates.listen((task) {
      _updateVesselTask(task);
    });

    ref.onDispose(() {
      _vesselTaskSubscription?.cancel();
    });

    // Listen for vessel onboarding trigger
    ref.listen<OnboardingPending>(onboardingPendingProvider, (previous, next) {
      if (next.isPending && !(previous?.isPending ?? false)) {
        final vesselName = next.vesselName ?? 'vessel';
        injectSoulMessage(
          'Je $vesselName is verbonden! Ik heb nu toegang tot een hele set tools — '
          "commando's uitvoeren, de browser bedienen, berichten sturen via 50+ kanalen, "
          'cron jobs plannen, en meer.\n\n'
          'Wil je dat ik je door de setup begeleid zodat we alles optimaal configureren? '
          'Of vertel me gewoon wat je als eerste wil aanpakken.',
        );
        // Clear pending flag
        ref.read(onboardingPendingProvider.notifier).clear();
      }
    });

    // Check for pending onboarding that may have been set while ChatNotifier was inactive
    final pendingOnboarding = ref.read(onboardingPendingProvider);
    if (pendingOnboarding.isPending) {
      // Schedule injection after build completes (cannot modify state during build)
      Future.microtask(() {
        final vesselName = pendingOnboarding.vesselName ?? 'vessel';
        injectSoulMessage(
          'Je $vesselName is verbonden! Ik heb nu toegang tot een hele set tools — '
          "commando's uitvoeren, de browser bedienen, berichten sturen via 50+ kanalen, "
          'cron jobs plannen, en meer.\n\n'
          'Wil je dat ik je door de setup begeleid zodat we alles optimaal configureren? '
          'Of vertel me gewoon wat je als eerste wil aanpakken.',
        );
        ref.read(onboardingPendingProvider.notifier).clear();
      });
    }

    // For new conversations (no conversationId), pre-populate SOUL's opening message
    if (conversationId == null) {
      final openingMessage = Message(
        id: const Uuid().v4(),
        conversationId: '',
        role: MessageRole.assistant,
        content: DemoTemplates.openingMessage,
        createdAt: DateTime.now(),
      );
      return ChatState(messages: [openingMessage]);
    }

    return const ChatState();
  }

  /// Update a single vessel task in state from the global task stream.
  void _updateVesselTask(VesselTask task) {
    state = state.copyWith(
      vesselTasks: {...state.vesselTasks, task.id: task},
    );
  }

  /// Loads existing messages from the database for an existing conversation.
  Future<void> _loadMessages(String conversationId) async {
    final dao = ref.read(conversationDaoProvider);
    try {
      final dbMessages =
          await dao.getMessagesForConversation(conversationId);
      if (dbMessages.isEmpty) return;

      final messages = dbMessages
          .map(
            (m) => Message(
              id: m.id,
              conversationId: m.conversationId,
              role: m.role == 'user' ? MessageRole.user : MessageRole.assistant,
              content: m.content,
              createdAt:
                  DateTime.fromMillisecondsSinceEpoch(m.createdAt),
              tokenCount: m.tokenCount,
            ),
          )
          .toList();
      state = state.copyWith(messages: messages);
    } catch (e) {
      log.e('Failed to load messages: $e');
    }
  }

  /// Sends a user message and streams the assistant response.
  ///
  /// If offline, queues the message for later replay.
  /// Otherwise, persists user + assistant messages to the database.
  Future<void> sendMessage(String text, ClaudeService claudeService) async {
    final convId = _activeConversationId ?? const Uuid().v4();
    _activeConversationId = convId;

    final isOffline = ref.read(isOfflineProvider);
    final dao = ref.read(conversationDaoProvider);

    final userMessage = Message(
      id: const Uuid().v4(),
      conversationId: convId,
      role: MessageRole.user,
      content: text,
      createdAt: DateTime.now(),
    );

    // If offline, queue the message and return
    if (isOffline) {
      state = state.copyWith(
        messages: [...state.messages, userMessage],
        status: ChatStatus.queued,
        errorType: null,
      );

      // Persist user message locally even when offline
      await _ensureConversationExists(dao, convId, text);
      await _persistMessage(dao, userMessage);

      final queue = ref.read(offlineMessageQueueProvider);
      queue.enqueue(
        QueuedMessage(
          text: text,
          conversationId: convId,
          queuedAt: DateTime.now(),
        ),
      );
      return;
    }

    // Check if API key is missing and demo mode is active
    final apiKey = ref.read(apiKeyNotifierProvider);
    if (apiKey.isEmpty) {
      final demoService = ref.read(demoModeServiceProvider);
      final isDemoActive = await demoService.isDemoActive();

      if (isDemoActive) {
        // Use demo mode instead of Claude API
        state = state.copyWith(
          messages: [...state.messages, userMessage],
          status: ChatStatus.streaming,
          errorType: null,
        );

        await _ensureConversationExists(dao, convId, text);
        await _persistMessage(dao, userMessage);

        final demoResponse = await demoService.generateDemoResponse(text);
        if (demoResponse != null) {
          final demoAssistant = Message(
            id: const Uuid().v4(),
            conversationId: convId,
            role: MessageRole.assistant,
            content: demoResponse,
            createdAt: DateTime.now(),
          );
          state = state.copyWith(
            messages: [...state.messages, demoAssistant],
            status: ChatStatus.idle,
          );
          await _persistMessage(dao, demoAssistant);

          // Check if demo is now exhausted
          final remaining = await demoService.getRemainingInteractions();
          if (remaining <= 0) {
            state = state.copyWith(demoExhausted: true);
          }
        }
        return;
      } else {
        // Demo exhausted, no API key — show exhaustion state
        state = state.copyWith(
          messages: [...state.messages, userMessage],
          status: ChatStatus.idle,
          demoExhausted: true,
        );
        return;
      }
    }

    // Create empty assistant message placeholder for streaming
    final assistantMessage = Message(
      id: const Uuid().v4(),
      conversationId: convId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantMessage],
      status: ChatStatus.streaming,
      errorType: null,
      lastDecisionTitle: null,
    );

    // Persist conversation and user message
    await _ensureConversationExists(dao, convId, text);
    await _persistMessage(dao, userMessage);

    try {
      // 1. Retrieve memory context and phone context before Claude call
      final memoryService = ref.read(memoryServiceProvider);
      final decisionDetector = ref.read(decisionDetectorProvider);
      final contextInjector = ref.read(contextInjectorProvider);
      final moodAdapter = ref.read(moodAdapterProvider);
      final decisionTracker = ref.read(decisionTrackerProvider);
      final memoryContext = await memoryService.getContext(text);
      final phoneContext = await contextInjector.buildFullContext();

      // Analyze mood state via Haiku sidecar (fires every Nth message)
      final recentUserMessages = state.messages
          .where((m) => m.role == MessageRole.user)
          .take(5)
          .map((m) => m.content)
          .toList();
      await moodAdapter.onUserMessage(
        recentMessages: recentUserMessages,
        sessionId: convId,
      );

      // Query open questions for system prompt injection
      final openQuestions = await decisionTracker.getOpenQuestions();

      final buffer = StringBuffer();

      // Build history excluding the empty assistant placeholder
      final history = state.messages
          .where((m) => m.content.isNotEmpty)
          .toList()
        ..removeLast(); // Remove the latest user message (sent separately)

      // Phase 8: Calculate momentum score and gather celebration context
      final momentumCalculator = ref.read(momentumCalculatorProvider);
      final celebrationService = ref.read(celebrationServiceProvider);
      double? momentumScore;
      String? celebrationContext;
      try {
        momentumScore = await momentumCalculator.calculate();
      } catch (_) {}
      try {
        celebrationContext =
            await celebrationService.getCelebrationContextForPrompt();
      } catch (_) {}

      // Load connected vessel capabilities for VesselContextLayer
      List<VesselCapabilitySummary>? connectedVessels;
      try {
        final vesselManager = ref.read(vesselManagerProvider);
        final vesselDao = ref.read(vesselDaoProvider);
        final vesselSummaries = <VesselCapabilitySummary>[];

        // Check OpenClaw
        if (vesselManager.openClawClient != null) {
          final groups = await vesselDao.getCapabilityGroups('openclaw');
          vesselSummaries.add(VesselCapabilitySummary(
            vesselId: 'openclaw',
            vesselName: 'OpenClaw',
            status: 'connected',
            capabilityGroups: groups,
          ));
        }

        // Check Agent SDK
        if (vesselManager.agentSdkClient != null) {
          vesselSummaries.add(VesselCapabilitySummary(
            vesselId: 'agentsdk',
            vesselName: 'Agent SDK Relay',
            status: 'connected',
            capabilityGroups: ['deep_coding', 'file', 'execute'],
          ));
        }

        if (vesselSummaries.isNotEmpty) {
          connectedVessels = vesselSummaries;
        }
      } catch (e) {
        // Non-critical — VesselContextLayer will show empty placeholder
      }

      // Load bootstrap step for active onboarding
      int? vesselBootstrapStep;
      try {
        final settingsDao = ref.read(settingsDaoProvider);
        // Check OpenClaw bootstrap (primary vessel)
        final stepStr = await settingsDao.getString(
          SettingsKeys.vesselBootstrapStep('openclaw'),
        );
        if (stepStr != null) {
          final completed = await settingsDao.getString(
            SettingsKeys.vesselBootstrapCompleted('openclaw'),
          );
          if (completed != 'true') {
            vesselBootstrapStep = int.tryParse(stepStr) ?? 0;
          }
        }
      } catch (_) {}

      // 2. Stream response with unified PromptContext including mood + open questions
      final currentMood = moodAdapter.currentMood;
      final promptContext = PromptContext(
        memory: memoryContext,
        phoneContext: phoneContext.isNotEmpty ? phoneContext : null,
        moodState: currentMood != null
            ? MoodState(
                energy: currentMood.energy,
                emotion: currentMood.emotion,
                intent: currentMood.intent,
              )
            : null,
        detectedLanguage: contextInjector.detectLanguage(text),
        openQuestions: openQuestions.isNotEmpty
            ? openQuestions
                .map((i) => OpenQuestion(
                      question: i.triggerDescription,
                      openSince: i.detectedAt,
                      proposedDefault: i.proposedDefault,
                    ))
                .toList()
            : null,
        momentumScore: momentumScore,
        distilledFacts: celebrationContext ?? '',
        connectedVessels: connectedVessels,
        vesselBootstrapStep: vesselBootstrapStep,
      );
      final stream = claudeService.streamMessage(
        userText: text,
        conversationHistory: history,
        promptContext: promptContext,
      );

      await for (final delta in stream) {
        buffer.write(delta);
        final updatedAssistant = assistantMessage.copyWith(
          content: buffer.toString(),
        );
        state = state.copyWith(
          messages: [
            ...state.messages.sublist(0, state.messages.length - 1),
            updatedAssistant,
          ],
        );
      }

      state = state.copyWith(status: ChatStatus.idle);

      // Persist the assistant message
      final finalContent = buffer.toString();
      final finalAssistant = assistantMessage.copyWith(content: finalContent);
      await _persistMessage(dao, finalAssistant);

      // Increment bootstrap step after each user message during onboarding
      if (vesselBootstrapStep != null) {
        try {
          final nextStep = vesselBootstrapStep + 1;
          final settingsDao = ref.read(settingsDaoProvider);
          if (nextStep >= 5) {
            // Onboarding complete
            await settingsDao.setString(
              SettingsKeys.vesselBootstrapCompleted('openclaw'),
              'true',
            );
            log.i('Vessel bootstrap completed for openclaw');
          } else {
            await settingsDao.setString(
              SettingsKeys.vesselBootstrapStep('openclaw'),
              nextStep.toString(),
            );
          }
        } catch (_) {}
      }

      // 3. Process tool calls for decision detection + scope guard + open questions
      final toolCalls = claudeService.getLastToolCalls();
      for (final call in toolCalls) {
        switch (call.name) {
          case 'log_decision':
            final title = await decisionDetector.processToolUse(
              conversationId: convId,
              messageId: finalAssistant.id,
              input: call.input,
            );
            if (title != null) {
              state = state.copyWith(lastDecisionTitle: title);
            }
            break;
          case 'flag_scope_creep':
            final scopeGuard = ref.read(scopeGuardProvider);
            await scopeGuard.processToolUse(
              conversationId: convId,
              messageId: finalAssistant.id,
              input: call.input,
            );
            break;
          case 'track_open_question':
            final decisionTracker = ref.read(decisionTrackerProvider);
            await decisionTracker.processToolUse(
              conversationId: convId,
              input: call.input,
            );
            break;
        }
      }

      // 4. Detect feature discovery from SOUL's response
      await _detectFeatureDiscovery(finalContent);

      // 5. Embed both messages async (non-blocking, fire-and-forget)
      memoryService.embedMessage(userMessage.id, text);
      memoryService.embedMessage(finalAssistant.id, finalContent);

      // 6. Trigger profile learning check
      try {
        final profileLearner = ref.read(profileLearnerProvider);
        profileLearner.onConversationComplete();
      } catch (_) {}

      // Update conversation preview with first 100 chars
      final preview = finalContent.length > 100
          ? '${finalContent.substring(0, 100)}...'
          : finalContent;
      await dao.updateConversationPreview(convId, preview);

      // Auto-title after first exchange (user + assistant = 2 messages)
      if (state.messages.length == 2) {
        final title = text.length > 40 ? '${text.substring(0, 37)}...' : text;
        await dao.updateConversationTitle(convId, title);
      }
    } catch (e) {
      log.e('Stream error: $e');
      final errorType = _classifyError(e.toString());

      // Remove the empty assistant message on error
      state = state.copyWith(
        messages:
            state.messages.where((m) => m.content.isNotEmpty).toList(),
        status: ChatStatus.error,
        errorType: errorType,
      );
    }
  }

  /// Creates the conversation in DB if it doesn't exist yet.
  Future<void> _ensureConversationExists(
    dynamic dao,
    String convId,
    String firstMessageText,
  ) async {
    try {
      final existing = await dao.getConversation(convId);
      if (existing == null) {
        await dao.createConversation(
          id: convId,
          title: 'New conversation',
        );
      }
    } catch (e) {
      log.e('Failed to ensure conversation exists: $e');
    }
  }

  /// Persists a message to the database.
  Future<void> _persistMessage(dynamic dao, Message message) async {
    try {
      await dao.insertMessage(
        id: message.id,
        conversationId: message.conversationId,
        role: message.role == MessageRole.user ? 'user' : 'assistant',
        content: message.content,
        tokenCount: message.tokenCount,
      );
    } catch (e) {
      log.e('Failed to persist message: $e');
    }
  }

  /// Cancels the current streaming response.
  void stopStreaming() {
    _streamSubscription?.cancel();
    state = state.copyWith(status: ChatStatus.idle);
  }

  /// Resends the last user message after an error.
  void retryLastMessage(ClaudeService claudeService) {
    final lastUserMessage = state.messages.lastWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => throw StateError('No user message to retry'),
    );
    state = state.copyWith(status: ChatStatus.idle, errorType: null);
    sendMessage(lastUserMessage.content, claudeService);
  }

  /// Classifies error string into user-friendly error types.
  String _classifyError(String errorStr) {
    final lower = errorStr.toLowerCase();
    if (lower.contains('socket') || lower.contains('connection')) {
      return 'network';
    }
    if (lower.contains('401') || lower.contains('auth')) {
      return 'apiKey';
    }
    if (lower.contains('429') || lower.contains('rate')) {
      return 'rateLimit';
    }
    return 'generic';
  }

  // --- Proactive Message Injection ---

  /// Inject a proactive SOUL message into the active conversation.
  /// Used for vessel onboarding and other proactive communication.
  void injectSoulMessage(String content) {
    final conversationId = _activeConversationId ?? '';
    final message = Message(
      id: const Uuid().v4(),
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: content,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, message],
    );
    // Persist to DB — reuse existing _persistMessage helper
    final dao = ref.read(conversationDaoProvider);
    _persistMessage(dao, message);
  }

  // --- Contextual Permission Requests ---

  /// Check notification permission before dispatching briefings or alerts.
  /// Returns true if granted. If not granted, adds a permission request
  /// message to the chat instead of silently failing.
  Future<bool> _ensureNotificationPermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    final hasPermission =
        await permissionService.isNotificationPermissionGranted();
    if (hasPermission) return true;

    // Insert a system message requesting permission contextually
    final permissionMessage = Message(
      id: const Uuid().v4(),
      conversationId: _activeConversationId ?? '',
      role: MessageRole.assistant,
      content:
          'Ik wil je briefings sturen, maar ik heb toestemming nodig voor notificaties. Geef je toestemming via de kaart hieronder.',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, permissionMessage],
    );
    return false;
  }

  /// Check calendar permission before reading calendar or syncing deadlines.
  Future<bool> _ensureCalendarPermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    final hasPermission =
        await permissionService.isCalendarPermissionGranted();
    if (hasPermission) return true;

    final permissionMessage = Message(
      id: const Uuid().v4(),
      conversationId: _activeConversationId ?? '',
      role: MessageRole.assistant,
      content:
          'Om je deadlines te synchroniseren heb ik toegang tot je agenda nodig.',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, permissionMessage],
    );
    return false;
  }

  /// Check contacts permission before accessing contacts.
  Future<bool> _ensureContactsPermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    final hasPermission =
        await permissionService.isContactsPermissionGranted();
    if (hasPermission) return true;

    final permissionMessage = Message(
      id: const Uuid().v4(),
      conversationId: _activeConversationId ?? '',
      role: MessageRole.assistant,
      content:
          'Om informatie over je contacten op te zoeken heb ik toegang tot je contactenlijst nodig.',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, permissionMessage],
    );
    return false;
  }

  // --- Feature Discovery ---

  /// Detect feature mentions in SOUL's response and mark them as discovered.
  Future<void> _detectFeatureDiscovery(String soulResponse) async {
    final FeatureDiscoveryService discoveryService;
    try {
      discoveryService = ref.read(featureDiscoveryServiceProvider);
    } catch (_) {
      return;
    }

    final featureKeywords = {
      'decisions': ['beslissing', 'decision', 'beslislog'],
      'memory': ['herinner', 'remember', 'vorige sessie', 'eerder besproken'],
      'briefings': ['briefing', 'ochtend', 'morning', 'dagelijks'],
      'vessels': ['vessel', 'OpenClaw', 'automatiser', 'CI/CD'],
      'terminal': ['terminal', 'shell', 'command'],
      'multi_project': ['project', 'portfolio', 'meerdere projecten'],
    };

    final lowerResponse = soulResponse.toLowerCase();
    for (final entry in featureKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerResponse.contains(keyword.toLowerCase())) {
          await discoveryService.markDiscovered(entry.key);
          break;
        }
      }
    }
  }

  // --- Vessel Task Methods ---

  /// Propose a vessel task from within a conversation.
  /// Called when SOUL determines a tool execution is needed.
  Future<void> proposeVesselTask({
    required String description,
    required String tool,
    required Map<String, dynamic> args,
  }) async {
    final vesselManager = ref.read(vesselManagerProvider);
    final task = await vesselManager.proposeTask(
      description: description,
      tool: tool,
      args: args,
      conversationId: _activeConversationId,
    );

    state = state.copyWith(
      vesselTasks: {...state.vesselTasks, task.id: task},
    );

    _listenToTaskUpdates(task.id);
  }

  /// Approve a proposed vessel task (VES-09).
  Future<void> approveVesselTask(String taskId) async {
    final vesselManager = ref.read(vesselManagerProvider);
    await vesselManager.approveTask(taskId);
  }

  /// Reject a proposed vessel task (VES-09).
  Future<void> rejectVesselTask(String taskId) async {
    final vesselManager = ref.read(vesselManagerProvider);
    await vesselManager.rejectTask(taskId);
  }

  /// Retry a failed vessel task.
  Future<void> retryVesselTask(String taskId) async {
    final vesselManager = ref.read(vesselManagerProvider);
    await vesselManager.retryTask(taskId);
  }

  /// Listen for state changes on a specific task and update local state.
  void _listenToTaskUpdates(String taskId) {
    final vesselManager = ref.read(vesselManagerProvider);
    vesselManager.taskUpdates
        .where((task) => task.id == taskId)
        .listen((task) {
      state = state.copyWith(
        vesselTasks: {...state.vesselTasks, task.id: task},
      );
    });
  }
}
