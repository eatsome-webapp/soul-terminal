import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../services/vessels/models/vessel_connection.dart';
import '../../services/vessels/models/vessel_task.dart';
import '../../services/vessels/vessel_interface.dart';
import '../../services/vessels/openclaw/openclaw_client.dart';
import '../../services/vessels/openclaw/openclaw_config.dart';
import '../../services/vessels/agent_sdk/agent_sdk_client.dart';
import '../../services/vessels/agent_sdk/agent_sdk_config.dart';
import '../../services/auth/api_key_service.dart';
import '../../core/di/providers.dart';
import '../../services/database/daos/settings_dao.dart';
import '../../services/vessels/capability_grouper.dart';

const _unchanged = Object();

/// State for vessel settings screen.
class VesselSettingsState {
  final bool hasApiKey;
  final String openClawHost;
  final int openClawPort;
  final bool openClawUseTls;
  final ConnectionStatus openClawStatus;
  final String agentSdkUrl;
  final ConnectionStatus agentSdkStatus;
  final bool isTesting;
  final bool firstConnectionDetected;
  final String? onboardingVesselId;
  final String openClawUrlPrefix;
  final String? openClawError;
  final int openClawToolCount;

  const VesselSettingsState({
    this.hasApiKey = false,
    this.openClawHost = '',
    this.openClawPort = 443,
    this.openClawUseTls = true,
    this.openClawStatus = ConnectionStatus.disconnected,
    this.agentSdkUrl = '',
    this.agentSdkStatus = ConnectionStatus.disconnected,
    this.isTesting = false,
    this.firstConnectionDetected = false,
    this.onboardingVesselId,
    this.openClawUrlPrefix = '',
    this.openClawError,
    this.openClawToolCount = 0,
  });

  VesselSettingsState copyWith({
    bool? hasApiKey,
    String? openClawHost,
    int? openClawPort,
    bool? openClawUseTls,
    ConnectionStatus? openClawStatus,
    String? agentSdkUrl,
    ConnectionStatus? agentSdkStatus,
    bool? isTesting,
    bool? firstConnectionDetected,
    String? onboardingVesselId,
    String? openClawUrlPrefix,
    Object? openClawError = _unchanged,
    int? openClawToolCount,
  }) {
    return VesselSettingsState(
      hasApiKey: hasApiKey ?? this.hasApiKey,
      openClawHost: openClawHost ?? this.openClawHost,
      openClawPort: openClawPort ?? this.openClawPort,
      openClawUseTls: openClawUseTls ?? this.openClawUseTls,
      openClawStatus: openClawStatus ?? this.openClawStatus,
      agentSdkUrl: agentSdkUrl ?? this.agentSdkUrl,
      agentSdkStatus: agentSdkStatus ?? this.agentSdkStatus,
      isTesting: isTesting ?? this.isTesting,
      firstConnectionDetected: firstConnectionDetected ?? this.firstConnectionDetected,
      onboardingVesselId: onboardingVesselId ?? this.onboardingVesselId,
      openClawUrlPrefix: openClawUrlPrefix ?? this.openClawUrlPrefix,
      openClawError: identical(openClawError, _unchanged) ? this.openClawError : openClawError as String?,
      openClawToolCount: openClawToolCount ?? this.openClawToolCount,
    );
  }
}

class VesselSettingsNotifier extends Notifier<VesselSettingsState> {
  final Logger _log = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiKeyService _apiKeyService = ApiKeyService();

  static const _openClawTokenKey = 'vessel_openclaw_token';
  static const _agentSdkTokenKey = 'vessel_agentsdk_token';

  @override
  VesselSettingsState build() {
    _loadSavedConfigs();
    return const VesselSettingsState();
  }

  Future<void> _loadSavedConfigs() async {
    final hasKey = await _apiKeyService.hasAnthropicKey();
    state = state.copyWith(hasApiKey: hasKey);

    final vesselDao = ref.read(vesselDaoProvider);
    final configs = await vesselDao.getAllConfigs();

    for (final config in configs) {
      final vesselType = config.vesselType;
      if (vesselType == 'openClaw') {
        state = state.copyWith(
          openClawHost: config.host,
          openClawPort: config.port,
          openClawUseTls: config.port == 443,
        );
        final settingsDao = ref.read(settingsDaoProvider);
        final savedPrefix = await settingsDao.getString(SettingsKeys.openClawUrlPrefix);
        if (savedPrefix != null) {
          state = state.copyWith(openClawUrlPrefix: savedPrefix);
        }
      } else if (vesselType == 'agentSdk') {
        state = state.copyWith(
          agentSdkUrl: config.host,
        );
      }
    }
  }

  Future<void> saveApiKey(String key) async {
    await _apiKeyService.saveAnthropicKey(key);
    ref.read(apiKeyNotifierProvider.notifier).setKey(key);
    state = state.copyWith(hasApiKey: true);
    _log.i('Anthropic API key updated');
  }

  Future<void> deleteApiKey() async {
    await _apiKeyService.deleteAnthropicKey();
    ref.read(apiKeyNotifierProvider.notifier).setKey('');
    state = state.copyWith(hasApiKey: false);
    _log.i('Anthropic API key removed');
  }

