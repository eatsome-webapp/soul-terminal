import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../core/di/providers.dart';
import '../../generated/terminal_bridge.g.dart';
import '../../services/vessels/models/vessel_connection.dart';
import '../../services/vessels/models/vessel_task.dart';
import '../vessels/vessel_status_indicator.dart';

/// App shell with Material 3 NavigationBar for top-level navigation.
/// Four destinations: Conversations, Decisions, Profile, Terminal.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static final _log = Logger();
  final _bridge = TerminalBridgeApi();
  int _previousIndex = 0;

  void _onDestinationSelected(int index) {
    final isTerminal = index == 3;
    final wasTerminal = _previousIndex == 3;

    // Toggle native terminal overlay visibility
    if (isTerminal && !wasTerminal) {
      _bridge.setTerminalVisible(true).catchError((error) {
        _log.e('Failed to show terminal: $error');
      });
    } else if (!isTerminal && wasTerminal) {
      _bridge.setTerminalVisible(false).catchError((error) {
        _log.e('Failed to hide terminal: $error');
      });
    }

    _previousIndex = index;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final vesselManager = ref.watch(vesselManagerProvider);
    final hasOpenClaw =
        vesselManager.getConnectionStatus(VesselType.openClaw) != null;
    final hasAgentSdk =
        vesselManager.getConnectionStatus(VesselType.agentSdk) != null;
    final hasVessel = hasOpenClaw || hasAgentSdk;
    final activeProjectId = ref.watch(activeProjectProvider);
    final projectsAsync = ref.watch(activeProjectsProvider);

    final isTerminalTab = widget.navigationShell.currentIndex == 3;

    return Scaffold(
      appBar: isTerminalTab ? null : AppBar(
        title: projectsAsync.when(
          data: (projects) {
            final activeProject = projects
                .where((p) => p.id == activeProjectId)
                .firstOrNull;
            return PopupMenuButton<String>(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeProject?.name ?? 'SOUL',
                    style: const TextStyle(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
              onSelected: (value) {
                if (value == '_new') {
                  context.push('/onboarding');
                } else {
                  ref
                      .read(activeProjectProvider.notifier)
                      .setActiveProject(value);
                  ref.read(projectDaoProvider).setActiveProject(value);
                }
              },
              itemBuilder: (context) => [
                ...projects.map(
                  (project) => PopupMenuItem<String>(
                    value: project.id,
                    child: Text(project.name),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: '_new',
                  child: Text('Nieuw project toevoegen'),
                ),
              ],
            );
          },
          loading: () => const Text(
            'SOUL',
            style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w600),
          ),
          error: (_, __) => const Text(
            'SOUL',
            style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          if (hasOpenClaw)
            VesselStatusIndicator(
              vesselName: 'OpenClaw',
              status: vesselManager.getConnectionStatus(VesselType.openClaw)?.status ?? ConnectionStatus.disconnected,
            ),
          if (hasAgentSdk)
            VesselStatusIndicator(
              vesselName: 'Agent SDK',
              status: vesselManager.getConnectionStatus(VesselType.agentSdk)?.status ?? ConnectionStatus.disconnected,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Instellingen',
          ),
        ],
      ),
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Conversations',
            tooltip: 'Conversations',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Decisions',
            tooltip: 'Decisions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
            tooltip: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: 'Terminal',
            tooltip: 'Terminal',
          ),
        ],
      ),
    );
  }
}
