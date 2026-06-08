class AppConstants {
  AppConstants._();

  static const String appName = 'FreeAI Writer';
  static const String appTagline = 'Write smarter with free AI';
  static const String hiveBoxSettings = 'settings_box';
  static const String hiveBoxChats = 'chats_box';
  static const String hiveKeySettings = 'app_settings';
  static const String hiveKeyOnboardingComplete = 'onboarding_complete';
  static const int maxRecentChats = 10;
  static const int maxStoredChats = 100;
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;
}
