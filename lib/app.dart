import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/genui/genui.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'shared/providers/settings_provider.dart';

class FreeAiWriterApp extends ConsumerWidget {
  const FreeAiWriterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingsProvider.select((settings) => settings.themeMode),
    );
    final router = ref.watch(routerProvider);
    // Initialize GenUI surface controller for the app lifecycle.
    ref.watch(surfaceControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: GenUiTheme.apply(AppTheme.light()),
      darkTheme: GenUiTheme.apply(AppTheme.dark()),
      themeMode: resolveThemeMode(themeMode),
      routerConfig: router,
    );
  }
}
