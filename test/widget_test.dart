import 'package:flutter_test/flutter_test.dart';

import 'package:test_gen_ui_1/shared/models/app_settings.dart';
import 'package:test_gen_ui_1/shared/models/chat_message.dart';
import 'package:test_gen_ui_1/shared/models/chat_session.dart';

void main() {
  test('AppSettings has sensible defaults', () {
    const settings = AppSettings();
    expect(settings.themeMode, ThemeModeOption.system);
    expect(settings.selectedModelId, 'groq:llama-4-70b-versatile');
    expect(settings.onboardingComplete, false);
  });

  test('ChatSession toJson uses maps for nested messages', () {
    final now = DateTime.utc(2026, 1, 1);
    final session = ChatSession(
      id: 'test-id',
      title: 'Test',
      messages: [
        ChatMessage(
          id: 'msg-1',
          role: MessageRole.user,
          content: 'Hello',
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final json = session.toJson();
    final messages = json['messages'] as List<dynamic>;

    expect(messages, hasLength(1));
    expect(messages.first, isA<Map<String, dynamic>>());
    expect((messages.first as Map)['content'], 'Hello');
  });
}
