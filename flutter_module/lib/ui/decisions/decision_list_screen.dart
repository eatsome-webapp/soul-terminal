import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';

final decisionListProvider = StreamProvider<List<dynamic>>((ref) {
  final dao = ref.watch(decisionDaoProvider);
  return dao.watchAllDecisions();
});

class DecisionListScreen extends ConsumerStatefulWidget {
  const DecisionListScreen({super.key});

  @override
  ConsumerState<DecisionListScreen> createState() => _DecisionListScreenState();
}

class _DecisionListScreenState extends ConsumerState<DecisionListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<dynamic>? _searchResults;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    final dao = ref.read(decisionDaoProvider);
    final results = await dao.searchDecisionContent(query);
    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    final decisionsAsync = ref.watch(decisionListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search decisions...',
                  border: InputBorder.none,
                ),
                onChanged: _search,
              )
            : const Text('Decisions'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: 'Search decisions',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchResults = null;
                }
              });
            },
          ),
        ],
      ),
      body: _searchResults != null
          ? _buildDecisionList(context, _searchResults!)
          : decisionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load decisions',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.error),
                ),
              ),
              data: (decisions) {
                if (decisions.isEmpty) return _buildEmptyState(context);
                return _buildDecisionList(context, decisions);
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
            Text('No decisions yet', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'As you chat with SOUL, strategic decisions are automatically captured here.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionList(BuildContext context, List<dynamic> decisions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: decisions.length,
      itemBuilder: (context, index) {
        final d = decisions[index];
        return _DecisionCard(
          title: d.title as String,
          domain: d.domain as String,
          reasoning: d.reasoning as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(d.createdAt as int),
          onTap: () => context.push('/decisions/${d.id}'),
        );
      },
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final String title;
  final String domain;
  final String reasoning;
  final DateTime createdAt;
  final VoidCallback onTap;

  const _DecisionCard({
    required this.title,
    required this.domain,
    required this.reasoning,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Chip(
                label: Text(domain, style: textTheme.labelLarge),
                backgroundColor: colorScheme.secondaryContainer,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 8),
              Text(
                reasoning,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatRelativeTime(createdAt),
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
