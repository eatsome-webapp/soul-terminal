import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/utils/logger.dart';
import '../ai/claude_service.dart';

/// Queued message waiting to be sent when connectivity returns.
class QueuedMessage {
  final String text;
  final String conversationId;
  final DateTime queuedAt;

  QueuedMessage({
    required this.text,
    required this.conversationId,
    required this.queuedAt,
  });
}

/// Manages offline message queueing and automatic retry.
///
/// When a message cannot be sent (offline), it is stored in an in-memory queue.
/// When connectivity is restored, queued messages are replayed in order via
/// the [onReplayMessage] callback.
class OfflineMessageQueue {
  final List<QueuedMessage> _queue = [];
  final ClaudeService _claudeService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Called for each queued message when connectivity is restored.
  /// Set this to trigger [ChatNotifier.sendMessage] for replay.
  void Function(QueuedMessage message)? onReplayMessage;

  OfflineMessageQueue({required ClaudeService claudeService})
      : _claudeService = claudeService;

  /// The underlying Claude service (available for replay logic).
  ClaudeService get claudeService => _claudeService;

  /// Start listening for connectivity changes.
  void startListening() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline && _queue.isNotEmpty) {
        _replayQueue();
      }
    });
  }

  /// Queue a message for later sending.
  void enqueue(QueuedMessage message) {
    final preview = message.text.length > 50
        ? '${message.text.substring(0, 50)}...'
        : message.text;
    log.i('Queueing message for offline retry: $preview');
    _queue.add(message);
  }

  /// Check if there are queued messages.
  bool get hasQueuedMessages => _queue.isNotEmpty;

  /// Number of queued messages.
  int get queueLength => _queue.length;

  /// Replay all queued messages in order.
  Future<void> _replayQueue() async {
    log.i(
      'Connectivity restored. Replaying ${_queue.length} queued messages.',
    );
    while (_queue.isNotEmpty) {
      final message = _queue.removeAt(0);
      if (onReplayMessage != null) {
        onReplayMessage!(message);
      }
    }
  }

  /// Clean up resources.
  void dispose() {
    _connectivitySub?.cancel();
  }
}
