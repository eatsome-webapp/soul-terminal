import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/logger.dart';

/// HTTP client for Voyage AI embeddings API.
/// Uses voyage-3-lite model (512 dimensions, $0.02/M tokens).
class EmbeddingService {
  static const _endpoint = 'https://api.voyageai.com/v1/embeddings';
  static const _model = 'voyage-3-lite';
  static const dimensions = 512;

  final String _apiKey;
  final http.Client _httpClient;

  EmbeddingService({
    required String apiKey,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client();

  /// Generates a 512-dimensional embedding for the given text.
  /// Returns null if the API call fails (non-blocking degradation).
  Future<List<double>?> embed(String text) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': [text],
          'model': _model,
          'input_type': 'document',
        }),
      );

      if (response.statusCode != 200) {
        log.w('Voyage AI error ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final embeddings = data['data'] as List<dynamic>;
      if (embeddings.isEmpty) return null;

      final vector = (embeddings[0]['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();

      if (vector.length != dimensions) {
        log.w(
            'Unexpected embedding dimensions: ${vector.length} (expected $dimensions)');
        return null;
      }

      return vector;
    } catch (e) {
      log.e('Embedding failed: $e');
      return null;
    }
  }

  /// Generates an embedding for a search query (uses 'query' input_type for better retrieval).
  Future<List<double>?> embedQuery(String query) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': [query],
          'model': _model,
          'input_type': 'query',
        }),
      );

      if (response.statusCode != 200) {
        log.w('Voyage AI query embed error ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final embeddings = data['data'] as List<dynamic>;
      if (embeddings.isEmpty) return null;

      return (embeddings[0]['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
    } catch (e) {
      log.e('Query embedding failed: $e');
      return null;
    }
  }

  void close() {
    _httpClient.close();
  }
}
