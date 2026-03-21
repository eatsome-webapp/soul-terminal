import 'dart:async';
import 'openclaw_client.dart';

/// Send and receive messages via OpenClaw channels (VES-14, VES-15).
/// Supports WhatsApp, Telegram, Slack, Discord, and 50+ more channels.
class OpenClawChannels {
  final OpenClawClient _client;

  const OpenClawChannels(this._client);

  /// Send a message to a channel (VES-14).
  /// Channel names: 'whatsapp', 'telegram', 'slack', 'discord', etc.
  Future<Map<String, dynamic>> sendMessage({
    required String channel,
    required String message,
    String? recipientId,
    Map<String, dynamic> extra = const {},
  }) {
    return _client.invokeTool(
      tool: channel,
      args: {
        'action': 'send',
        'message': message,
        if (recipientId != null) 'to': recipientId,
        ...extra,
      },
    );
  }

  /// Poll for incoming messages on a channel (VES-15).
  /// For v1, uses polling via sessions_status.
  /// Push notifications will come in Phase 4.
  Future<List<Map<String, dynamic>>> pollIncomingMessages({
    String? channel,
    String sessionKey = 'main',
    int limit = 20,
  }) async {
    final result = await _client.invokeTool(
      tool: 'sessions_status',
      args: {'key': sessionKey},
    );

    // Extract messages from session history
    final history = result['history'] as List<dynamic>? ?? [];
    return history
        .whereType<Map<String, dynamic>>()
        .where((msg) =>
            msg['role'] == 'user' &&
            (channel == null || msg['channel'] == channel))
        .take(limit)
        .toList();
  }

  /// List available channels on this OpenClaw instance.
  Future<List<String>> listChannels() async {
    // Use a tool list or health endpoint to discover channels.
    // For now, return common channel names.
    return const [
      'whatsapp',
      'telegram',
      'slack',
      'discord',
      'email',
      'sms',
    ];
  }
}
