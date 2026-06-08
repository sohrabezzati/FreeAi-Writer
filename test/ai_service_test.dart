import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:test_gen_ui_1/core/network/network_info.dart';
import 'package:test_gen_ui_1/shared/models/app_settings.dart';
import 'package:test_gen_ui_1/shared/providers/ai_provider.dart';
import 'package:test_gen_ui_1/shared/providers/ai_service.dart';

class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({required this.connected});
  final bool connected;

  @override
  Future<bool> get isConnected => Future.value(connected);

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(connected);
}

class FakeAiProvider implements AiProvider {
  FakeAiProvider(this.id, this.name, {required this.shouldSucceed, this.errorMessage = ''});

  @override
  final String id;
  @override
  final String name;
  @override
  bool get requiresApiKey => true;
  @override
  List<String> get defaultModels => ['mock-model'];

  final bool shouldSucceed;
  final String errorMessage;

  @override
  bool isAvailable({required String apiKey}) => apiKey.isNotEmpty;

  @override
  Stream<String> streamCompletion(
    AiCompletionRequest request, {
    required String apiKey,
    required AiCancelToken cancelToken,
  }) async* {
    if (!shouldSucceed) {
      throw AiProviderException(errorMessage);
    }
    yield 'Hello';
    yield ' ';
    yield 'World';
  }
}

// Test-specific subclass of AiService to inject fake providers
class TestAiService extends AiService {
  TestAiService({
    required NetworkInfo networkInfo,
    required List<AiProvider> mockProviders,
  })  : _mockProviders = {for (var p in mockProviders) p.id: p},
        super(dio: Dio(), networkInfo: networkInfo);

  final Map<String, AiProvider> _mockProviders;

  @override
  AiProvider? getProvider(String id) => _mockProviders[id];

  @override
  List<AiProvider> get allProviders => _mockProviders.values.toList();
}

void main() {
  test('AiService streamWithFallback throws when offline', () async {
    final networkInfo = FakeNetworkInfo(connected: false);
    final service = TestAiService(networkInfo: networkInfo, mockProviders: []);

    expect(
      () => service.streamWithFallback(
        request: const AiCompletionRequest(messages: []),
        settings: const AppSettings(groqApiKey: 'gsk_test'),
        cancelToken: AiCancelToken(),
      ).toList(),
      throwsA(isA<AiProviderException>().having(
        (e) => e.message,
        'message',
        contains('No internet connection'),
      )),
    );
  });

  test('AiService streamWithFallback yields chunks from successful provider', () async {
    final networkInfo = FakeNetworkInfo(connected: true);
    final provider = FakeAiProvider('groq', 'Groq', shouldSucceed: true);
    final service = TestAiService(networkInfo: networkInfo, mockProviders: [provider]);

    final chunks = await service.streamWithFallback(
      request: const AiCompletionRequest(messages: []),
      settings: const AppSettings(groqApiKey: 'gsk_test'),
      cancelToken: AiCancelToken(),
    ).toList();

    expect(chunks, ['Hello', ' ', 'World']);
  });

  test('AiService streamWithFallback switches provider on failure', () async {
    final networkInfo = FakeNetworkInfo(connected: true);
    final failingProvider = FakeAiProvider('groq', 'Groq', shouldSucceed: false, errorMessage: 'Rate limit');
    final successProvider = FakeAiProvider('openrouter', 'OpenRouter', shouldSucceed: true);
    
    final service = TestAiService(
      networkInfo: networkInfo,
      mockProviders: [failingProvider, successProvider],
    );

    // Groq is preferred/auto first, will fail, then falls back to OpenRouter.
    final chunks = await service.streamWithFallback(
      request: const AiCompletionRequest(messages: []),
      settings: const AppSettings(
        groqApiKey: 'gsk_test',
        openRouterApiKey: 'sk_test',
      ),
      cancelToken: AiCancelToken(),
    ).toList();

    expect(chunks, ['Hello', ' ', 'World']);
  });
}
