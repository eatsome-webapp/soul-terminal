import '../../../models/prompt_context.dart';
import 'prompt_layer.dart';

/// Project State layer — active project, risks, deadlines.
///
/// Priority 3. Shows current project context and risk awareness.
class ProjectStateLayer implements PromptLayer {
  @override
  String get layerName => 'PROJECT STATE';

  @override
  int get priority => 3;

  @override
  String get emptyPlaceholder => 'Geen actief project geladen.';

  @override
  Future<String> compose(PromptContext context) async {
    final sections = <String>[];

    // Active project from memory context
    final projectContext = context.memory?.projectContext;
    if (projectContext != null && projectContext.isNotEmpty) {
      sections.add('### Actief Project\n$projectContext');
    }

    // Project state with risks and deadlines (future — currently null)
    final state = context.projectState;
    if (state != null) {
      final risksStr =
          state.risks.isNotEmpty ? state.risks.join(', ') : 'geen';
      final assumptionsStr = state.assumptions.isNotEmpty
          ? state.assumptions.join(', ')
          : 'geen';

      sections.add(
        '### Risico\'s & Deadlines\n'
        'Fase: ${state.phase ?? 'onbekend'} | '
        'Deadline: ${state.deadline ?? 'niet gezet'} | '
        'Risico\'s: $risksStr\n'
        'Ongevalideerde aannames: $assumptionsStr',
      );
    }

    // AI-extracted project state from ProjectStateExtractor
    if (context.extractedProjectStatus != null && context.extractedProjectStatus!.isNotEmpty) {
      final extractedBuffer = StringBuffer();
      extractedBuffer.writeln('### AI-Extracted State');
      extractedBuffer.writeln('Status: ${context.extractedProjectStatus}');
      if (context.extractedRiskiestItem != null) {
        extractedBuffer.writeln('Riskiest untested item: ${context.extractedRiskiestItem}');
      }
      if (context.extractedAssumptions != null) {
        extractedBuffer.writeln('Unvalidated assumptions: ${context.extractedAssumptions}');
      }
      sections.add(extractedBuffer.toString().trim());
    }

    // Founder momentum score from MomentumCalculator
    if (context.momentumScore != null) {
      final label = context.momentumScore! >= 75
          ? 'High'
          : context.momentumScore! >= 40
              ? 'Medium'
              : 'Low';
      final momentumBuffer = StringBuffer();
      momentumBuffer.writeln('### Founder Momentum');
      momentumBuffer.writeln('Score: ${context.momentumScore!.toInt()}/100 ($label)');
      if (context.momentumScore! < 40) {
        momentumBuffer.writeln('Momentum is low. Push harder. Be more direct.');
      } else if (context.momentumScore! >= 75) {
        momentumBuffer.writeln('Momentum is high. Encourage and accelerate.');
      }
      sections.add(momentumBuffer.toString().trim());
    }

    if (sections.isEmpty) return '';
    return sections.join('\n\n');
  }
}
