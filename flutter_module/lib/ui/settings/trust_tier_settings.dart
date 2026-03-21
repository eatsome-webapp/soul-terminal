import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../services/ai/trust_tier_classifier.dart';

/// Settings section showing tool-to-tier assignments.
///
/// Three expandable sections (autonomous, soft, hard) with tools
/// listed in monospace font. Each tool has a popup menu to move
/// between tiers.
class TrustTierSettings extends ConsumerWidget {
  const TrustTierSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classifier = ref.watch(trustTierClassifierProvider);
    final classifications = classifier.getAllClassifications();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Vertrouwensniveaus', style: textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'SOUL vraagt toestemming op basis van het actietype. Hogere niveaus vereisen bevestiging.',
            style: textTheme.bodyMedium,
          ),
        ),
        _buildTierSection(
          context: context,
          ref: ref,
          title: 'Autonoom \u2014 geen toestemming',
          tier: TrustTier.autonomous,
          tools: classifications[TrustTier.autonomous] ?? [],
          otherTiers: const [
            (TrustTier.softApproval, 'Verplaats naar Soft'),
            (TrustTier.hardApproval, 'Verplaats naar Hard'),
          ],
        ),
        _buildTierSection(
          context: context,
          ref: ref,
          title: 'Soft \u2014 1 tik toestemming',
          tier: TrustTier.softApproval,
          tools: classifications[TrustTier.softApproval] ?? [],
          otherTiers: const [
            (TrustTier.autonomous, 'Verplaats naar Autonoom'),
            (TrustTier.hardApproval, 'Verplaats naar Hard'),
          ],
        ),
        _buildTierSection(
          context: context,
          ref: ref,
          title: 'Hard \u2014 dubbele bevestiging',
          tier: TrustTier.hardApproval,
          tools: classifications[TrustTier.hardApproval] ?? [],
          otherTiers: const [
            (TrustTier.autonomous, 'Verplaats naar Autonoom'),
            (TrustTier.softApproval, 'Verplaats naar Soft'),
          ],
        ),
      ],
    );
  }

  Widget _buildTierSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required TrustTier tier,
    required List<String> tools,
    required List<(TrustTier, String)> otherTiers,
  }) {
    return ExpansionTile(
      title: Text(title),
      children: tools
          .map(
            (tool) => ListTile(
              title: Text(
                tool,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                ),
              ),
              trailing: PopupMenuButton<TrustTier>(
                onSelected: (newTier) => _moveTool(ref, tool, newTier),
                itemBuilder: (_) => otherTiers
                    .map(
                      (entry) => PopupMenuItem(
                        value: entry.$1,
                        child: Text(entry.$2),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  void _moveTool(WidgetRef ref, String toolName, TrustTier newTier) {
    final classifier = ref.read(trustTierClassifierProvider);
    classifier.overrideTier(toolName, newTier);
    classifier.persistOverrides();
  }
}
