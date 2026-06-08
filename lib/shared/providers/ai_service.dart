import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
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

  static const _autoProviderOrder = [
    'groq',
    'openrouter',
    'together',
    'huggingface',
  ];

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

  List<AiProvider> _orderedProviders(AppSettings settings) {
    if (settings.preferredProvider != AiProviderType.auto) {
      final preferred = _providers[settings.preferredProvider.name];
      if (preferred != null) {
        final others =
            _providers.values.where((p) => p.id != preferred.id).toList();
        return [preferred, ...others];
      }
    }

    return _autoProviderOrder
        .map((id) => _providers[id])
        .whereType<AiProvider>()
        .toList();
  }

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

    final providers = _orderedProviders(settings);
    AiProviderException? lastError;
    var attemptedProviders = 0;

    for (var attempt = 0; attempt < AppConstants.maxRetries; attempt++) {
      AppLogger.info('Streaming attempt ${attempt + 1}/${AppConstants.maxRetries} starting.');
      for (final provider in providers) {
        if (cancelToken.isCancelled) {
          AppLogger.info('Streaming cancelled by user.');
          return;
        }

        final apiKey = _apiKeyForProvider(provider, settings);
        if (!provider.isAvailable(apiKey: apiKey)) {
          AppLogger.debug('Provider ${provider.name} is not configured/available. Skipping.');
          continue;
        }

        AppLogger.info('Attempting completion stream using provider: ${provider.name}');
        attemptedProviders++;
        try {
          yield* provider.streamCompletion(
            request,
            apiKey: apiKey,
            cancelToken: cancelToken,
          );
          AppLogger.info('Successfully completed streaming with provider: ${provider.name}');
          return;
        } on AiProviderException catch (e) {
          AppLogger.warning('Provider ${provider.name} failed: ${e.message} (rate-limited: ${e.isRateLimited})');
          lastError = e;
          if (e.isRateLimited) {
            AppLogger.info('Provider rate-limited. Waiting for ${AppConstants.retryDelay.inSeconds}s before next attempt.');
            await Future<void>.delayed(AppConstants.retryDelay);
          }
          AppLogger.info('Switching to next available provider.');
          continue;
        }
      }

      if (attempt < AppConstants.maxRetries - 1) {
        AppLogger.info('Attempt failed. Retrying all providers in ${AppConstants.retryDelay.inSeconds}s.');
        await Future<void>.delayed(AppConstants.retryDelay);
      }
    }

    if (attemptedProviders == 0) {
      AppLogger.error('Failed to stream: No available provider configured with keys.');
      throw AiProviderException(settings.missingApiKeyMessage);
    }

    AppLogger.error('All configured providers failed after ${AppConstants.maxRetries} attempts. Last error: ${lastError?.message}');
    throw lastError ??
        AiProviderException(
          'All configured providers failed. Check your API keys in Settings '
          'or try a different provider.',
        );
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  final dio = ref.watch(dioProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AiService(dio: dio, networkInfo: networkInfo);
});
