import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';

class DecisionDetailScreen extends ConsumerWidget {
  final String decisionId;
  const DecisionDetailScreen({super.key, required this.decisionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: ref.read(decisionDaoProvider).getDecision(decisionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final decision = snapshot.data;
          if (decision == null) {
            return const Center(child: Text('Decision not found'));
          }

          List<String>? alternatives;
          if (decision.alternativesConsidered != null) {
            try {
              alternatives = List<String>.from(
                jsonDecode(decision.alternativesConsidered as String) as List,
              );
            } catch (_) {}
          }

          final createdAt =
              DateTime.fromMillisecondsSinceEpoch(decision.createdAt as int);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Superseded banner
                if (decision.supersededBy != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          context.push('/decisions/${decision.supersededBy}'),
                      child: Text(
                        'This decision has been superseded',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                // Title
                Text(decision.title as String, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                // Domain chip
                Chip(
                  label: Text(decision.domain as String,
                      style: textTheme.labelLarge),
                  backgroundColor: colorScheme.secondaryContainer,
                  side: BorderSide.none,
                ),
                const SizedBox(height: 16),
                // Reasoning
                Text(decision.reasoning as String, style: textTheme.bodyLarge),
                const SizedBox(height: 8),
                // Timestamp
                Text(
                  '${createdAt.day}/${createdAt.month}/${createdAt.year} at ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                // Alternatives
                if (alternatives != null && alternatives.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Alternatives considered', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  ...alternatives.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('\u2022 '),
                          Expanded(
                            child: Text(a, style: textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Context link
                TextButton(
                  onPressed: () {
                    context.push('/chat/${decision.conversationId}');
                  },
                  child: const Text('View original conversation'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
