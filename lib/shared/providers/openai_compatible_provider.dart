import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;

import 'ai_provider.dart';

abstract class OpenAiCompatibleProvider implements AiProvider {
  OpenAiCompatibleProvider(this._dio);

  final dio.Dio _dio;

  String get baseUrl;
  Map<String, String> extraHeaders(String apiKey);

  @override
  bool get requiresApiKey => true;

  @override
  bool isAvailable({required String apiKey}) => apiKey.isNotEmpty;

  @override
  Stream<String> streamCompletion(
    AiCompletionRequest request, {
    required String apiKey,
    required AiCancelToken cancelToken,
  }) async* {
    if (!isAvailable(apiKey: apiKey)) {
      throw AiProviderException('$name API key required. Add it in Settings.');
    }

    final model = request.model ?? defaultModels.first;

    try {
      final response = await _dio.post<dio.ResponseBody>(
        '$baseUrl/chat/completions',
        data: {
          'model': model,
          'messages': request.toApiMessages(),
          'temperature': request.temperature,
          'max_tokens': request.maxTokens,
          'stream': true,
        },
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            ...extraHeaders(apiKey),
          },
          responseType: dio.ResponseType.stream,
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw AiProviderException('No stream received from $name');
      }

      final lineStream = stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        if (cancelToken.isCancelled) return;
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (!trimmed.startsWith('data: ')) continue;
        final data = trimmed.substring(6).trim();
        if (data == '[DONE]') return;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;

          final delta = choices.first['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            yield content;
          }
        } catch (_) {
          continue;
        }
      }
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AiProviderException _handleDioError(dio.DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return AiProviderException(
        '$name API key is invalid. Check your key in Settings.',
        statusCode: status,
      );
    }
    if (status == 429) {
      return AiProviderException(
        '$name rate limit reached',
        statusCode: status,
        isRateLimited: true,
      );
    }
    final message =
        e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    return AiProviderException('$name error: $message', statusCode: status);
  }
}
