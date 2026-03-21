import 'layers/prompt_layer.dart';
import 'layers/identity_layer.dart';
import 'layers/user_context_layer.dart';
import 'layers/project_state_layer.dart';
import 'layers/decision_log_layer.dart';
import 'layers/conversation_memory_layer.dart';
import 'layers/behavioral_rules_layer.dart';
import 'layers/vessel_context_layer.dart';
import '../demo/feature_discovery_service.dart';
import '../../models/prompt_context.dart';

/// Composes the unified SOUL system prompt from 7 composable layers.
///
/// Layer order optimized for prompt caching:
/// 1. Identity (static) — cache-stable prefix
/// 2. Behavioral Rules (static) — cache-stable pair with Identity
/// 3. User Context (dynamic) — founder profile, mood, phone
/// 4. Project State (dynamic) — active project, risks, deadlines
/// 5. Decision Log (dynamic) — recent and open decisions
/// 6. Conversation Memory (placeholder) — session summaries (Phase 8)
/// 7. Vessel Context (dynamic) — connected vessels and capabilities
class PromptComposer {
  final List<PromptLayer> _layers;

  PromptComposer({
    List<PromptLayer>? layers,
    FeatureDiscoveryService? featureDiscoveryService,
  }) : _layers = layers ??
            [
              IdentityLayer(),
              BehavioralRulesLayer(
                featureDiscoveryService: featureDiscoveryService,
              ),
              UserContextLayer(),
              ProjectStateLayer(),
              DecisionLogLayer(),
              ConversationMemoryLayer(),
              VesselContextLayer(),
            ];

  /// Composes the full system prompt from all layers.
  ///
  /// Each layer produces a `## LAYER_NAME` section. Empty layers
  /// render their placeholder text (or are omitted if placeholder is empty).
  Future<String> compose(PromptContext context) async {
    final sections = <String>[];

    for (final layer in _layers) {
      final content = await layer.compose(context);
      if (content.isEmpty) {
        final placeholder = layer.emptyPlaceholder;
        if (placeholder.isNotEmpty) {
          sections.add('## ${layer.layerName}\n$placeholder');
        }
      } else {
        sections.add('## ${layer.layerName}\n$content');
      }
    }

    return sections.join('\n\n');
  }
}
