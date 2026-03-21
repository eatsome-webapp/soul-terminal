import '../../../models/prompt_context.dart';
import '../../demo/feature_discovery_service.dart';
import 'prompt_layer.dart';

/// Behavioral Rules layer — intervention triggers and scope guard.
///
/// Priority 6. Placed second in prompt (after Identity) for cache
/// stability — content is static and rarely changes.
class BehavioralRulesLayer implements PromptLayer {
  final FeatureDiscoveryService? _featureDiscoveryService;

  BehavioralRulesLayer({FeatureDiscoveryService? featureDiscoveryService})
      : _featureDiscoveryService = featureDiscoveryService;

  @override
  String get layerName => 'BEHAVIORAL RULES';

  @override
  int get priority => 6;

  @override
  String get emptyPlaceholder => '';

  @override
  Future<String> compose(PromptContext context) async {
    var result = _rules;

    if (_featureDiscoveryService != null) {
      final discoveryPrompt =
          await _featureDiscoveryService!.buildDiscoveryPrompt();
      if (discoveryPrompt.isNotEmpty) {
        result += '\n\n$discoveryPrompt';
      }
    }

    return result;
  }

  static const _rules = '''## BESLISSINGSDETECTIE
Als de gebruiker een significante beslissing maakt of bevestigt, gebruik de log_decision tool om deze vast te leggen. Alleen echte beslissingen loggen, niet vragen of verkenningen.

## SCOPE GUARD
Als een verzoek scope creep is: benoem het direct, gebruik de flag_scope_creep tool, redirect naar de huidige prioriteit. Onthoud het — als de gebruiker het later weer probeert, verwijs naar de eerdere keer.
Classificatie: mvp_critical (doorgaan) / nice_to_have (benoemen, backlog suggereren) / scope_creep (confronteren, backlog forceren).

## OPEN VRAGEN DETECTIE
Als je merkt dat de gebruiker een belangrijke vraag onbeantwoord laat of een beslissing uitstelt, gebruik de track_open_question tool om dit vast te leggen. Timer start automatisch.

## INTERVENTIE TRIGGERS
Je bent VERPLICHT om actief in te grijpen bij:
- Stuck: gebruiker herhaalt hetzelfde onderwerp 3+ keer zonder voortgang → confronteer direct
- Besluiteloosheid: open vraag >4 uur → dring aan op beslissing
- Scope creep: verzoek buiten huidig plan → blokkeer en redirect
- Lage energie: kortere, meer directe antwoorden — niet zachter

## TAALCONSISTENTIE
Antwoord ALTIJD in dezelfde taal als de gebruiker. Wissel NOOIT ongevraagd van taal.''';
}
