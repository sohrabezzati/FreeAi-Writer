import '../../shared/models/app_settings.dart';

class FreeAiModel {
  const FreeAiModel({
    required this.id,
    required this.modelId,
    required this.provider,
    required this.displayName,
  });

  final String id;
  final String modelId;
  final AiProviderType provider;
  final String displayName;
}

class FreeModelsCatalog {
  FreeModelsCatalog._();

  static const defaultModelId = 'groq:llama-4-70b-versatile';

  static const List<FreeAiModel> all = [
    // Groq
    FreeAiModel(
      id: 'groq:llama-4-70b-versatile',
      modelId: 'llama-4-70b-versatile',
      provider: AiProviderType.groq,
      displayName: 'Llama 4 70B',
    ),
    FreeAiModel(
      id: 'groq:gemma4-31b-it',
      modelId: 'gemma4-31b-it',
      provider: AiProviderType.groq,
      displayName: 'Gemma 4 31B',
    ),
    FreeAiModel(
      id: 'groq:qwen3-72b-preview',
      modelId: 'qwen3-72b-preview',
      provider: AiProviderType.groq,
      displayName: 'Qwen3 72B',
    ),
    // OpenRouter (free tier)
    FreeAiModel(
      id: 'openrouter:google/gemma-4-31b-it:free',
      modelId: 'google/gemma-4-31b-it:free',
      provider: AiProviderType.openrouter,
      displayName: 'Gemma 4 31B',
    ),
    FreeAiModel(
      id: 'openrouter:deepseek/deepseek-v4-flash:free',
      modelId: 'deepseek/deepseek-v4-flash:free',
      provider: AiProviderType.openrouter,
      displayName: 'DeepSeek V4 Flash',
    ),
    FreeAiModel(
      id: 'openrouter:qwen/qwen3-coder:free',
      modelId: 'qwen/qwen3-coder:free',
      provider: AiProviderType.openrouter,
      displayName: 'Qwen3 Coder',
    ),
    FreeAiModel(
      id: 'openrouter:openai/gpt-oss-20b:free',
      modelId: 'openai/gpt-oss-20b:free',
      provider: AiProviderType.openrouter,
      displayName: 'GPT-OSS 20B',
    ),
    FreeAiModel(
      id: 'openrouter:nvidia/nemotron-3-ultra-550b-a55b:free',
      modelId: 'nvidia/nemotron-3-ultra-550b-a55b:free',
      provider: AiProviderType.openrouter,
      displayName: 'Nemotron 3 Ultra',
    ),
    // Together AI
    FreeAiModel(
      id: 'together:meta-llama/Llama-4-70B-Instruct-Turbo',
      modelId: 'meta-llama/Llama-4-70B-Instruct-Turbo',
      provider: AiProviderType.together,
      displayName: 'Llama 4 70B Instruct',
    ),
    FreeAiModel(
      id: 'together:google/gemma-4-27b-it',
      modelId: 'google/gemma-4-27b-it',
      provider: AiProviderType.together,
      displayName: 'Gemma 4 27B',
    ),
    FreeAiModel(
      id: 'together:Qwen/Qwen3-72B-Instruct-Turbo',
      modelId: 'Qwen/Qwen3-72B-Instruct-Turbo',
      provider: AiProviderType.together,
      displayName: 'Qwen3 72B Instruct',
    ),
    // Hugging Face
    FreeAiModel(
      id: 'huggingface:google/gemma-4-31b-it',
      modelId: 'google/gemma-4-31b-it',
      provider: AiProviderType.huggingface,
      displayName: 'Gemma 4 31B',
    ),
    FreeAiModel(
      id: 'huggingface:mistralai/Mistral-Small-24B-Instruct-2506',
      modelId: 'mistralai/Mistral-Small-24B-Instruct-2506',
      provider: AiProviderType.huggingface,
      displayName: 'Mistral Small 24B',
    ),
    FreeAiModel(
      id: 'huggingface:meta-llama/Llama-4-8B-Instruct',
      modelId: 'meta-llama/Llama-4-8B-Instruct',
      provider: AiProviderType.huggingface,
      displayName: 'Llama 4 8B',
    ),
  ];

  static FreeAiModel get defaultModel =>
      findById(defaultModelId) ?? all.first;

  static FreeAiModel? findById(String id) {
    for (final model in all) {
      if (model.id == id) return model;
    }
    return null;
  }

  static FreeAiModel resolve(String? id) => findById(id ?? '') ?? defaultModel;

  static const _providerOrder = [
    AiProviderType.groq,
    AiProviderType.openrouter,
    AiProviderType.together,
    AiProviderType.huggingface,
  ];

  static List<({AiProviderType provider, List<FreeAiModel> models})>
      get groupedByProvider {
    final groups = <({AiProviderType provider, List<FreeAiModel> models})>[];
    for (final provider in _providerOrder) {
      final models = all.where((model) => model.provider == provider).toList();
      if (models.isNotEmpty) {
        groups.add((provider: provider, models: models));
      }
    }
    return groups;
  }
}

extension FreeAiModelX on FreeAiModel {
  String get labelWithProvider =>
      '$displayName · ${provider.displayName}';

  String get compactLabel => displayName;
}
