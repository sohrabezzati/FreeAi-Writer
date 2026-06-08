class PromptBuilder {
  PromptBuilder._();

  static String buildFromTemplate({
    required String systemPrompt,
    required String userInput,
  }) {
    return '$systemPrompt\n\nUser request: $userInput';
  }

  static List<Map<String, String>> toChatMessages({
    String? systemPrompt,
    required List<({String role, String content})> messages,
  }) {
    final result = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      result.add({'role': 'system', 'content': systemPrompt});
    }

    for (final message in messages) {
      result.add({'role': message.role, 'content': message.content});
    }

    return result;
  }
}
