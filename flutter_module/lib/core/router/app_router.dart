import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/chat/chat_screen.dart';
import '../../ui/conversations/conversation_list_screen.dart';
import '../../ui/decisions/decision_list_screen.dart';
import '../../ui/decisions/decision_detail_screen.dart';
import '../../ui/onboarding/onboarding_screen.dart';
import '../../ui/profile/profile_screen.dart';
import '../../ui/setup/setup_screen.dart';
import '../../ui/terminal/terminal_screen.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/settings/settings_screen.dart';
import '../../ui/vessels/vessel_settings_screen.dart';
import '../../ui/projects/project_dashboard_screen.dart';
import '../../ui/setup_wizard/setup_wizard_screen.dart';

GoRouter createAppRouter({String initialLocation = '/'}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        // Shell route with bottom navigation
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Conversations
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const ConversationListScreen(),
                ),
              ],
            ),
            // Branch 1: Decisions
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/decisions',
                  builder: (context, state) => const DecisionListScreen(),
                ),
              ],
            ),
            // Branch 2: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
            // Branch 3: Terminal
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/terminal',
                  builder: (context, state) => const TerminalScreen(),
                ),
              ],
            ),
          ],
        ),
        // Top-level routes (no bottom nav)
        GoRoute(
          path: '/setup',
          builder: (context, state) => const SetupScreen(),
        ),
        GoRoute(
          path: '/chat/new',
          builder: (context, state) => const ChatScreen(conversationId: null),
        ),
        GoRoute(
          path: '/chat/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            return ChatScreen(conversationId: conversationId);
          },
        ),
        GoRoute(
          path: '/decisions/:decisionId',
          builder: (context, state) {
            final decisionId = state.pathParameters['decisionId']!;
            return DecisionDetailScreen(decisionId: decisionId);
          },
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/setup-wizard',
          builder: (context, state) => const SetupWizardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/vessels',
          builder: (context, state) => const VesselSettingsScreen(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectDashboardScreen(),
        ),
      ],
    );
