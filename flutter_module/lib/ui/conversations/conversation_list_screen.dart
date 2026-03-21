import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/providers.dart';
import '../common/offline_banner.dart';
import 'conversation_search.dart';
import 'widgets/conversation_list_tile.dart';

/// Reactive stream of all conversations, sorted by most recent.
final conversationListProvider = StreamProvider<List<dynamic>>((ref) {
  final dao = ref.watch(conversationDaoProvider);
  return dao.watchAllConversations();
});

/// Main screen showing all conversations with search, FAB, and swipe-to-delete.
class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ConversationSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Consumer(
            builder: (context, ref, _) {
              final hasProject = ref.watch(hasProjectProvider);
              return hasProject.when(
                data: (has) => has
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: colorScheme.surfaceContainerHigh,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Set up your project so SOUL can help you better.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () => context.go('/onboarding'),
                                  child: const Text('Set up'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Expanded(
            child: conversationsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to load conversations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                ),
              ),
              data: (conversations) {
                if (conversations.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildConversationList(
                  context,
                  ref,
                  conversations,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final id = const Uuid().v4();
          context.push('/chat/$id');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first conversation with SOUL.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, _) {
              final hasProject = ref.watch(hasProjectProvider);
              return hasProject.when(
                data: (has) => has
                    ? FilledButton(
                        onPressed: () => context.push('/chat/new'),
                        child: const Text('Start a conversation'),
                      )
                    : FilledButton(
                        onPressed: () => context.go('/onboarding'),
                        child: const Text('Set up your project'),
                      ),
                loading: () => FilledButton(
                  onPressed: () => context.push('/chat/new'),
                  child: const Text('Start a conversation'),
                ),
                error: (_, __) => FilledButton(
                  onPressed: () => context.push('/chat/new'),
                  child: const Text('Start a conversation'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> conversations,
  ) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        // Drift row: id, title, createdAt (int), updatedAt (int), lastMessagePreview
        final id = conversation.id as String;
        final title = conversation.title as String;
        final updatedAt = DateTime.fromMillisecondsSinceEpoch(
          conversation.updatedAt as int,
        );
        final preview = conversation.lastMessagePreview as String?;

        return ConversationListTile(
          title: title,
          preview: preview,
          updatedAt: updatedAt,
          onTap: () => context.push('/chat/$id'),
          onDelete: () async {
            final dao = ref.read(conversationDaoProvider);
            await dao.deleteConversation(id);
          },
        );
      },
    );
  }
}
