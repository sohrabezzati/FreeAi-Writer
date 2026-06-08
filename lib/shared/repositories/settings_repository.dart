import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository();

  AppSettings getSettings() {
    final data = HiveService.settingsBox.get(AppConstants.hiveKeySettings);
    if (data == null) return _withEnvFallback(const AppSettings());

    try {
      if (data is String) {
        return _withEnvFallback(
          AppSettings.fromJson(
            jsonDecode(data) as Map<String, dynamic>,
          ),
        );
      }
      if (data is Map) {
        return _withEnvFallback(
          AppSettings.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    } catch (_) {
      return _withEnvFallback(const AppSettings());
    }

    return _withEnvFallback(const AppSettings());
  }

  AppSettings _withEnvFallback(AppSettings settings) {
    return settings.copyWith(
      groqApiKey: settings.groqApiKey.isNotEmpty
          ? settings.groqApiKey
          : const String.fromEnvironment('GROQ_API_KEY'),
      openRouterApiKey: settings.openRouterApiKey.isNotEmpty
          ? settings.openRouterApiKey
          : const String.fromEnvironment('OPENROUTER_API_KEY'),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await HiveService.settingsBox.put(
      AppConstants.hiveKeySettings,
      jsonEncode(settings.toJson()),
    );
  }

  Future<void> completeOnboarding() async {
    final current = getSettings();
    await saveSettings(current.copyWith(onboardingComplete: true));
  }

  Future<void> clearAll() async {
    await HiveService.settingsBox.clear();
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
