import 'dart:async';

import 'package:dio/dio.dart' as dio;

import '../../core/constants/api_constants.dart';
import '../../shared/models/chat_message.dart';
import 'ai_provider.dart';

class HuggingFaceProvider implements AiProvider {
  HuggingFaceProvider(this._dio);

  final dio.Dio _dio;

  @override
  String get id => 'huggingface';

  @override
  String get name => 'Hugging Face';

  @override
  bool get requiresApiKey => true;

  @override
  List<String> get defaultModels => ApiConstants.huggingFaceModels;

  @override
  bool isAvailable({required String apiKey}) => apiKey.isNotEmpty;

  @override
  Stream<String> streamCompletion(
    AiCompletionRequest request, {
    required String apiKey,
    required AiCancelToken cancelToken,
  }) async* {
    if (!isAvailable(apiKey: apiKey)) {
      throw AiProviderException(
        'Hugging Face API key required. Add it in Settings.',
      );
    }

    final model = request.model ?? defaultModels.first;
    final prompt = _buildPrompt(request);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConstants.huggingFaceBaseUrl}/models/$model',
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': request.maxTokens,
            'temperature': request.temperature,
            'return_full_text': false,
          },
          'options': {'wait_for_model': true},
        },
        options: dio.Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      if (cancelToken.isCancelled) return;

      final text = _extractText(response.data);
      if (text.isEmpty) {
        throw AiProviderException('Empty response from Hugging Face');
      }

      yield* _simulateStream(text, cancelToken);
    } on dio.DioException catch (e) {
      throw _handleDioError(e, 'Hugging Face');
    }
  }

  String _buildPrompt(AiCompletionRequest request) {
    final buffer = StringBuffer();
    if (request.systemPrompt != null) {
      buffer.writeln('System: ${request.systemPrompt}');
    }
    for (final msg in request.messages) {
      final role = msg.role == MessageRole.user ? 'User' : 'Assistant';
      buffer.writeln('$role: ${msg.content}');
    }
    buffer.write('Assistant:');
    return buffer.toString();
  }

  String _extractText(Map<String, dynamic>? data) {
    if (data == null) return '';
    if (data.containsKey('generated_text')) {
      return data['generated_text'] as String? ?? '';
    }
    return data.toString();
  }

  Stream<String> _simulateStream(String text, AiCancelToken token) async* {
    const chunkSize = 8;
    for (var i = 0; i < text.length; i += chunkSize) {
      if (token.isCancelled) return;
      final end = (i + chunkSize).clamp(0, text.length);
      yield text.substring(i, end);
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
  }

  AiProviderException _handleDioError(dio.DioException e, String provider) {
    final status = e.response?.statusCode;
    if (status == 429) {
      return AiProviderException(
        '$provider rate limit reached',
        statusCode: status,
        isRateLimited: true,
      );
    }
    final message =
        e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    return AiProviderException('$provider error: $message', statusCode: status);
  }
}
