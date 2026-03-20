import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/objectbox.dart';

import '../bridge/pigeon_bridge_handler.dart';

import '../../services/auth/api_key_service.dart';
import '../../services/ai/claude_service.dart';
import '../../services/ai/cost_tracker.dart';
import '../../services/ai/decision_detector.dart';
import '../../services/ai/decision_tracker.dart';
import '../../services/ai/scope_guard.dart';
import '../../services/ai/mood_adapter.dart';
import '../../services/ai/intervention_config.dart';
import '../../services/chat/offline_message_queue.dart';
import '../../services/database/daos/mood_dao.dart';
import '../../services/database/daos/intervention_dao.dart';
import '../../services/database/daos/conversation_dao.dart';
import '../../services/database/daos/decision_dao.dart';
import '../../services/database/daos/project_dao.dart';
import '../../services/database/daos/project_state_dao.dart';
import '../../services/database/daos/profile_dao.dart';
import '../../services/database/soul_database.dart';
import '../../services/memory/embedding_service.dart';
import '../../services/memory/memory_service.dart';
import '../../services/memory/profile_learner.dart';
import '../../services/memory/vector_store.dart';
import '../../services/database/daos/vessel_dao.dart';
import '../../services/database/daos/contacts_dao.dart';
import '../../services/database/daos/calendar_dao.dart';
import '../../services/database/daos/notification_dao.dart';
import '../../services/database/daos/briefing_dao.dart';
import '../../services/database/daos/settings_dao.dart';
import '../../services/database/daos/api_usage_dao.dart';
import '../../services/database/daos/audit_dao.dart';
import '../../services/ai/trust_tier_classifier.dart';
import '../../services/vessels/vessel_router.dart';
import '../../services/vessels/vessel_manager.dart';
import '../../services/vessels/openclaw/openclaw_service.dart';
import '../../services/vessels/openclaw/openclaw_ci_monitor.dart';
import '../../services/platform/permission_service.dart';
import '../../services/platform/foreground_service_manager.dart';
import '../../services/platform/contacts_service.dart';
import '../../services/platform/calendar_service.dart';
import '../../services/platform/notification_monitor.dart';
import '../../services/platform/local_notification_service.dart';
import '../../services/ai/briefing_engine.dart';
import '../../services/ai/stuckness_detector.dart';
import '../../services/ai/context_injector.dart';
import '../../services/agentic/mcp/mcp_config.dart';
import '../../services/agentic/mcp/mcp_manager.dart';
import '../../services/database/daos/metrics_dao.dart';
import '../../services/database/daos/streak_dao.dart';
import '../../services/database/daos/achievement_dao.dart';
import '../../services/success/momentum_calculator.dart';
import '../../services/success/celebration_service.dart';
import '../../services/demo/feature_discovery_service.dart';
import '../../services/demo/demo_mode_service.dart';
import '../../services/monitoring/ci_monitor_service.dart';

// --- Database ---

/// Database singleton -- disposed when ProviderScope is destroyed.
final soulDatabaseProvider = Provider<SoulDatabase>((ref) {
  final db = SoulDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// ConversationDao from database.
final conversationDaoProvider = Provider<ConversationDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.conversationDao;
});

/// DecisionDao from database.
final decisionDaoProvider = Provider<DecisionDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.decisionDao;
});

/// ProjectDao from database.
final projectDaoProvider = Provider<ProjectDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.projectDao;
});

/// ProjectStateDao from database.
final projectStateDaoProvider = Provider<ProjectStateDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.projectStateDao;
});

/// ProfileDao from database.
final profileDaoProvider = Provider<ProfileDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.profileDao;
});

// --- API Key ---

/// Service for reading/writing the Anthropic API key from Android Keystore.
final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  return ApiKeyService();
});

/// Holds the currently active Anthropic API key.
///
/// Initialized empty; set in main.dart after loading from secure storage.
/// Update via [apiKeyNotifierProvider.notifier.setKey] to hot-reload all
/// consumers (claudeServiceProvider, profileLearnerProvider).
class ApiKeyNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setKey(String key) => state = key;
}

