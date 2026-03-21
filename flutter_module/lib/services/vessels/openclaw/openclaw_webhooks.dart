import 'dart:convert';
import 'package:http/http.dart' as http;

import 'openclaw_config.dart';

/// Triggers OpenClaw webhooks for event-driven automation (VES-06).
/// Uses direct POST to /hooks/* endpoints, NOT /tools/invoke.
/// Note: webhook auth token may differ from gateway token (Pitfall 7).
class OpenClawWebhooks {
  final OpenClawConfig _config;
  final http.Client _httpClient;
  final String? _webhookToken;

  OpenClawWebhooks({
    required OpenClawConfig config,
    http.Client? httpClient,
    String? webhookToken,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client(),
        _webhookToken = webhookToken;

  /// Trigger the /hooks/wake endpoint (system wake).
  Future<Map<String, dynamic>> triggerWake({
    String? message,
  }) {
    return _triggerHook('wake', body: {
      if (message != null) 'message': message,
    });
  }

  /// Trigger the /hooks/agent endpoint (isolated agent run).
  Future<Map<String, dynamic>> triggerAgent({
    required String prompt,
    String? agentId,
    int timeoutSeconds = 300,
  }) {
    return _triggerHook('agent', body: {
      'prompt': prompt,
      if (agentId != null) 'agentId': agentId,
      'timeoutSeconds': timeoutSeconds,
    });
  }

  /// Trigger a custom named webhook.
  Future<Map<String, dynamic>> triggerCustom({
    required String hookName,
    Map<String, dynamic> body = const {},
  }) {
    return _triggerHook(hookName, body: body);
  }

  Future<Map<String, dynamic>> _triggerHook(
    String hookName, {
    Map<String, dynamic> body = const {},
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Use webhook token if available, otherwise gateway token
    // Pitfall 7: webhook auth token may differ from gateway token
    final token = _webhookToken ?? _config.token;
    headers['x-openclaw-token'] = token;

    final response = await _httpClient.post(
      _config.hooksUrl(hookName),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('Webhook $hookName failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
