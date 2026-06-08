import 'package:freezed_annotation/freezed_annotation.dart';

import 'chat_message.dart';

part 'chat_session.freezed.dart';
part 'chat_session.g.dart';

@freezed
abstract class ChatSession with _$ChatSession {
  @JsonSerializable(explicitToJson: true)
  const factory ChatSession({
    required String id,
    required String title,
    required List<ChatMessage> messages,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? templateId,
    String? systemPrompt,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}
