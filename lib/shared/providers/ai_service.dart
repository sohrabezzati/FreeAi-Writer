import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/free_models.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/logger.dart';
import '../../shared/models/app_settings.dart';
import 'ai_provider.dart';
import 'huggingface_provider.dart';
import 'openrouter_provider.dart';

export 'ai_provider.dart';

class AiService {
  AiService({
    required Dio dio,
    required NetworkInfo networkInfo,
  })  : _networkInfo = networkInfo,
        _providers = {
          'huggingface': HuggingFaceProvider(dio),
          'openrouter': OpenRouterProvider(dio),
          'together': TogetherProvider(dio),
          'groq': GroqProvider(dio),
        };

  final NetworkInfo _networkInfo;
  final Map<String, AiProvider> _providers;

  List<AiProvider> get allProviders => _providers.values.toList();

  AiProvider? getProvider(String id) => _providers[id];

  String _apiKeyForProvider(AiProvider provider, AppSettings settings) {
    return switch (provider.id) {
      'huggingface' => settings.huggingFaceApiKey.trim(),
      'openrouter' => settings.openRouterApiKey.trim(),
      'together' => settings.togetherApiKey.trim(),
      'groq' => settings.groqApiKey.trim(),
      _ => '',
    };
  }

  FreeAiModel _selectedModel(AppSettings settings) =>
      FreeModelsCatalog.resolve(settings.selectedModelId);

  Stream<String> streamWithFallback({
    required AiCompletionRequest request,
    required AppSettings settings,
    required AiCancelToken cancelToken,
  }) async* {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      AppLogger.warning('Streaming failed: No internet connection.');
      throw AiProviderException(
        'No internet connection. Please check your network.',
      );
    }

    if (!settings.hasAnyApiKey) {
      AppLogger.warning('Streaming failed: No API keys configured.');
      throw AiProviderException(settings.missingApiKeyMessage);
    }

    final selectedModel = _selectedModel(settings);
    final provider = getProvider(selectedModel.provider.name);
    if (provider == null) {
      throw AiProviderException(
        'Selected model is not available. Choose another model in Settings.',
      );
    }

    final apiKey = _apiKeyForProvider(provider, settings);
    if (!provider.isAvailable(apiKey: apiKey)) {
      throw AiProviderException(
        '${provider.name} API key required for ${selectedModel.displayName}. '
        'Add it in Settings.',
      );
    }

    final modelRequest = AiCompletionRequest(
      messages: request.messages,
      systemPrompt: request.systemPrompt,
      model: selectedModel.modelId,
      temperature: request.temperature,
      maxTokens: request.maxTokens,
    );

    AiProviderException? lastError;

    for (var attempt = 0; attempt < AppConstants.maxRetries; attempt++) {
      if (cancelToken.isCancelled) {
        AppLogger.info('Streaming cancelled by user.');
        return;
      }

      AppLogger.info(
        'Attempting completion with model: ${selectedModel.modelId} '
        'via ${provider.name} (attempt ${attempt + 1})',
      );

      try {
        await for (final chunk in provider.streamCompletion(
          modelRequest,
          apiKey: apiKey,
          cancelToken: cancelToken,
        )) {
          yield chunk;
        }
        AppLogger.info(
          'Successfully completed streaming with model: ${selectedModel.modelId}',
        );
        return;
      } on AiProviderException catch (e) {
        AppLogger.warning(
          'Model ${selectedModel.modelId} failed: ${e.message} '
          '(rate-limited: ${e.isRateLimited})',
        );
        lastError = e;
        if (e.isRateLimited && attempt < AppConstants.maxRetries - 1) {
          await Future<void>.delayed(AppConstants.retryDelay);
          continue;
        }
        break;
      }
    }

    throw lastError ??
        AiProviderException(
          'Failed to generate a response with ${selectedModel.labelWithProvider}. '
          'Try another model or check your API key.',
        );
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  final dio = ref.watch(dioProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AiService(dio: dio, networkInfo: networkInfo);
});
