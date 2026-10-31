import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

import 'data/database.dart';
import 'core/design/dark_theme.dart';
import 'core/design/light_theme.dart';
import 'core/l10n/strings.dart';
import 'presentation/router.dart';
import 'providers/theme_provider.dart';
import 'domain/services/notification_service.dart';
import 'services/tour_service.dart';
import 'services/widget_action_headless.dart';
import 'services/widget_bridge.dart';
import 'services/widget_quick_input_channel.dart';
import 'services/widget_refresh_worker.dart';
import 'data/repositories/task_repository.dart';

/// Cold-path headless entrypoint invoked by WidgetActionReceiver when no
/// Flutter engine is cached. MUST be declared in this root library: named
/// DartEntrypoints resolve against Dart_RootLibrary() (lib/main.dart), never
/// the file that declares the implementation.
@pragma('vm:entry-point')
void widgetActionHeadless() => runWidgetActionHeadless();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (!kIsWeb) {
    Intl.defaultLocale = Platform.localeName;
  }
  await initializeDateFormatting();

  try {
    await AppDatabase.init();
  } catch (e) {
    // Database init failed — app will show error state
  }

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('[Main] Notification init error: $e');
  }

  try {
    await SharedPreferences.getInstance();
  } catch (_) {}

  try {
    await TaskRepository().purgeOldTrash();
  } catch (_) {}

  // Push home widget snapshot once app is ready (Android only).
  if (!kIsWeb) {
    await setupWidgetQuickInputChannel();
    unawaited(refreshWidgetsFromPrefs());
  }

  // Periodic 30m widget refresh via WorkManager — register once.
  if (!kIsWeb) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registered = prefs.getBool('widget_worker_registered') ?? false;
      if (!registered) {
        await Workmanager().initialize(callbackDispatcher);
        await Workmanager().registerPeriodicTask(
          '1',
          kWidgetRefreshTask,
          frequency: const Duration(minutes: 30),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
          constraints: Constraints(networkType: NetworkType.notRequired),
        );
        await prefs.setBool('widget_worker_registered', true);
      }
    } catch (_) {
      // WorkManager optional; widgets still update via app-open/CRUD paths.
    }
  }

  final introSeen = await TourService.isIntroSeen();
  final widgetLocation = !kIsWeb ? await initialWidgetNotesLocation() : null;
  final initialLocation = introSeen ? widgetLocation ?? '/' : '/intro';

  final router = appRouter(initialLocation: initialLocation);

  if (!kIsWeb) {
    setupWidgetClickStream(navigate: router.go);
  }

  // Re-init notification service with router callback for tap handling
  try {
    await NotificationService.init(
      onNotificationTap: (payload) {
        router.go('/');
      },
    );
  } catch (_) {}

  runApp(
    ProviderScope(
      child: TodoawApp(router: router),
    ),
  );
}

class TodoawApp extends ConsumerWidget {
  final GoRouter router;

  const TodoawApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme(accent: accentColor),
      darkTheme: DarkTheme.theme(accent: accentColor),
      themeMode: themeMode,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));
        return child!;
      },
      routerConfig: router,
    );
  }
}