final apiKeyNotifierProvider = NotifierProvider<ApiKeyNotifier, String>(
  ApiKeyNotifier.new,
);

/// Whether an API key is saved in secure storage.
final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(apiKeyServiceProvider);
  return service.hasAnthropicKey();
});

// --- AI Services ---

/// Cost tracker for API usage monitoring and budget warnings.
final costTrackerProvider = Provider<CostTracker>((ref) {
  return CostTracker(
    apiUsageDao: ref.watch(apiUsageDaoProvider),
    settingsDao: ref.watch(settingsDaoProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
  );
});

/// Claude service — rebuilds automatically when API key changes.
final claudeServiceProvider = Provider<ClaudeService>((ref) {
  final apiKey = ref.watch(apiKeyNotifierProvider);
  return ClaudeService(
    apiKey: apiKey,
    costTracker: ref.watch(costTrackerProvider),
  );
});

// --- ObjectBox ---

/// Notifier for ObjectBox Store -- starts as null, set by SoulInitWidget after async init.
/// Use [objectBoxStoreReadyProvider] in providers that require a non-null Store.
class ObjectBoxStoreNotifier extends Notifier<Store?> {
  @override
  Store? build() => null;

  void setStore(Store store) => state = store;
}

final objectBoxStoreProvider =
    NotifierProvider<ObjectBoxStoreNotifier, Store?>(
  ObjectBoxStoreNotifier.new,
);

/// Non-null store provider — only use after initialization is confirmed complete.
/// Throws if accessed before store is ready (guarded by SoulInitWidget).
final objectBoxStoreReadyProvider = Provider<Store>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  if (store == null) throw StateError('ObjectBox store not yet initialized');
  return store;
});

// --- Pigeon Bridge ---

/// Pigeon bridge handler singleton — handles Java→Dart terminal events.
///
/// Reading this provider triggers [PigeonBridgeHandler.init()] which registers
/// the handler with the SoulBridgeApi Pigeon channel. Must be read during app
/// startup (before the Flutter UI is fully loaded) to ensure Java-side events
/// are handled from the start.
final pigeonBridgeHandlerProvider = Provider<PigeonBridgeHandler>((ref) {
  final handler = PigeonBridgeHandler();
  handler.init();
  return handler;
});

// --- Memory Services ---

/// Embedding service for Voyage AI vectors.
/// Gracefully handles empty API key (embed returns null).
/// Voyage key is still supplied via --dart-define (not user-configurable).
final embeddingServiceProvider = Provider<EmbeddingService>((ref) {
  const apiKey = String.fromEnvironment('VOYAGE_API_KEY');
  return EmbeddingService(apiKey: apiKey);
});

/// ObjectBox vector store for semantic search.
final vectorStoreProvider = Provider<VectorStore>((ref) {
  final store = ref.watch(objectBoxStoreReadyProvider);
  return VectorStore(store: store);
});

/// Memory context retrieval orchestrator (FTS5 + vector + profile).
final memoryServiceProvider = Provider<MemoryService>((ref) {
  return MemoryService(
    decisionDao: ref.watch(decisionDaoProvider),
    projectDao: ref.watch(projectDaoProvider),
    profileDao: ref.watch(profileDaoProvider),
    embeddingService: ref.watch(embeddingServiceProvider),
    vectorStore: ref.watch(vectorStoreProvider),
  );
});

/// Decision detector for processing Claude tool_use responses.
final decisionDetectorProvider = Provider<DecisionDetector>((ref) {
  return DecisionDetector(
    decisionDao: ref.watch(decisionDaoProvider),
    embeddingService: ref.watch(embeddingServiceProvider),
    vectorStore: ref.watch(vectorStoreProvider),
  );
});

/// ScopeGuard for processing flag_scope_creep tool calls.
final scopeGuardProvider = Provider<ScopeGuard>((ref) {
  return ScopeGuard(decisionDao: ref.watch(decisionDaoProvider));
});

