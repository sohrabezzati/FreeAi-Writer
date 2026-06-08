import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:test_gen_ui_1/core/constants/app_constants.dart';
import 'package:test_gen_ui_1/shared/models/chat_message.dart';
import 'package:test_gen_ui_1/shared/models/chat_session.dart';
import 'package:test_gen_ui_1/shared/repositories/chat_repository.dart';

void main() {
  late Directory tempDir;
  late ChatRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('chat_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.hiveBoxChats);
    repository = ChatRepository();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('ChatRepository returns empty list when no sessions are stored', () {
    final sessions = repository.getAllSessions();
    expect(sessions, isEmpty);
  });

  test('ChatRepository saves and retrieves a session correctly', () async {
    final now = DateTime.utc(2026, 1, 1);
    final session = ChatSession(
      id: 'session-1',
      title: 'First Session',
      messages: [
        ChatMessage(
          id: 'msg-1',
          role: MessageRole.user,
          content: 'Hello World',
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await repository.saveSession(session);

    final retrieved = repository.getSession('session-1');
    expect(retrieved, isNotNull);
    expect(retrieved!.id, 'session-1');
    expect(retrieved.title, 'First Session');
    expect(retrieved.messages.length, 1);
    expect(retrieved.messages.first.content, 'Hello World');
  });

  test('ChatRepository sorts sessions by updatedAt descending', () async {
    final now = DateTime.utc(2026, 1, 1);
    final session1 = ChatSession(
      id: 'session-1',
      title: 'Older Session',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    final session2 = ChatSession(
      id: 'session-2',
      title: 'Newer Session',
      messages: [],
      createdAt: now,
      updatedAt: now.add(const Duration(hours: 1)),
    );

    await repository.saveSession(session1);
    await repository.saveSession(session2);

    final all = repository.getAllSessions();
    expect(all, hasLength(2));
    expect(all.first.id, 'session-2');
    expect(all.last.id, 'session-1');
  });

  test('ChatRepository limits maximum stored chats and prunes oldest', () async {
    final now = DateTime.utc(2026, 1, 1);
    
    // Save maxStoredChats + 5 sessions
    for (var i = 0; i < AppConstants.maxStoredChats + 5; i++) {
      final session = ChatSession(
        id: 'session-$i',
        title: 'Session $i',
        messages: [],
        createdAt: now,
        updatedAt: now.add(Duration(minutes: i)),
      );
      await repository.saveSession(session);
    }

    final all = repository.getAllSessions();
    expect(all.length, AppConstants.maxStoredChats);
    // The oldest 5 sessions (session-0 to session-4) should be pruned
    final ids = all.map((s) => s.id).toList();
    for (var i = 0; i < 5; i++) {
      expect(ids.contains('session-$i'), isFalse);
    }
    // The newest session should be present
    expect(ids.contains('session-${AppConstants.maxStoredChats + 4}'), isTrue);
  });
}
