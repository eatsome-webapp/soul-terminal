import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/sentry_config.dart';
import 'core/theme/soul_theme.dart';
import 'objectbox.g.dart';
import 'services/auth/api_key_service.dart';
import 'services/vessels/openclaw/openclaw_client.dart';
import 'services/vessels/openclaw/openclaw_config.dart';

final _logger = Logger();

void main() {
  final container = ProviderContainer();

  SentryConfig.init(
    appRunner: () async {
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const SoulInitWidget(),
        ),
      );
    },
  );
}

/// Root widget that shows a loading screen while async initialization completes,
/// then transitions to the full SOUL app once ready.
class SoulInitWidget extends StatefulWidget {
  const SoulInitWidget({super.key});

  @override
  State<SoulInitWidget> createState() => _SoulInitWidgetState();
}

class _SoulInitWidgetState extends State<SoulInitWidget> {
  String? _initialLocation;
  bool _initComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final container = ProviderScope.containerOf(context, listen: false);

    // Initialize bridge handler early so Java-side calls are handled
    // even before the full SOUL UI has loaded.
    container.read(pigeonBridgeHandlerProvider);

    // 1. Open ObjectBox store
    final store = await openStore();
    container.read(objectBoxStoreProvider.notifier).state = store;
    _logger.i('ObjectBox store initialized');

    // 2. Load Anthropic API key
    final apiKeyService = ApiKeyService();
    final savedKey = await apiKeyService.getAnthropicKey() ?? '';
    if (savedKey.isNotEmpty) {
      container.read(apiKeyNotifierProvider.notifier).setKey(savedKey);
      _logger.i('API key loaded from secure storage');
    }

    // 3. Initialize OpenClaw client (non-fatal)
    try {
      final hasOpenClaw = await apiKeyService.hasOpenClawCredentials();
      if (hasOpenClaw) {
        final host = await apiKeyService.getOpenClawHost();
        final token = await apiKeyService.getOpenClawToken();
        final useTls = await apiKeyService.getOpenClawUseTls();
        final config = OpenClawConfig(
          host: host!,
          port: useTls ? 443 : 18789,
          token: token!,
          useTls: useTls,
        );
        final client = OpenClawClient(config: config);
        await client.connect();
        container.read(vesselManagerProvider).setOpenClawClient(client);
        _logger.i('OpenClaw client initialized: ${config.baseUrl}');
      }
    } catch (error) {
      _logger.e('Failed to initialize OpenClaw client: $error');
    }

    // 4. Initialize notification service (non-fatal)
    try {
      final notificationService =
          container.read(localNotificationServiceProvider);
      await notificationService.initialize();
      _logger.i('Local notification service initialized');
    } catch (error) {
      _logger.e('Failed to initialize notification service: $error');
    }

    // 5. Initialize foreground service (non-fatal)
    try {
      final serviceManager = container.read(foregroundServiceManagerProvider);
      serviceManager.initialize();
      await serviceManager.startService();
      _logger.i('Foreground service started');
    } catch (error) {
      _logger.e('Failed to start foreground service: $error');
    }

    // 6. Determine initial route
    String initialLocation;
    try {
      final projectDao = container.read(projectDaoProvider);
      final activeProject = await projectDao.getActiveProject();
      final hasProjects = activeProject != null;
      initialLocation =
          (hasProjects && savedKey.isNotEmpty) ? '/' : '/chat/new';
    } catch (error) {
      _logger.e('Failed to check projects: $error');
      initialLocation = '/chat/new';
    }

    if (mounted) {
      setState(() {
        _initialLocation = initialLocation;
        _initComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initComplete) {
      return const _SoulLoadingScreen();
    }
    return SoulApp(initialLocation: _initialLocation!);
  }
}

/// Branded loading screen shown during async initialization.
class _SoulLoadingScreen extends StatelessWidget {
  const _SoulLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0F23),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SOUL',
                style: TextStyle(
                  color: const Color(0xFF6C63FF),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SoulApp extends StatefulWidget {
  final String initialLocation;

  const SoulApp({super.key, required this.initialLocation});

  @override
  State<SoulApp> createState() => _SoulAppState();
}

class _SoulAppState extends State<SoulApp> {
  late final _router = createAppRouter(initialLocation: widget.initialLocation);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SOUL',
      theme: SoulTheme.light(null),
      darkTheme: SoulTheme.dark(null),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
