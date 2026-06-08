import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:test_gen_ui_1/core/constants/app_constants.dart';
import 'package:test_gen_ui_1/shared/models/app_settings.dart';
import 'package:test_gen_ui_1/shared/repositories/settings_repository.dart';

void main() {
  late Directory tempDir;
  late SettingsRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('settings_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.hiveBoxSettings);
    repository = SettingsRepository();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('SettingsRepository returns default settings when box is empty', () {
    final settings = repository.getSettings();
    expect(settings.themeMode, ThemeModeOption.system);
    expect(settings.preferredProvider, AiProviderType.auto);
    expect(settings.groqApiKey, isEmpty);
  });

  test('SettingsRepository saves and retrieves settings correctly', () async {
    const settings = AppSettings(
      themeMode: ThemeModeOption.dark,
      preferredProvider: AiProviderType.groq,
      groqApiKey: 'gsk_test_key_123',
    );

    await repository.saveSettings(settings);

    final retrieved = repository.getSettings();
    expect(retrieved.themeMode, ThemeModeOption.dark);
    expect(retrieved.preferredProvider, AiProviderType.groq);
    expect(retrieved.groqApiKey, 'gsk_test_key_123');
  });

  test('SettingsRepository completeOnboarding updates settings state', () async {
    expect(repository.getSettings().onboardingComplete, isFalse);

    await repository.completeOnboarding();

    expect(repository.getSettings().onboardingComplete, isTrue);
  });
}
