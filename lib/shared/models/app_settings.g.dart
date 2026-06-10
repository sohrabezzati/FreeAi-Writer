// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  themeMode:
      $enumDecodeNullable(_$ThemeModeOptionEnumMap, json['themeMode']) ??
      ThemeModeOption.system,
  selectedModelId:
      json['selectedModelId'] as String? ?? 'groq:llama-4-70b-versatile',
  huggingFaceApiKey: json['huggingFaceApiKey'] as String? ?? '',
  openRouterApiKey: json['openRouterApiKey'] as String? ?? '',
  togetherApiKey: json['togetherApiKey'] as String? ?? '',
  groqApiKey: json['groqApiKey'] as String? ?? '',
  onboardingComplete: json['onboardingComplete'] as bool? ?? false,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeOptionEnumMap[instance.themeMode]!,
      'selectedModelId': instance.selectedModelId,
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
