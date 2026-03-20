import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Manages the Anthropic API key in Android Keystore via flutter_secure_storage.
/// Provides format validation and zero-cost API validation via count_tokens.
class ApiKeyService {
  static const _anthropicKeyStorageKey = 'anthropic_api_key';
  static const _relayUrlStorageKey = 'agent_sdk_relay_url';
  static const _relayTokenStorageKey = 'agent_sdk_relay_token';
  static const _openClawHostKey = 'openclaw_host';
  static const _openClawTokenKey = 'openclaw_token';
  static const _openClawUseTlsKey = 'openclaw_use_tls';

  final FlutterSecureStorage _storage;
  final Logger _logger = Logger();

  ApiKeyService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getAnthropicKey() =>
      _storage.read(key: _anthropicKeyStorageKey);

  Future<void> saveAnthropicKey(String key) =>
      _storage.write(key: _anthropicKeyStorageKey, value: key);

  Future<void> deleteAnthropicKey() =>
      _storage.delete(key: _anthropicKeyStorageKey);

  Future<bool> hasAnthropicKey() async {
    final key = await getAnthropicKey();
    return key != null && key.isNotEmpty;
  }

  // --- Relay credentials (Agent SDK) ---

  Future<String?> getRelayUrl() => _storage.read(key: _relayUrlStorageKey);

  Future<void> saveRelayUrl(String url) =>
      _storage.write(key: _relayUrlStorageKey, value: url);

  Future<String?> getRelayToken() => _storage.read(key: _relayTokenStorageKey);

  Future<void> saveRelayToken(String token) =>
      _storage.write(key: _relayTokenStorageKey, value: token);

  Future<void> deleteRelayCredentials() async {
    await _storage.delete(key: _relayUrlStorageKey);
    await _storage.delete(key: _relayTokenStorageKey);
  }

  Future<bool> hasRelayCredentials() async {
    final url = await getRelayUrl();
    final token = await getRelayToken();
    return url != null && url.isNotEmpty && token != null && token.isNotEmpty;
  }

  // --- OpenClaw credentials ---

  Future<String?> getOpenClawHost() => _storage.read(key: _openClawHostKey);
  Future<void> saveOpenClawHost(String host) =>
      _storage.write(key: _openClawHostKey, value: host);

  Future<String?> getOpenClawToken() => _storage.read(key: _openClawTokenKey);
  Future<void> saveOpenClawToken(String token) =>
      _storage.write(key: _openClawTokenKey, value: token);

  Future<bool> getOpenClawUseTls() async {
    final value = await _storage.read(key: _openClawUseTlsKey);
    return value == 'true';
  }

  Future<void> saveOpenClawUseTls(bool useTls) =>
      _storage.write(key: _openClawUseTlsKey, value: useTls.toString());

  Future<void> deleteOpenClawCredentials() async {
    await _storage.delete(key: _openClawHostKey);
    await _storage.delete(key: _openClawTokenKey);
    await _storage.delete(key: _openClawUseTlsKey);
  }

  Future<bool> hasOpenClawCredentials() async {
    final host = await getOpenClawHost();
    final token = await getOpenClawToken();
    return host != null && host.isNotEmpty && token != null && token.isNotEmpty;
  }

  /// Validate API key format (client-side, no network).
  /// Returns null if valid, error message if invalid.
  String? validateFormat(String key) {
    if (key.isEmpty) return 'API key mag niet leeg zijn';
    if (key.length < 40) return 'API key is te kort';
    if (!key.startsWith('sk-ant-api03-')) {
      return 'Ongeldige key format — verwacht sk-ant-api03-...';
    }
    return null; // Valid format
  }

  /// Validate API key format and verify with Anthropic API.
  /// Uses count_tokens endpoint (zero cost).
  /// Returns null if valid, error message if invalid.
  Future<String?> validateKey(String key) async {
    // Format check first
    final formatError = validateFormat(key);
    if (formatError != null) return formatError;

    // API validation via count_tokens (free endpoint)
    AnthropicClient? client;
    try {
      client = AnthropicClient(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider(key),
        ),
      );

      await client.messages.countTokens(
        TokenCountRequest(
          model: 'claude-sonnet-4-20250514',
          messages: [InputMessage.user('test')],
        ),
      );

      _logger.i('API key validation successful');
      return null; // Valid
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        return 'Ongeldige API key — controleer of je de juiste key hebt gekopieerd';
      } else if (e.statusCode == 429) {
        return 'Rate limited — probeer het over een paar minuten opnieuw';
      }
      return 'Validatie mislukt: ${e.message}';
    } catch (e) {
      _logger.e('Key validation error: $e');
      return 'Kan niet verbinden — controleer je internetverbinding';
    } finally {
      client?.close();
    }
  }

  /// Validate and save key. Returns error message or null on success.
  Future<String?> validateAndSaveKey(String key) async {
    final error = await validateKey(key);
    if (error != null) return error;
    await saveAnthropicKey(key);
    return null;
  }
}
