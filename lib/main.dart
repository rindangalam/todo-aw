import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'core/design/dark_theme.dart';
import 'core/design/light_theme.dart';
import 'core/l10n/strings.dart';
import 'presentation/router.dart';
import 'providers/theme_provider.dart';
import 'domain/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init();
  await NotificationService.init();
  // Pre-load SharedPreferences so theme setting is ready on first frame
  await SharedPreferences.getInstance();
  runApp(
    const ProviderScope(
      child: TodoawApp(),
    ),
  );
}

class TodoawApp extends ConsumerWidget {
  const TodoawApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
