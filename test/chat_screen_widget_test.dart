import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:test_gen_ui_1/core/constants/app_constants.dart';
import 'package:test_gen_ui_1/core/network/network_info.dart';
import 'package:test_gen_ui_1/features/chat/chat_screen.dart';
import 'package:test_gen_ui_1/features/chat/providers/chat_provider.dart';
import 'package:test_gen_ui_1/shared/models/app_settings.dart';
import 'package:test_gen_ui_1/shared/models/chat_session.dart';
import 'package:test_gen_ui_1/shared/providers/settings_provider.dart';

// Riverpod Notifier Mocks
class MockSettingsNotifier extends SettingsNotifier {
  MockSettingsNotifier(this.initialSettings);
  final AppSettings initialSettings;

  @override
  AppSettings build() {
    return initialSettings;
  }
}

class MockChatNotifier extends ChatNotifier {
  MockChatNotifier(this.initialState);
  final ChatState initialState;

  @override
  ChatState build() {
    return initialState;
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('widget_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.hiveBoxSettings);
    await Hive.openBox(AppConstants.hiveBoxChats);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('ChatScreen shows onboarding warning banner when API key is missing', (WidgetTester tester) async {
    final now = DateTime.utc(2026, 1, 1);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(() => MockSettingsNotifier(
            const AppSettings(
              huggingFaceApiKey: '',
              groqApiKey: '',
              onboardingComplete: true,
            ),
          )),
          chatProvider.overrideWith(() => MockChatNotifier(
            ChatState(
              session: ChatSession(
                id: 'test-session',
                title: 'New Chat',
                messages: [],
                createdAt: now,
                updatedAt: now,
              ),
            ),
          )),
          isOnlineProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(
          home: TickerMode(
            enabled: false,
            child: ChatScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify "Start a conversation" empty state is shown
    expect(find.text('Start a conversation'), findsOneWidget);
    
    // Verify warning text is displayed
    expect(find.textContaining('Add a free Groq API key in Settings'), findsOneWidget);

    // Unmount ChatScreen to clean up animations/tickers/timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('ChatScreen displays error banner when chatState has error', (WidgetTester tester) async {
    final now = DateTime.utc(2026, 1, 1);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(() => MockSettingsNotifier(
            const AppSettings(
              groqApiKey: 'gsk_test',
              onboardingComplete: true,
            ),
          )),
          chatProvider.overrideWith(() => MockChatNotifier(
            ChatState(
              error: 'Rate limit exceeded on Groq',
              session: ChatSession(
                id: 'test-session',
                title: 'New Chat',
                messages: [],
                createdAt: now,
                updatedAt: now,
              ),
            ),
          )),
          isOnlineProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(
          home: TickerMode(
            enabled: false,
            child: ChatScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify MaterialBanner displays the error message
    expect(find.text('Rate limit exceeded on Groq'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);

    // Unmount ChatScreen to clean up animations/tickers/timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
