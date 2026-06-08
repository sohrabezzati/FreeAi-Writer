import '../../core/constants/api_constants.dart';
import 'openai_compatible_provider.dart';

class OpenRouterProvider extends OpenAiCompatibleProvider {
  OpenRouterProvider(super.dio);

  @override
  String get id => 'openrouter';

  @override
  String get name => 'OpenRouter';

  @override
  List<String> get defaultModels => ApiConstants.openRouterModels;

  @override
  String get baseUrl => ApiConstants.openRouterBaseUrl;

  @override
  Map<String, String> extraHeaders(String apiKey) => {
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://freeaiwriter.app',
        'X-Title': 'FreeAI Writer',
      };
}

class TogetherProvider extends OpenAiCompatibleProvider {
  TogetherProvider(super.dio);

  @override
  String get id => 'together';

  @override
  String get name => 'Together AI';

  @override
  List<String> get defaultModels => ApiConstants.togetherModels;

  @override
  String get baseUrl => ApiConstants.togetherBaseUrl;

  @override
  Map<String, String> extraHeaders(String apiKey) => {
        'Authorization': 'Bearer $apiKey',
      };
}

class GroqProvider extends OpenAiCompatibleProvider {
  GroqProvider(super.dio);

  @override
  String get id => 'groq';

  @override
  String get name => 'Groq';

  @override
  List<String> get defaultModels => ApiConstants.groqModels;

  @override
  String get baseUrl => ApiConstants.groqBaseUrl;

  @override
  Map<String, String> extraHeaders(String apiKey) => {
        'Authorization': 'Bearer $apiKey',
      };
}
