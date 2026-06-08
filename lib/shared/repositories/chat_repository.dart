import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatRepository {
  ChatRepository();

  Map<String, dynamic> _sessionToMap(ChatSession session) {
    return {
      'id': session.id,
      'title': session.title,
      'messages': session.messages.map(_messageToMap).toList(),
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
      'templateId': session.templateId,
      'systemPrompt': session.systemPrompt,
    };
  }

  Map<String, dynamic> _messageToMap(ChatMessage message) {
    return {
      'id': message.id,
      'role': message.role.name,
      'content': message.content,
      'status': message.status.name,
      'createdAt': message.createdAt?.toIso8601String(),
      'errorMessage': message.errorMessage,
    };
  }

  ChatSession? _parseStoredValue(dynamic data) {
    if (data == null) return null;

    try {
      if (data is String) {
        return ChatSession.fromJson(
          jsonDecode(data) as Map<String, dynamic>,
        );
      }

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final messages = map['messages'];
        if (messages is List) {
          map['messages'] = messages
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
        }
        return ChatSession.fromJson(map);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  List<ChatSession> getAllSessions() {
    final sessions = <ChatSession>[];
    for (final key in HiveService.chatsBox.keys) {
      final session = _parseStoredValue(HiveService.chatsBox.get(key));
      if (session != null) {
        sessions.add(session);
      }
    }
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  ChatSession? getSession(String id) {
    return _parseStoredValue(HiveService.chatsBox.get(id));
  }

  Future<void> saveSession(ChatSession session) async {
    await HiveService.chatsBox.put(
      session.id,
      jsonEncode(_sessionToMap(session)),
    );

    final all = getAllSessions();
    if (all.length > AppConstants.maxStoredChats) {
      for (final old in all.sublist(AppConstants.maxStoredChats)) {
        await HiveService.chatsBox.delete(old.id);
      }
    }
  }

  Future<void> deleteSession(String id) async {
    await HiveService.chatsBox.delete(id);
  }

  Future<void> clearAll() async {
    await HiveService.chatsBox.clear();
  }

  List<ChatSession> getRecentSessions({
    int limit = AppConstants.maxRecentChats,
  }) {
    return getAllSessions().take(limit).toList();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});
