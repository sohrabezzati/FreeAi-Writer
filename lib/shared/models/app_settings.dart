import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

enum ThemeModeOption {
  @JsonValue('system')
  system,
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
}

enum AiProviderType {
  @JsonValue('auto')
  auto,
  @JsonValue('huggingface')
  huggingface,
  @JsonValue('openrouter')
  openrouter,
  @JsonValue('together')
  together,
  @JsonValue('groq')
  groq,
}

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeModeOption.system) ThemeModeOption themeMode,
    @Default(AiProviderType.auto) AiProviderType preferredProvider,
    @Default('') String huggingFaceApiKey,
    @Default('') String openRouterApiKey,
    @Default('') String togetherApiKey,
    @Default('') String groqApiKey,
    @Default(false) bool onboardingComplete,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}

extension AppSettingsX on AppSettings {
  bool get hasAnyApiKey =>
      huggingFaceApiKey.trim().isNotEmpty ||
      openRouterApiKey.trim().isNotEmpty ||
      togetherApiKey.trim().isNotEmpty ||
      groqApiKey.trim().isNotEmpty;

  List<AiProviderType> get configuredProviders {
    final providers = <AiProviderType>[];
    if (groqApiKey.trim().isNotEmpty) providers.add(AiProviderType.groq);
    if (openRouterApiKey.trim().isNotEmpty) {
      providers.add(AiProviderType.openrouter);
    }
    if (togetherApiKey.trim().isNotEmpty) providers.add(AiProviderType.together);
    if (huggingFaceApiKey.trim().isNotEmpty) {
      providers.add(AiProviderType.huggingface);
    }
    return providers;
  }

  String get missingApiKeyMessage =>
      'No API keys saved yet. Open Settings, paste a free Groq key '
      '(console.groq.com), and tap Save API Keys.';
}

extension AiProviderTypeX on AiProviderType {
  String get displayName => switch (this) {
        AiProviderType.auto => 'Auto (Fallback)',
        AiProviderType.huggingface => 'Hugging Face',
        AiProviderType.openrouter => 'OpenRouter',
        AiProviderType.together => 'Together AI',
        AiProviderType.groq => 'Groq',
      };

  String get description => switch (this) {
        AiProviderType.auto =>
          'Automatically tries providers until one succeeds',
        AiProviderType.huggingface => 'Free inference API models',
        AiProviderType.openrouter => 'Free tier chat models',
        AiProviderType.together => 'Together AI free tier',
        AiProviderType.groq => 'Fast Groq inference',
      };
}