/// InterventionDao from database.
final interventionDaoProvider = Provider<InterventionDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.interventionDao;
});

/// DecisionTracker for processing track_open_question tool calls.
final decisionTrackerProvider = Provider<DecisionTracker>((ref) {
  return DecisionTracker(
      interventionDao: ref.watch(interventionDaoProvider));
});

/// MoodDao from database.
final moodDaoProvider = Provider<MoodDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.moodDao;
});

/// MoodAdapter for energy/emotion/intent analysis via Haiku sidecar.
final moodAdapterProvider = Provider<MoodAdapter>((ref) {
  return MoodAdapter(
    claudeService: ref.watch(claudeServiceProvider),
    moodDao: ref.watch(moodDaoProvider),
  );
});

// --- Profile Learning ---

/// Profile learner for extracting traits from conversations.
final profileLearnerProvider = Provider<ProfileLearner>((ref) {
  final apiKey = ref.watch(apiKeyNotifierProvider);
  final learner = ProfileLearner(
    conversationDao: ref.watch(conversationDaoProvider),
    profileDao: ref.watch(profileDaoProvider),
    apiKey: apiKey,
  );
  ref.onDispose(() => learner.close());
  return learner;
});

// --- Vessel Services ---

/// VesselDao from database.
final vesselDaoProvider = Provider<VesselDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.vesselDao;
});

/// AuditDao from database -- audit trail for all vessel actions.
final auditDaoProvider = Provider<AuditDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.auditDao;
});

/// Trust tier classifier -- determines approval flow per tool.
/// Depends on InterventionConfig (YAML) and AuditDao (track record).
final trustTierClassifierProvider = Provider<TrustTierClassifier>((ref) {
  final config = ref.watch(interventionConfigProvider).value ??
      InterventionConfig.defaults();
  final auditDao = ref.watch(auditDaoProvider);
  return TrustTierClassifier(config: config, auditDao: auditDao);
});

/// Vessel router for task classification.
final vesselRouterProvider = Provider<VesselRouter>((ref) {
  return VesselRouter();
});

/// Vessel manager -- orchestrates all vessel operations.
/// Wired with trust classifier and audit dao for tier-aware approval flow.
final vesselManagerProvider = Provider<VesselManager>((ref) {
  final manager = VesselManager(
    router: ref.watch(vesselRouterProvider),
    vesselDao: ref.watch(vesselDaoProvider),
  );
  manager.setTrustClassifier(ref.watch(trustTierClassifierProvider));
  manager.setAuditDao(ref.watch(auditDaoProvider));
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// OpenClaw service facade — available when OpenClaw is configured.
/// Returns null if no OpenClaw client is set on VesselManager.
final openClawServiceProvider = Provider<OpenClawService?>((ref) {
  final manager = ref.watch(vesselManagerProvider);
  final client = manager.openClawClient;
  if (client == null) return null;
  return OpenClawService.fromClient(client, client.config);
});

/// CI failure stream — emits when a GitHub Actions build fails (VES-13).
/// Subscribe in chat to show failure cards and push notifications.
final ciFailuresProvider = StreamProvider<CiFailure>((ref) {
  final service = ref.watch(openClawServiceProvider);
  if (service == null) return const Stream.empty();
  return service.ciMonitor.failures;
});

// --- Project State ---

/// Active project ID -- persisted in settings, drives project-scoped queries.
class ActiveProjectNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> initialize() async {
    final settingsDao = ref.read(settingsDaoProvider);
    state = await settingsDao.getString(SettingsKeys.activeProjectId);
  }

  Future<void> setActiveProject(String? projectId) async {
    final settingsDao = ref.read(settingsDaoProvider);
    if (projectId != null) {
      await settingsDao.setString(SettingsKeys.activeProjectId, projectId);
    }
    state = projectId;
  }
}

final activeProjectProvider =
    NotifierProvider<ActiveProjectNotifier, String?>(
  ActiveProjectNotifier.new,
);

/// List of active projects for the project switcher.
final activeProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final dao = ref.watch(projectDaoProvider);
  return dao.getActiveProjects();
});

