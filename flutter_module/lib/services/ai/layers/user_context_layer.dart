import '../../../models/prompt_context.dart';
import 'prompt_layer.dart';

/// User Context layer — founder profile, mood/energy, phone context.
///
/// Priority 2 — placed after Identity for cache stability.
/// Adapts response style based on detected energy and intent.
class UserContextLayer implements PromptLayer {
  @override
  String get layerName => 'USER CONTEXT';

  @override
  int get priority => 2;

  @override
  String get emptyPlaceholder =>
      'Geen aanvullende gebruikerscontext beschikbaar.';

  @override
  Future<String> compose(PromptContext context) async {
    final sections = <String>[];

    // 1. Founder profile
    final profileTraits = context.memory?.profileTraits;
    if (profileTraits != null && profileTraits.isNotEmpty) {
      sections.add('### Founder Profiel\n$profileTraits');
    }

    // 2. Mood/energy state (null until MoodAdapter is built in Plan 03)
    final mood = context.moodState;
    if (mood != null) {
      sections.add(
        '### Huidige Staat\n'
        'Energie: ${mood.energy} | Emotie: ${mood.emotion} | Intent: ${mood.intent}',
      );

      if (mood.energy <= 2) {
        sections.add(
          'AANPASSING: Lage energie gedetecteerd. Kort en actiegericht. '
          'Geen analyse. Geef stappen. "Doe dit. Dan dat. Klaar."',
        );
      }

      if (mood.intent == 'vent') {
        sections.add(
          'AANPASSING: Venting gedetecteerd. Max 1 zin erkenning '
          '("Klote dag. Snap ik.") dan redirect naar concrete actie.',
        );
      }
    }

    // 3. Phone context
    final phone = context.phoneContext;
    if (phone != null && phone.isNotEmpty) {
      sections.add('### Telefoon Context\n$phone');
    }

    if (sections.isEmpty) return '';
    return sections.join('\n\n');
  }
}
