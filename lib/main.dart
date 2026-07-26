import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'core/design/dark_theme.dart';
import 'core/design/light_theme.dart';
import 'core/l10n/strings.dart';
import 'presentation/router.dart';
import 'providers/theme_provider.dart';
import 'domain/services/notification_service.dart';
import 'services/tour_service.dart';
import 'services/widget_bridge.dart';
import 'data/repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Platform.localeName;
  await initializeDateFormatting();
  await AppDatabase.init();
  await NotificationService.init();
  await SharedPreferences.getInstance();
  await TaskRepository().purgeOldTrash();

  HomeWidget.setAppGroupId(WidgetBridge.groupId);
  HomeWidget.widgetClicked.listen((_) {});

  final introSeen = await TourService.isIntroSeen();
  final initialLocation = introSeen ? '/' : '/intro';

  final router = appRouter(initialLocation: initialLocation);

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
      routerConfig: router,
    );
  }
}
