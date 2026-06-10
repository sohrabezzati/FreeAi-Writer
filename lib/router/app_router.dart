import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/logger.dart';
import '../../shared/providers/settings_provider.dart';
import '../features/chat/chat_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/settings/settings_screen.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigation: Pushed route ${route.settings.name ?? route.toString()} (from ${previousRoute?.settings.name ?? previousRoute?.toString()})');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigation: Popped route ${route.settings.name ?? route.toString()} (returning to ${previousRoute?.settings.name ?? previousRoute?.toString()})');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.info('Navigation: Replaced route ${oldRoute?.settings.name ?? oldRoute?.toString()} with ${newRoute?.settings.name ?? newRoute?.toString()}');
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // Only rebuild the router for navigation-critical settings changes.
  final onboardingComplete = ref.watch(
    settingsProvider.select((settings) => settings.onboardingComplete),
  );

  return GoRouter(
    initialLocation: '/splash',
    observers: [LoggingNavigatorObserver()],
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (location == '/splash') return null;

      if (!onboardingComplete &&
          location != '/onboarding' &&
          location != '/splash') {
        AppLogger.info('Redirecting to onboarding (onboarding incomplete).');
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            sessionId: extra?['sessionId'] as String?,
            templateId: extra?['templateId'] as String?,
            systemPrompt: extra?['systemPrompt'] as String?,
            initialTitle: extra?['title'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
