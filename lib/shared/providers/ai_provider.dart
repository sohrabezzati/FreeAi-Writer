import '../../shared/models/chat_message.dart';

class AiCompletionRequest {
  const AiCompletionRequest({
    required this.messages,
    this.systemPrompt,
    this.model,
    this.temperature = 0.7,
    this.maxTokens = 2048,
  });

  final List<ChatMessage> messages;
  final String? systemPrompt;
  final String? model;
  final double temperature;
  final int maxTokens;

  List<Map<String, String>> toApiMessages() {
    final apiMessages = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt!.isNotEmpty) {
      apiMessages.add({'role': 'system', 'content': systemPrompt!});
    }

    for (final msg in messages) {
      if (msg.role == MessageRole.system) continue;
      apiMessages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    return apiMessages;
  }
}

class AiProviderException implements Exception {
  AiProviderException(this.message, {this.statusCode, this.isRateLimited = false});

  final String message;
  final int? statusCode;
  final bool isRateLimited;

  @override
  String toString() => message;
}

abstract class AiProvider {
  String get id;
  String get name;
  bool get requiresApiKey;
  List<String> get defaultModels;

  bool isAvailable({required String apiKey});

  Stream<String> streamCompletion(
    AiCompletionRequest request, {
    required String apiKey,
    required AiCancelToken cancelToken,
  });
}

class AiCancelToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() => _isCancelled = true;
}
