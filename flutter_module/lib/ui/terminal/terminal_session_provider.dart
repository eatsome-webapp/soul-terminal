import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'terminal_session.dart';

class TerminalSessionsState {
  final List<TerminalSession> sessions;
  final int activeIndex;

  const TerminalSessionsState({
    this.sessions = const [],
    this.activeIndex = 0,
  });

  TerminalSession? get activeSession =>
      sessions.isNotEmpty && activeIndex < sessions.length
          ? sessions[activeIndex]
          : null;

  TerminalSessionsState copyWith({
    List<TerminalSession>? sessions,
    int? activeIndex,
  }) {
    return TerminalSessionsState(
      sessions: sessions ?? this.sessions,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

class TerminalSessionsNotifier extends Notifier<TerminalSessionsState> {
  final Logger _log = Logger();

  @override
  TerminalSessionsState build() {
    // Start with one default session
    final defaultSession = TerminalSession(
      id: const Uuid().v4(),
      label: 'Terminal 1',
    );
    return TerminalSessionsState(sessions: [defaultSession]);
  }

  /// Add a new terminal session tab.
  void addSession({String? label}) {
    final index = state.sessions.length + 1;
    final session = TerminalSession(
      id: const Uuid().v4(),
      label: label ?? 'Terminal $index',
    );
    state = state.copyWith(
      sessions: [...state.sessions, session],
      activeIndex: state.sessions.length,
    );
    _log.i('Added terminal session: ${session.label}');
  }

  /// Remove a terminal session tab.
  void removeSession(String sessionId) {
    final sessions = state.sessions.where((s) => s.id != sessionId).toList();
    if (sessions.isEmpty) return; // Keep at least one
    final newIndex = state.activeIndex >= sessions.length
        ? sessions.length - 1
        : state.activeIndex;
    state = state.copyWith(sessions: sessions, activeIndex: newIndex);
    _log.i('Removed terminal session: $sessionId');
  }

  /// Switch to a terminal session tab by index.
  void setActiveIndex(int index) {
    if (index >= 0 && index < state.sessions.length) {
      state = state.copyWith(activeIndex: index);
    }
  }

  /// Get a session by ID.
  TerminalSession? getSession(String sessionId) {
    try {
      return state.sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  /// Update a session's connection status.
  void updateSessionStatus(
    String sessionId,
    TerminalSessionStatus status, {
    String? errorMessage,
  }) {
    final sessions = state.sessions.map((s) {
      if (s.id == sessionId) {
        s.status = status;
        s.errorMessage = errorMessage;
      }
      return s;
    }).toList();
    state = state.copyWith(sessions: sessions);
  }
}

final terminalSessionsProvider =
    NotifierProvider<TerminalSessionsNotifier, TerminalSessionsState>(
  TerminalSessionsNotifier.new,
);
