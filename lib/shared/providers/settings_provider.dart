import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  late SettingsRepository _repository;

  @override
  AppSettings build() {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _repository.saveSettings(settings);
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    await updateSettings(state.copyWith(themeMode: mode));
  }

  Future<void> setPreferredProvider(AiProviderType provider) async {
    await updateSettings(state.copyWith(preferredProvider: provider));
  }

  Future<void> setApiKey({
    String? huggingFace,
    String? openRouter,
    String? together,
    String? groq,
  }) async {
    await updateSettings(
      state.copyWith(
        huggingFaceApiKey: huggingFace ?? state.huggingFaceApiKey,
        openRouterApiKey: openRouter ?? state.openRouterApiKey,
        togetherApiKey: together ?? state.togetherApiKey,
        groqApiKey: groq ?? state.groqApiKey,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    await updateSettings(state.copyWith(onboardingComplete: true));
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

ThemeMode resolveThemeMode(AppSettings settings) {
  return switch (settings.themeMode) {
    ThemeModeOption.light => ThemeMode.light,
    ThemeModeOption.dark => ThemeMode.dark,
    ThemeModeOption.system => ThemeMode.system,
  };
}
