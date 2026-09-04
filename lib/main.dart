import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'data/database.dart';
import 'core/design/dark_theme.dart';
import 'core/design/light_theme.dart';
import 'core/l10n/strings.dart';
import 'presentation/router.dart';
import 'providers/theme_provider.dart';
import 'domain/services/notification_service.dart';
import 'services/tour_service.dart';
import 'services/widget_bridge.dart';
import 'services/widget_action.dart';
import 'data/repositories/task_repository.dart';

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
  } catch (_) {}

  try {
    await SharedPreferences.getInstance();
  } catch (_) {}

  try {
    await TaskRepository().purgeOldTrash();
  } catch (_) {}

  if (!kIsWeb) {
    try {
      HomeWidget.setAppGroupId(WidgetBridge.groupId);
      HomeWidget.widgetClicked.listen((_) {});
    } catch (_) {}
  }

  final introSeen = await TourService.isIntroSeen();
  final initialLocation = introSeen ? '/' : '/intro';

  final router = appRouter(initialLocation: initialLocation);

  runApp(
    ProviderScope(
      child: TodoawApp(router: router),
    ),
  );

  if (!kIsWeb && Platform.isAndroid) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        const channel = MethodChannel('com.todoaw.todoaw/widget_action');
        final action = await channel.invokeMethod('getPendingAction');
        if (action != null && action is Map) {
          PendingWidgetAction.action = action['action'] as String?;
          PendingWidgetAction.taskUuid = action['taskUuid'] as String?;
        }
      } catch (_) {}
    });
  }
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
