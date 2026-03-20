import '../../../models/prompt_context.dart';
import 'prompt_layer.dart';

/// Decision Log layer — recent and open decisions.
///
/// Priority 4. Injects past decisions for continuity and
/// pushes resolution of long-open questions.
class DecisionLogLayer implements PromptLayer {
  @override
  String get layerName => 'DECISION LOG';

  @override
  int get priority => 4;

  @override
  String get emptyPlaceholder => 'Geen relevante eerdere beslissingen.';

  @override
  Future<String> compose(PromptContext context) async {
    final sections = <String>[];

    // Recent decisions from memory
    final decisions = context.memory?.relevantDecisions;
    if (decisions != null && decisions.isNotEmpty) {
      sections.add(
        '### Recente Beslissingen\n'
        '$decisions\n\n'
        'Refereer natuurlijk naar eerdere beslissingen: '
        '"Vorige keer koos je X — geldt dat nog?"',
      );
    }

    // Open questions (from DecisionTracker, built in Plan 03)
    final questions = context.openQuestions;
    if (questions != null && questions.isNotEmpty) {
      final questionLines = questions.map((q) {
        final age = DateTime.now().difference(q.createdAt);
        final ageStr = age.inHours > 24
            ? '${age.inDays}d'
            : '${age.inHours}h';
        final proposal = q.proposedDefault != null
            ? '\n  Voorstel: ${q.proposedDefault}'
            : '';
        return '- $ageStr: ${q.question}$proposal';
      }).join('\n');

      sections.add(
        '### Open Beslissingen\n'
        '$questionLines\n\n'
        'ACTIE: Dring aan op een beslissing voor de langstlopende open vraag.',
      );
    }

    if (sections.isEmpty) return '';
    return sections.join('\n\n');
  }
}