/// Whether the user has an active project (for onboarding flow).
final hasProjectProvider = FutureProvider<bool>((ref) async {
  final dao = ref.watch(projectDaoProvider);
  final project = await dao.getActiveProject();
  return project != null;
});

// --- Connectivity ---

/// Connectivity stream from device.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Simple offline check -- true when no connectivity.
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.whenOrNull(
        data: (results) => results.contains(ConnectivityResult.none),
      ) ??
      false;
});

/// Offline message queue -- queues messages when offline, replays on reconnect.
final offlineMessageQueueProvider = Provider<OfflineMessageQueue>((ref) {
  final claudeService = ref.watch(claudeServiceProvider);
  final queue = OfflineMessageQueue(claudeService: claudeService);
  queue.startListening();
  ref.onDispose(() => queue.dispose());
  return queue;
});

// --- Platform Services (Phase 4) ---

/// ContactsDao from database.
final contactsDaoProvider = Provider<ContactsDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.contactsDao;
});

/// CalendarDao from database.
final calendarDaoProvider = Provider<CalendarDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.calendarDao;
});

/// NotificationDao from database.
final notificationDaoProvider = Provider<NotificationDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.notificationDao;
});

/// BriefingDao from database.
final briefingDaoProvider = Provider<BriefingDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.briefingDao;
});

/// SettingsDao from database.
final settingsDaoProvider = Provider<SettingsDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.settingsDao;
});

/// DemoModeService for pre-loaded demo interactions without API key.
final demoModeServiceProvider = Provider<DemoModeService>((ref) {
  return DemoModeService(settingsDao: ref.watch(settingsDaoProvider));
});

/// ApiUsageDao from database.
final apiUsageDaoProvider = Provider<ApiUsageDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.apiUsageDao;
});

/// Permission service for runtime permission management.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Foreground service manager for background processing.
/// Injects NotificationMonitor, VesselManager for kill switch, and data receiver.
final foregroundServiceManagerProvider = Provider<ForegroundServiceManager>((ref) {
  final manager = ForegroundServiceManager();
  manager.notificationMonitor = ref.watch(notificationMonitorProvider);
  manager.vesselManager = ref.watch(vesselManagerProvider);
  manager.registerDataReceiver();
  return manager;
});

/// Local notification service for push notifications.
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

/// Contacts service with local cache.
final contactsServiceProvider = Provider<ContactsService>((ref) {
  return ContactsService(contactsDao: ref.watch(contactsDaoProvider));
});

/// Calendar service with local cache.
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService(calendarDao: ref.watch(calendarDaoProvider));
});

/// Notification monitor for capturing notifications from other apps.
final notificationMonitorProvider = Provider<NotificationMonitor>((ref) {
  final monitor = NotificationMonitor(
    notificationDao: ref.watch(notificationDaoProvider),
  );
  ref.onDispose(() => monitor.dispose());
  return monitor;
});

// --- Intelligence Services (Phase 4) ---

