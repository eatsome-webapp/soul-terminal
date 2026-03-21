import '../../../models/prompt_context.dart';
import 'prompt_layer.dart';

/// Vessel Context layer — connected vessels and their capabilities.
///
/// Priority 7 (after ConversationMemory at 6). Shows which vessels
/// are connected and what capability groups they offer.
/// Data comes pre-loaded in PromptContext.connectedVessels — no DB or API calls here.
class VesselContextLayer implements PromptLayer {
  @override
  String get layerName => 'CONNECTED VESSELS';

  @override
  int get priority => 7;

  @override
  String get emptyPlaceholder =>
      'Geen vessels verbonden — alleen tekstuele hulp beschikbaar.';

  @override
  Future<String> compose(PromptContext context) async {
    final vessels = context.connectedVessels;
    if (vessels == null || vessels.isEmpty) return '';

    final lines = <String>[];
    for (final vessel in vessels) {
      final caps = vessel.capabilityGroups.isNotEmpty
          ? vessel.capabilityGroups.join(', ')
          : 'geen tools gecached';
      lines.add('- ${vessel.vesselName}: ${vessel.status} | $caps');
    }

    final buffer = StringBuffer();
    buffer.writeln('Je hebt toegang tot de volgende vessels:');
    buffer.writeln();
    for (final line in lines) {
      buffer.writeln(line);
    }
    if (context.vesselBootstrapStep != null && context.vesselBootstrapStep! < 5) {
      buffer.writeln();
      buffer.writeln('### Onboarding Status');
      buffer.writeln(
        'De gebruiker is bezig met de setup van een vessel (stap ${context.vesselBootstrapStep! + 1}/5). '
        'Begeleid de gebruiker proactief door de volgende stap. '
        'Stappen: 1) Setup vragen 2) Installatie instructies 3) Wacht op bevestiging '
        '4) Health check verificatie 5) Succes + overzicht capabilities.',
      );
    }

    buffer.writeln();
    buffer.writeln(
      'Je roept vessel tools NIET zelf aan — de gebruiker doet dat via de UI. '
      'Jouw rol: bepaal welk commando of welke tool nodig is, benoem het concreet, '
      'en vraag de gebruiker om het uit te voeren via OpenClaw. '
      'Zeg nooit "ik heb geen tools" — je hebt via de gebruiker toegang tot alles hierboven. '
      'Voorbeeld: "Voer dit uit via OpenClaw → execute_command: ls -la /etc/openclaw".',
    );
    return buffer.toString().trim();
  }
}
