import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/calendar_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/search_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/tags_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/trash_screen.dart';
import 'screens/archive_screen.dart';
import 'widgets/intro_slides.dart';

import '../core/l10n/strings.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

Page<dynamic> _slideFromRight(Widget child) {
  return CustomTransitionPage<dynamic>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

Page<dynamic> _fadeIn(Widget child) {
  return CustomTransitionPage<dynamic>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

Page<dynamic> _noTransition(Widget child) {
  return NoTransitionPage<dynamic>(child: child);
}

GoRouter appRouter({String initialLocation = '/splash'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeIn(const SplashScreen()),
      ),
      GoRoute(
        path: '/intro',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeIn(const IntroSlides()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final location = state.location;
          final int currentIndex;
          if (location == '/') {
            currentIndex = 0;
          } else if (location.startsWith('/calendar')) {
            currentIndex = 1;
          } else if (location.startsWith('/dashboard')) {
            currentIndex = 2;
          } else if (location.startsWith('/notes')) {
            currentIndex = 3;
          } else if (location.startsWith('/settings')) {
            currentIndex = 4;
          } else {
            currentIndex = 0;
          }
          return ScaffoldWithNavBar(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _noTransition(const HomeScreen()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                _noTransition(const CalendarScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                _noTransition(const DashboardScreen()),
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) =>
                _noTransition(const NotesScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _noTransition(const SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(const SearchScreen()),
      ),
      GoRoute(
        path: '/trash',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(const TrashScreen()),
      ),
      GoRoute(
        path: '/archive',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(const ArchiveScreen()),
      ),
      GoRoute(
        path: '/categories',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(const CategoriesScreen()),
      ),
      GoRoute(
        path: '/tags',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(const TagsScreen()),
      ),
      GoRoute(
        path: '/habits',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(const HabitsScreen()),
      ),
      GoRoute(
        path: '/focus',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(const FocusScreen()),
      ),
    ],
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/calendar');
              break;
            case 2:
              context.go('/dashboard');
              break;
            case 3:
              context.go('/notes');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: S.navBeranda,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: S.navKalender,
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: S.navDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_outlined),
            selectedIcon: Icon(Icons.sticky_note_2),
            label: S.navCatatan,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: S.navPengaturan,
          ),
        ],
      ),
    );
  }
}
