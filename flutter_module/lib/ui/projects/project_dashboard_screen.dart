import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../services/database/soul_database.dart' show Project;
import '../../services/monitoring/ci_status.dart';
import 'widgets/project_card.dart';

/// Provider for CI status cache from CiMonitorService.
final ciStatusCacheProvider = Provider<Map<String, CiStatus>>((ref) {
  final ciMonitor = ref.watch(ciMonitorServiceProvider);
  return ciMonitor.getAllStatuses();
});

/// Dashboard screen showing all active projects with CI status cards.
class ProjectDashboardScreen extends ConsumerWidget {
  const ProjectDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(activeProjectsProvider);
    final ciStatuses = ref.watch(ciStatusCacheProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projecten'),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Kan projecten niet laden',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
          ),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildProjectList(context, ref, projects, ciStatuses);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/onboarding'),
        icon: const Icon(Icons.add),
        label: const Text('Nieuw project'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nog geen projecten',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg je eerste project toe.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(
    BuildContext context,
    WidgetRef ref,
    List<Project> projects,
    Map<String, CiStatus> ciStatuses,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final ciStatus = ciStatuses[project.id];

        return ProjectCard(
          project: project,
          ciStatus: ciStatus,
          onTap: () {
            ref
                .read(activeProjectProvider.notifier)
                .setActiveProject(project.id);
            ref.read(projectDaoProvider).setActiveProject(project.id);
            context.go('/');
          },
        );
      },
    );
  }
}
