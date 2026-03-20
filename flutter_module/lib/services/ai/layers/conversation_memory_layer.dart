import '../../../models/prompt_context.dart';
import 'prompt_layer.dart';

/// Conversation Memory layer — session summaries and patterns.
///
/// Priority 5. Placeholder for Phase 8 session summary feature.
/// Maintains the 6-layer structure for future expansion.
class ConversationMemoryLayer implements PromptLayer {
  @override
  String get layerName => 'CONVERSATION MEMORY';

  @override
  int get priority => 5;

  @override
  String get emptyPlaceholder =>
      'Eerste gesprek — nog geen gespreksgeschiedenis.';

  @override
  Future<String> compose(PromptContext context) async {
    final buffer = StringBuffer();

    // Include distilled facts when available
    if (context.distilledFacts.isNotEmpty) {
      buffer.writeln('### Distilled Knowledge');
      buffer.writeln(context.distilledFacts);
    }

    return buffer.toString().trim();
  }
}