  Future<void> saveOpenClawConfig(
    String host,
    int port,
    String token, {
    bool useTls = true,
    String urlPrefix = '',
  }) async {
    await _secureStorage.write(key: _openClawTokenKey, value: token);
    state = state.copyWith(isTesting: true);

    final client = OpenClawClient(
      config: OpenClawConfig(host: host, port: port, token: token, useTls: useTls, urlPrefix: urlPrefix),
    );

    final manager = ref.read(vesselManagerProvider);
    manager.setOpenClawClient(client);

    // Validate connection before marking as connected (matches BYOK pattern)
    final healthError = await client.checkHealth();
    final isHealthy = healthError == null;

    final vesselDao = ref.read(vesselDaoProvider);
    await vesselDao.upsertConfig(
      id: 'openclaw-default',
      vesselType: 'openClaw',
      host: host,
      port: port,
      tokenRef: _openClawTokenKey,
      isActive: true,
    );

    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setString(SettingsKeys.openClawUrlPrefix, urlPrefix);

    state = state.copyWith(
      openClawHost: host,
      openClawPort: port,
      openClawUseTls: useTls,
      openClawUrlPrefix: urlPrefix,
      openClawError: healthError,
      openClawStatus: isHealthy
          ? ConnectionStatus.connected
          : ConnectionStatus.error,
      isTesting: false,
    );

    if (isHealthy) {
      // Fetch and cache tools
      try {
        final tools = await client.fetchTools();
        final vesselId = 'openclaw';
        // Clear old cache
        await vesselDao.deleteToolsByVesselId(vesselId);
        // Cache each tool with capability group
        for (final tool in tools) {
          final toolName = tool['name'] as String? ?? '';
          if (toolName.isEmpty) continue;
          await vesselDao.insertVesselTool(
            vesselId: vesselId,
            toolName: toolName,
            description: tool['description'] as String?,
            capabilityGroup: CapabilityGrouper.classify(toolName),
          );
        }
        _log.i('Cached ${tools.length} tools for OpenClaw');
        state = state.copyWith(openClawToolCount: tools.length);
      } catch (e) {
        _log.w('Failed to fetch/cache tools: $e');
      }

      // Detect first connection
      final settingsDao = ref.read(settingsDaoProvider);
      final firstConnKey = SettingsKeys.vesselFirstConnected('openclaw');
      final previousConnection = await settingsDao.getString(firstConnKey);
      if (previousConnection == null) {
        await settingsDao.setString(firstConnKey, DateTime.now().toIso8601String());
        // Initialize bootstrap step to 0 so vesselBootstrapStep tracking starts
        await settingsDao.setString(
          SettingsKeys.vesselBootstrapStep('openclaw'),
          '0',
        );
        state = state.copyWith(
          firstConnectionDetected: true,
          onboardingVesselId: 'openclaw',
        );
        // Signal to ChatNotifier via global provider
        ref.read(onboardingPendingProvider.notifier).set(OnboardingPending(
          isPending: true,
          vesselId: 'openclaw',
          vesselName: 'OpenClaw',
        ));
        _log.i('First OpenClaw connection detected — triggering onboarding');
      }
    }

    _log.i('OpenClaw configured: $host:$port');
  }

  Future<void> saveAgentSdkConfig(
    String relayUrl,
    String token,
  ) async {
    await _secureStorage.write(key: _agentSdkTokenKey, value: token);

    final client = AgentSdkClient(
      config: AgentSdkConfig(relayUrl: relayUrl, token: token),
    );

    final manager = ref.read(vesselManagerProvider);
    manager.setAgentSdkClient(client);

    // Validate connection before marking as connected (matches BYOK pattern)
    final healthError = await client.checkHealth();
    final isHealthy = healthError == null;

    final vesselDao = ref.read(vesselDaoProvider);
    await vesselDao.upsertConfig(
      id: 'agentsdk-default',
      vesselType: 'agentSdk',
      host: relayUrl,
      port: 0,
      tokenRef: _agentSdkTokenKey,
      isActive: true,
    );

    state = state.copyWith(
      agentSdkUrl: relayUrl,
      agentSdkStatus: isHealthy
          ? ConnectionStatus.connected
          : ConnectionStatus.error,
    );

    _log.i('Agent SDK configured: $relayUrl');
  }

  Future<String?> testConnection(VesselType type) async {
    state = state.copyWith(isTesting: true);

    try {
      final manager = ref.read(vesselManagerProvider);
      VesselInterface? client;
      if (type == VesselType.openClaw) {
        client = manager.openClawClient;
      } else {
        client = manager.agentSdkClient;
      }
      if (client == null) {
        state = state.copyWith(isTesting: false);
        return 'Geen client geconfigureerd';
      }
      final healthError = await client.checkHealth();
      final isHealthy = healthError == null;

      if (type == VesselType.openClaw) {
        state = state.copyWith(
          openClawStatus: isHealthy
              ? ConnectionStatus.connected
              : ConnectionStatus.error,
          isTesting: false,
        );
      } else {
        state = state.copyWith(
          agentSdkStatus: isHealthy
              ? ConnectionStatus.connected
              : ConnectionStatus.error,
          isTesting: false,
        );
      }

      return healthError;
    } catch (error) {
      _log.e('Connection test failed', error: error);
      state = state.copyWith(isTesting: false);
      return error.toString();
    }
  }

  Future<void> disconnect(VesselType type) async {
    if (type == VesselType.openClaw) {
      await _secureStorage.delete(key: _openClawTokenKey);
      state = state.copyWith(
        openClawHost: '',
        openClawPort: 18789,
        openClawStatus: ConnectionStatus.disconnected,
      );
    } else {
      await _secureStorage.delete(key: _agentSdkTokenKey);
      state = state.copyWith(
        agentSdkUrl: '',
        agentSdkStatus: ConnectionStatus.disconnected,
      );
    }

    _log.i('Vessel disconnected: ${type.name}');
  }
}

final vesselSettingsNotifierProvider =
    NotifierProvider<VesselSettingsNotifier, VesselSettingsState>(
  VesselSettingsNotifier.new,
);
