import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

final profileSummaryProvider = FutureProvider<String>((ref) {
  final learner = ref.watch(profileLearnerProvider);
  return learner.generateProfileSummary();
});

final profileTraitsProvider = FutureProvider<List<dynamic>>((ref) {
  final dao = ref.watch(profileDaoProvider);
  return dao.getAllTraits();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final summaryAsync = ref.watch(profileSummaryProvider);
    final traitsAsync = ref.watch(profileTraitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About you')),
      body: traitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error loading profile', style: textTheme.bodyMedium)),
        data: (traits) {
          if (traits.isEmpty) return _buildEmptyState(context);
          return _buildProfile(context, ref, traits, summaryAsync);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Still learning about you', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'The more we talk, the better I understand your style and preferences. Keep chatting.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref,
      List<dynamic> traits, AsyncValue<String> summaryAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Group traits by category
    final grouped = <String, List<dynamic>>{};
    for (final t in traits) {
      final category = t.category as String;
      grouped.putIfAbsent(category, () => []).add(t);
    }

    final categoryLabels = {
      'style': 'Communication style',
      'preference': 'Preferences',
      'pattern': 'Decision patterns',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Card(
            color: colorScheme.surfaceContainerHigh,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: summaryAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text(
                  "I'm still getting to know you. After a few more conversations, I'll have a clearer picture of how you work.",
                  style: textTheme.bodyLarge,
                ),
                data: (summary) =>
                    Text(summary, style: textTheme.bodyLarge),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Category sections
          ...grouped.entries.map((entry) {
            final label = categoryLabels[entry.key] ?? entry.key;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((t) {
                    final confidence = (t.confidence as num).toDouble();
                    final evidenceCount = t.evidenceCount as int;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          avatar: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: confidence >= 0.7
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          label: Text(
                            '${t.traitKey}: ${t.traitValue}',
                            style: textTheme.bodyMedium,
                          ),
                          backgroundColor: colorScheme.tertiaryContainer,
                          side: BorderSide.none,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Observed $evidenceCount times',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
