import 'package:logger/logger.dart';

import '../models/vessel_connection.dart';
import 'openclaw_client.dart';
import 'openclaw_config.dart';
import 'openclaw_tools.dart';
import 'openclaw_cron.dart';
import 'openclaw_webhooks.dart';
import 'openclaw_agents.dart';
import 'openclaw_channels.dart';
import 'openclaw_ci_monitor.dart';

/// Unified facade for all OpenClaw Gateway interactions.
/// Composes HTTP client, tool invocation, cron, webhooks, agents, and channels.
class OpenClawService {
  final OpenClawClient client;
  final OpenClawTools tools;
  final OpenClawCron cron;
  final OpenClawWebhooks webhooks;
  final OpenClawAgents agents;
  final OpenClawChannels channels;
  final OpenClawCiMonitor ciMonitor;
  final Logger _log = Logger();

  OpenClawService({required OpenClawConfig config})
      : client = OpenClawClient(config: config),
        tools = OpenClawTools(OpenClawClient(config: config)),
        cron = OpenClawCron(OpenClawClient(config: config)),
        webhooks = OpenClawWebhooks(config: config),
        agents = OpenClawAgents(OpenClawClient(config: config)),
        channels = OpenClawChannels(OpenClawClient(config: config)),
        ciMonitor = OpenClawCiMonitor(
          cron: OpenClawCron(OpenClawClient(config: config)),
          tools: OpenClawTools(OpenClawClient(config: config)),
        );

  /// Factory from a single client instance (shares HTTP connection).
  factory OpenClawService.fromClient(OpenClawClient client, OpenClawConfig config) {
    final tools = OpenClawTools(client);
    final cron = OpenClawCron(client);
    return OpenClawService._shared(
      client: client,
      tools: tools,
      cron: cron,
      webhooks: OpenClawWebhooks(config: config),
      agents: OpenClawAgents(client),
      channels: OpenClawChannels(client),
      ciMonitor: OpenClawCiMonitor(cron: cron, tools: tools),
    );
  }

  OpenClawService._shared({
    required this.client,
    required this.tools,
    required this.cron,
    required this.webhooks,
    required this.agents,
    required this.channels,
    required this.ciMonitor,
  });

  /// Send a message via a channel (MSG-01).
  /// Returns via VesselManager task flow for approval.
  Future<Map<String, dynamic>> sendMessage({
    required String channel,
    required String message,
    String? recipientId,
  }) {
    return channels.sendMessage(
      channel: channel,
      message: message,
      recipientId: recipientId,
    );
  }

  /// Poll for incoming messages (MSG-02).
  Future<List<Map<String, dynamic>>> pollIncomingMessages({
    String? channel,
  }) {
    return channels.pollIncomingMessages(channel: channel);
  }

  /// Connect and validate health (VES-01).
  Future<bool> connectAndValidate() async {
    final connection = await client.connect();
    return connection.status == ConnectionStatus.connected;
  }

  /// Stream chat completions from OpenClaw agent (VES-03).
  Stream<String> streamCompletion({
    required List<Map<String, String>> messages,
    String? agentId,
    String? sessionKey,
  }) {
    return client.streamCompletion(
      messages: messages,
      agentId: agentId,
      sessionKey: sessionKey,
    );
  }

  /// List all active OpenClaw sessions (VES-04).
  Future<List<Map<String, dynamic>>> listSessions() {
    return client.listSessions();
  }

  /// Reset an OpenClaw session (VES-04).
  Future<void> resetSession(String sessionKey) {
    return client.resetSession(sessionKey);
  }

  /// Compact an OpenClaw session (VES-04).
  Future<void> compactSession(String sessionKey) {
    return client.compactSession(sessionKey);
  }

  void dispose() {
    ciMonitor.dispose();
    client.dispose();
  }
}