/// Morning briefing engine.
final briefingEngineProvider = Provider<BriefingEngine>((ref) {
  final openClawService = ref.watch(openClawServiceProvider);
  return BriefingEngine(
    claudeService: ref.watch(claudeServiceProvider),
    briefingDao: ref.watch(briefingDaoProvider),
    calendarDao: ref.watch(calendarDaoProvider),
    decisionDao: ref.watch(decisionDaoProvider),
    notificationDao: ref.watch(notificationDaoProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
    settingsDao: ref.watch(settingsDaoProvider),
    projectDao: ref.watch(projectDaoProvider),
    projectStateDao: ref.watch(projectStateDaoProvider),
    ciMonitorService: openClawService?.ciMonitor,
  );
});

/// Stuckness detector for proactive nudges.
final stucknessDetectorProvider = Provider<StucknessDetector>((ref) {
  return StucknessDetector(
    conversationDao: ref.watch(conversationDaoProvider),
    decisionDao: ref.watch(decisionDaoProvider),
    briefingDao: ref.watch(briefingDaoProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
  );
});

/// Context injector for phone-native context in Claude prompts.
final contextInjectorProvider = Provider<ContextInjector>((ref) {
  return ContextInjector(
    calendarDao: ref.watch(calendarDaoProvider),
    notificationDao: ref.watch(notificationDaoProvider),
    contactsService: ref.watch(contactsServiceProvider),
    profileDao: ref.watch(profileDaoProvider),
  );
});

// --- Agentic Engine (Phase 5) ---

/// MCP config store for MCP server persistence.
final mcpConfigStoreProvider = Provider<McpConfigStore>((ref) {
  return McpConfigStore();
});

/// MCP manager for server lifecycle.
final mcpManagerProvider = Provider<McpManager>((ref) {
  final manager = McpManager(configStore: ref.watch(mcpConfigStoreProvider));
  ref.onDispose(() => manager.dispose());
  return manager;
});

// AgenticSession is a @riverpod generated provider (auto-registered).
// No manual provider needed — it's created by build_runner from
// lib/ui/agentic/agentic_session_provider.dart

// --- Phase 8: Memory Distillation & Success Tracking ---

/// MetricsDao from database.
final metricsDaoProvider = Provider<MetricsDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.metricsDao;
});

/// StreakDao from database.
final streakDaoProvider = Provider<StreakDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.streakDao;
});

/// AchievementDao from database.
final achievementDaoProvider = Provider<AchievementDao>((ref) {
  final db = ref.watch(soulDatabaseProvider);
  return db.achievementDao;
});

/// Momentum calculator for weekly engagement scoring.
final momentumCalculatorProvider = Provider<MomentumCalculator>((ref) {
  return MomentumCalculator(
    metricsDao: ref.watch(metricsDaoProvider),
    streakDao: ref.watch(streakDaoProvider),
  );
});

/// Celebration service for milestone display and prompt injection.
final celebrationServiceProvider = Provider<CelebrationService>((ref) {
  return CelebrationService(
    achievementDao: ref.watch(achievementDaoProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
  );
});

// --- Phase 10: Feature Discovery ---

/// Feature discovery service for progressive feature disclosure.
final featureDiscoveryServiceProvider =
    Provider<FeatureDiscoveryService>((ref) {
  return FeatureDiscoveryService(
    settingsDao: ref.watch(settingsDaoProvider),
  );
});

// --- Phase 10: CI Monitoring ---

/// CI monitor service for per-project GitHub Actions status tracking.
final ciMonitorServiceProvider = Provider<CiMonitorService>((ref) {
  final projectDao = ref.watch(projectDaoProvider);
  final openClawService = ref.watch(openClawServiceProvider);
  final notificationService = ref.watch(localNotificationServiceProvider);
  return CiMonitorService(
    projectDao: projectDao,
    openClawClient: openClawService?.client,
    notificationService: notificationService,
  );
});

// --- Phase 11: Vessel Onboarding ---

/// Global flag for pending vessel onboarding.
/// Set by VesselSettingsNotifier on first connection.
/// Consumed by ChatNotifier to inject SOUL's onboarding message.
class OnboardingPending {
  final bool isPending;
  final String? vesselId;
  final String? vesselName;

  const OnboardingPending({
    this.isPending = false,
    this.vesselId,
    this.vesselName,
  });
}

class OnboardingPendingNotifier extends Notifier<OnboardingPending> {
  @override
  OnboardingPending build() => const OnboardingPending();

  void set(OnboardingPending pending) => state = pending;

  void clear() => state = const OnboardingPending();
}

final onboardingPendingProvider =
    NotifierProvider<OnboardingPendingNotifier, OnboardingPending>(
  OnboardingPendingNotifier.new,
);
