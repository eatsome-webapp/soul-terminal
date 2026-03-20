import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/di/providers.dart';
import 'terminal_session.dart';
import 'terminal_session_provider.dart';
import 'terminal_session_view.dart';

/// Main terminal screen with multi-session tab management.
/// Each tab shows a TerminalSessionView connected to a vessel.
class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen>
    with TickerProviderStateMixin {
  final Logger _log = Logger();
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(int length, int activeIndex) {
    if (_tabController == null ||
        _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: activeIndex.clamp(0, length - 1),
      );
      _tabController!.addListener(_onTabChanged);
    } else if (_tabController!.index != activeIndex) {
      _tabController!.animateTo(activeIndex.clamp(0, length - 1));
    }
  }

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging) {
      ref
          .read(terminalSessionsProvider.notifier)
          .setActiveIndex(_tabController!.index);
    }
  }

  void _onTerminalOutput(TerminalSession session, String data) {
    if (!session.isConnected) return;

    // Route user input to the connected vessel via VesselManager (TERM-03)
    final vesselManager = ref.read(vesselManagerProvider);
    vesselManager.proposeTask(
      description: 'Terminal input: ${data.trim()}',
      tool: 'exec',
      args: {'command': data},
      targetVessel: session.vesselType,
    );
    _log.d('Terminal input routed to vessel: ${session.vesselType}');
  }

  void _connectWebSocketStream(TerminalSession session) {
    // Bind WebSocket output stream to terminal display (TERM-02)
    if (session.webSocketChannel != null) {
      session.webSocketChannel!.stream.listen(
        (data) {
          session.terminal.write(data.toString());
        },
        onError: (error) {
          _log.e('WebSocket error for session ${session.id}: $error');
          ref.read(terminalSessionsProvider.notifier).updateSessionStatus(
                session.id,
                TerminalSessionStatus.error,
                errorMessage: error.toString(),
              );
        },
        onDone: () {
          _log.i('WebSocket closed for session ${session.id}');
          ref.read(terminalSessionsProvider.notifier).updateSessionStatus(
                session.id,
                TerminalSessionStatus.disconnected,
              );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(terminalSessionsProvider);
    final sessions = state.sessions;

    if (sessions.isEmpty) {
      return const Center(child: Text('No terminal sessions'));
    }

    _syncTabController(sessions.length, state.activeIndex);

    // Set up terminal.onOutput for each session
    for (final session in sessions) {
      session.terminal.onOutput = (data) {
        _onTerminalOutput(session, data);
      };

      // Connect WebSocket streams for connected sessions
      if (session.isConnected) {
        _connectWebSocketStream(session);
      }
    }

    return Column(
      children: [
        // Tab bar with dark terminal background
        Container(
          color: const Color(0xFF0D0D1A),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: sessions.map((session) {
                    return GestureDetector(
                      onLongPress: sessions.length > 1
                          ? () {
                              ref
                                  .read(terminalSessionsProvider.notifier)
                                  .removeSession(session.id);
                            }
                          : null,
                      child: Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              session.isConnected
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 8,
                              color: session.isConnected
                                  ? Colors.greenAccent
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 6),
                            Text(session.label),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Add tab button
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white70),
                onPressed: () {
                  ref.read(terminalSessionsProvider.notifier).addSession();
                },
                tooltip: 'New terminal session',
              ),
            ],
          ),
        ),
        // Terminal views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: sessions.map((session) {
              return TerminalSessionView(session: session);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
