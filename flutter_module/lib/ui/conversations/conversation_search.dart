import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';

/// Search screen for finding messages across conversations via FTS5.
///
/// Debounces input by 300ms before calling [ConversationDao.searchMessageContent].
/// Results are grouped by conversation with matching message snippets.
class ConversationSearchScreen extends ConsumerStatefulWidget {
  const ConversationSearchScreen({super.key});

  @override
  ConsumerState<ConversationSearchScreen> createState() =>
      _ConversationSearchScreenState();
}

class _ConversationSearchScreenState
    extends ConsumerState<ConversationSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<dynamic> _results = [];
  String _lastQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final dao = ref.read(conversationDaoProvider);
    try {
      final results = await dao.searchMessageContent(query);
      setState(() {
        _results = results;
        _lastQuery = query;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            border: InputBorder.none,
          ),
          style: textTheme.bodyLarge,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lastQuery.isNotEmpty && _results.isEmpty) {
      return Center(
        child: Text(
          'No results for "$_lastQuery"',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'Type to search across all conversations',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final message = _results[index];
        // message is a Drift Message row: id, conversationId, role, content, createdAt
        final content = message.content as String;
        final conversationId = message.conversationId as String;
        final role = message.role as String;

        // Show a snippet of the matching content
        final snippet = content.length > 120
            ? '${content.substring(0, 120)}...'
            : content;

        return ListTile(
          leading: Icon(
            role == 'user' ? Icons.person : Icons.auto_awesome,
            color: colorScheme.onSurfaceVariant,
          ),
          title: Text(
            snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            role == 'user' ? 'You' : 'SOUL',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          onTap: () => context.push('/chat/$conversationId'),
        );
      },
    );
  }
}
