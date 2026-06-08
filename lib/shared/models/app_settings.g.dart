// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  themeMode:
      $enumDecodeNullable(_$ThemeModeOptionEnumMap, json['themeMode']) ??
      ThemeModeOption.system,
  preferredProvider:
      $enumDecodeNullable(_$AiProviderTypeEnumMap, json['preferredProvider']) ??
      AiProviderType.auto,
  huggingFaceApiKey: json['huggingFaceApiKey'] as String? ?? '',
  openRouterApiKey: json['openRouterApiKey'] as String? ?? '',
  togetherApiKey: json['togetherApiKey'] as String? ?? '',
  groqApiKey: json['groqApiKey'] as String? ?? '',
  onboardingComplete: json['onboardingComplete'] as bool? ?? false,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeOptionEnumMap[instance.themeMode]!,
      'preferredProvider': _$AiProviderTypeEnumMap[instance.preferredProvider]!,
      'huggingFaceApiKey': instance.huggingFaceApiKey,
      'openRouterApiKey': instance.openRouterApiKey,
      'togetherApiKey': instance.togetherApiKey,
      'groqApiKey': instance.groqApiKey,
      'onboardingComplete': instance.onboardingComplete,
    };

const _$ThemeModeOptionEnumMap = {
  ThemeModeOption.system: 'system',
  ThemeModeOption.light: 'light',
  ThemeModeOption.dark: 'dark',
};

const _$AiProviderTypeEnumMap = {
  AiProviderType.auto: 'auto',
  AiProviderType.huggingface: 'huggingface',
  AiProviderType.openrouter: 'openrouter',
  AiProviderType.together: 'together',
  AiProviderType.groq: 'groq',
};
