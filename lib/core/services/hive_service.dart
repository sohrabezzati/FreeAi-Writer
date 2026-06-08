import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../shared/models/chat_message.dart';
import '../../shared/models/chat_session.dart';

class HiveService {
  static Future<void> init() async {
    try {
      AppLogger.info('Initializing Hive storage...');
      await Hive.initFlutter();
      await Hive.openBox(AppConstants.hiveBoxSettings);
      await Hive.openBox(AppConstants.hiveBoxChats);
      AppLogger.info('Hive boxes opened. Running migrations...');
      await _migrateSettingsBox();
      await _migrateChatsBox();
      AppLogger.info('Hive initialization and migration complete.');
    } catch (e, stack) {
      AppLogger.error('Hive initialization failed: $e', e, stack);
      rethrow;
    }
  }

  static Future<void> _migrateSettingsBox() async {
    try {
      final data = settingsBox.get(AppConstants.hiveKeySettings);
      if (data is Map) {
        AppLogger.info('Migrating settings box from legacy Map format...');
        await settingsBox.put(
          AppConstants.hiveKeySettings,
          jsonEncode(Map<String, dynamic>.from(data)),
        );
      }
    } catch (e, stack) {
      AppLogger.warning('Settings box migration failed, deleting corrupt settings key: $e', e, stack);
      await settingsBox.delete(AppConstants.hiveKeySettings);
    }
  }

  /// Converts legacy Map entries to JSON strings and removes corrupt data.
  static Future<void> _migrateChatsBox() async {
    final box = chatsBox;
    for (final key in box.keys.toList()) {
      final value = box.get(key);
      if (value is String) continue;

      if (value is Map) {
        try {
          AppLogger.info('Migrating chat session $key from legacy Map format...');
          final session = ChatSession.fromJson(_normalizeSessionMap(value));
          await box.put(key, jsonEncode(_sessionToMap(session)));
        } catch (e, stack) {
          AppLogger.warning('Chat session migration failed for key $key, deleting entry: $e', e, stack);
          await box.delete(key);
        }
        continue;
      }

      AppLogger.warning('Unknown stored chat data type for key $key, deleting entry.');
      await box.delete(key);
    }
  }

  static Map<String, dynamic> _normalizeSessionMap(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final messages = map['messages'];
    if (messages is List) {
      map['messages'] = messages
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    return map;
  }

  static Map<String, dynamic> _sessionToMap(ChatSession session) {
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

  static Map<String, dynamic> _messageToMap(ChatMessage message) {
    return {
      'id': message.id,
      'role': message.role.name,
      'content': message.content,
      'status': message.status.name,
      'createdAt': message.createdAt?.toIso8601String(),
      'errorMessage': message.errorMessage,
    };
  }

  static Box get settingsBox => Hive.box(AppConstants.hiveBoxSettings);
  static Box get chatsBox => Hive.box(AppConstants.hiveBoxChats);
}

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
