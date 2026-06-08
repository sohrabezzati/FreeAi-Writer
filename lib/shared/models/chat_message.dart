import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('streaming')
  streaming,
  @JsonValue('completed')
  completed,
  @JsonValue('error')
  error,
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageRole role,
    required String content,
    @Default(MessageStatus.completed) MessageStatus status,
    DateTime? createdAt,
    String? errorMessage,
    String? surfaceId,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
