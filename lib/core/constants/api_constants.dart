class ApiConstants {
  ApiConstants._();

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);
  // Hugging Face
  static const String huggingFaceBaseUrl =
      'https://api-inference.huggingface.co';
  static const List<String> huggingFaceModels = [
    'google/gemma-4-31b-it',
    'mistralai/Mistral-Small-24B-Instruct-2506',
    'meta-llama/Llama-4-8B-Instruct',
  ];

  // OpenRouter
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const List<String> openRouterModels = [
    'google/gemma-4-31b-it:free',
    'deepseek/deepseek-v4-flash:free',
    'qwen/qwen3-coder:free',
    'openai/gpt-oss-20b:free',
    'nvidia/nemotron-3-ultra-550b-a55b:free',
  ];

  // Together AI
  static const String togetherBaseUrl = 'https://api.together.xyz/v1';
  static const List<String> togetherModels = [
    'meta-llama/Llama-4-70B-Instruct-Turbo',
    'google/gemma-4-27b-it',
    'Qwen/Qwen3-72B-Instruct-Turbo',
  ];

  // Groq
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const List<String> groqModels = [
    'llama-4-70b-versatile',
    'gemma4-31b-it',
    'qwen3-72b-preview',
  ];
}
