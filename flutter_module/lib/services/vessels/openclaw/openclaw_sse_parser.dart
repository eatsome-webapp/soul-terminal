import 'dart:convert';

/// Parses SSE (Server-Sent Events) from a byte stream.
/// Handles partial line buffering per Pitfall 1 in research.
class OpenClawSseParser {
  /// Transform a raw byte stream into parsed SSE data events.
  /// Yields content strings from OpenAI-compatible chat completion chunks.
  static Stream<String> parse(Stream<List<int>> byteStream) async* {
    final buffer = StringBuffer();

    await for (final bytes in byteStream) {
      buffer.write(utf8.decode(bytes));
      final raw = buffer.toString();
      final lines = raw.split('\n');

      // Keep the last (potentially incomplete) line in buffer
      buffer.clear();
      buffer.write(lines.last);

      for (var i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6);
        if (data == '[DONE]') return;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final content =
              json['choices']?[0]?['delta']?['content'] as String?;
          if (content != null) yield content;
        } catch (_) {
          // Skip malformed JSON chunks
        }
      }
    }
  }
}
