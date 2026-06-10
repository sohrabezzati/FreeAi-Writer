import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genai_primitives/genai_primitives.dart' as genai;
import 'package:genui/genui.dart' as genui;
import 'package:genui/genui.dart' hide ChatMessage;
import 'package:uuid/uuid.dart';

import '../../../core/genui/genui.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/models/chat_message.dart';
import '../../../shared/models/chat_session.dart';

import '../../../shared/providers/ai_service.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/repositories/chat_repository.dart';

class ChatState {
  const ChatState({this.session, this.isGenerating = false, this.error});

  final ChatSession? session;
  final bool isGenerating;
  final String? error;

  ChatState copyWith({
    ChatSession? session,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      session: session ?? this.session,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final _uuid = const Uuid();
  AiCancelToken? _cancelToken;

  late ChatRepository _repository;
  late AiService _aiService;
  late SurfaceController _surfaceController;
  late PromptBuilder _promptBuilder;

  genui.A2uiTransportAdapter? _genUiTransport;
  genui.Conversation? _genUiConversation;
  StreamSubscription<genui.ConversationEvent>? _genUiEventsSub;
  String? _pendingAssistantId;
  String? _pendingSurfaceId;

  @override
  ChatState build() {
    _repository = ref.watch(chatRepositoryProvider);
    _aiService = ref.watch(aiServiceProvider);
    _surfaceController = ref.watch(surfaceControllerProvider);
    _promptBuilder = ref.watch(promptBuilderProvider);

    _ensureGenUi();

    ref.onDispose(() {
      _cancelToken?.cancel();
      _disposeGenUi();
    });

    return const ChatState();
  }

  void _ensureGenUi() {
    if (_genUiConversation != null) return;

    _genUiTransport = genui.A2uiTransportAdapter(onSend: _handleGenUiSend);
    _genUiConversation = genui.Conversation(
      controller: _surfaceController,
      transport: _genUiTransport!,
    );
    _genUiEventsSub = _genUiConversation!.events.listen((event) {
      if (event is genui.ConversationSurfaceAdded) {
        AppLogger.info(
          'GenUI surface added: ${event.surfaceId}',
        );
        _pendingSurfaceId = event.surfaceId;
        _applySurfaceToPendingAssistant();
      }
    });
  }

  void _disposeGenUi() {
    _genUiEventsSub?.cancel();
    _genUiConversation?.dispose();
    _genUiTransport?.dispose();
    _genUiConversation = null;
    _genUiTransport = null;
  }

  void _applySurfaceToPendingAssistant() {
    final assistantId = _pendingAssistantId;
    final surfaceId = _pendingSurfaceId;
    final session = state.session;
    if (assistantId == null || surfaceId == null || session == null) return;

    final updatedMessages = session.messages.map((message) {
      if (message.id == assistantId) {
        return message.copyWith(surfaceId: surfaceId);
      }
      return message;
    }).toList();

    state = ChatState(
      session: session.copyWith(messages: updatedMessages),
      isGenerating: state.isGenerating,
    );
  }

  Future<void> _handleGenUiSend(genai.ChatMessage message) async {
    final isInteraction = message.parts.any((part) => part.isUiInteractionPart);

    if (isInteraction) {
      if (state.isGenerating) {
        AppLogger.warning('Ignoring UI action while a response is generating.');
        return;
      }

      var session = state.session;
      if (session == null) {
        await createSession();
        session = state.session!;
      }

      final userMessage = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.user,
        content: _formatGenUiInteraction(message),
        createdAt: DateTime.now(),
      );
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.assistant,
        content: '',
        status: MessageStatus.streaming,
        createdAt: DateTime.now(),
      );

      session = session.copyWith(
        messages: [...session.messages, userMessage, assistantMessage],
        updatedAt: DateTime.now(),
      );
      _pendingAssistantId = assistantMessage.id;
      _pendingSurfaceId = null;
      state = state.copyWith(
        session: session,
        isGenerating: true,
        clearError: true,
      );
      await _repository.saveSession(session);
    } else if (_pendingAssistantId == null) {
      AppLogger.warning('GenUI text request received without a pending assistant.');
      return;
    }

    final session = state.session;
    if (session == null) return;

    await _streamAssistantResponse(session);
  }

  void loadSession(String sessionId) {
    final session = _repository.getSession(sessionId);
    state = ChatState(session: session);
  }

  Future<void> createSession({
    String? templateId,
    String? systemPrompt,
    String? initialTitle,
  }) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: _uuid.v4(),
      title: initialTitle ?? 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
      templateId: templateId,
      systemPrompt: systemPrompt,
    );
    state = ChatState(session: session);
    await _repository.saveSession(session);
  }

  Future<void> sendMessage(String content) async {
    AppLogger.info(
      'sendMessage: Starting message generation. Content: "${_truncate(content, 30)}"',
    );
    if (content.trim().isEmpty || state.isGenerating) {
      AppLogger.warning('sendMessage: Aborted (empty content or already generating)');
      return;
    }

    var session = state.session;
    if (session == null) {
      AppLogger.info('sendMessage: No active session. Creating a new one...');
      await createSession();
      session = state.session!;
    }

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      status: MessageStatus.streaming,
      createdAt: DateTime.now(),
    );

    var updatedMessages = [...session.messages, userMessage, assistantMessage];
    var title = session.title;
    if (session.messages.isEmpty) {
      title = _truncate(content.trim(), 40);
    }

    session = session.copyWith(
      messages: updatedMessages,
      title: title,
      updatedAt: DateTime.now(),
    );

    _pendingAssistantId = assistantMessage.id;
    _pendingSurfaceId = null;
    state = state.copyWith(
      session: session,
      isGenerating: true,
      clearError: true,
    );
    await _repository.saveSession(session);

    _ensureGenUi();
    await _genUiConversation!.sendRequest(
      genai.ChatMessage.user(content.trim()),
    );
  }

  Future<void> _streamAssistantResponse(ChatSession session) async {
    final assistantId = _pendingAssistantId;
    if (assistantId == null) return;

    final transport = _genUiTransport;
    if (transport == null) return;

    _cancelToken = AiCancelToken();
    final settings = ref.read(settingsProvider);
    var updatedMessages = List<ChatMessage>.from(session.messages);
    var currentSession = session;

    try {
      final baseSystemPrompt = currentSession.systemPrompt ?? '';
      final genUiSystemPrompt = _promptBuilder.systemPrompt().join('\n');
      final finalSystemPrompt = baseSystemPrompt.isEmpty
          ? genUiSystemPrompt
          : '$baseSystemPrompt\n\n$genUiSystemPrompt';

      final request = AiCompletionRequest(
        messages: updatedMessages
            .where((message) => message.id != assistantId)
            .toList(),
        systemPrompt: finalSystemPrompt,
      );

      var accumulatedRawText = '';
      AppLogger.info('sendMessage: Starting stream from selected model...');
      await for (final chunk in _aiService.streamWithFallback(
        request: request,
        settings: settings,
        cancelToken: _cancelToken!,
      )) {
        accumulatedRawText += chunk;
        transport.addChunk(chunk);

        updatedMessages = updatedMessages.map((message) {
          if (message.id == assistantId) {
            final displayContent = _sanitize(accumulatedRawText);
            return message.copyWith(
              content: displayContent.isEmpty ? '...' : displayContent,
              surfaceId: _pendingSurfaceId ?? message.surfaceId,
            );
          }
          return message;
        }).toList();

        currentSession = currentSession.copyWith(
          messages: updatedMessages,
          updatedAt: DateTime.now(),
        );
        state = ChatState(session: currentSession, isGenerating: true);
      }

      AppLogger.info('sendMessage: Stream completed successfully.');
      updatedMessages = updatedMessages.map((message) {
        if (message.id == assistantId) {
          final finalContent = _sanitize(accumulatedRawText);
          return message.copyWith(
            content: finalContent,
            status: MessageStatus.completed,
            surfaceId: _pendingSurfaceId ?? message.surfaceId,
          );
        }
        return message;
      }).toList();

      currentSession = currentSession.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      state = ChatState(session: currentSession, isGenerating: false);
      await _repository.saveSession(currentSession);
    } on AiProviderException catch (e, stack) {
      AppLogger.warning('sendMessage: AI provider failed: ${e.message}', e, stack);
      updatedMessages =
          updatedMessages.where((message) => message.id != assistantId).toList();
      currentSession = currentSession.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
      state = ChatState(
        session: currentSession,
        isGenerating: false,
        error: e.message,
      );
      await _repository.saveSession(currentSession);
    } catch (e, stack) {
      AppLogger.error('sendMessage: Unexpected error: $e', e, stack);
      state = state.copyWith(
        isGenerating: false,
        error: 'Something went wrong: $e',
      );
    } finally {
      AppLogger.debug('sendMessage: Cleaning up generation resources.');
      _cancelToken = null;
      _pendingAssistantId = null;
    }
  }

  Future<void> regenerateLastResponse() async {
    final session = state.session;
    if (session == null || session.messages.isEmpty || state.isGenerating) {
      return;
    }

    var messages = List<ChatMessage>.from(session.messages);
    if (messages.last.role == MessageRole.assistant) {
      messages.removeLast();
    }
    if (messages.isEmpty) return;

    final lastUser = messages.last;
    if (lastUser.role != MessageRole.user) return;

    final updatedSession = session.copyWith(
      messages: messages.sublist(0, messages.length - 1),
      updatedAt: DateTime.now(),
    );
    state = ChatState(session: updatedSession);
    await _repository.saveSession(updatedSession);
    await sendMessage(lastUser.content);
  }

  void stopGeneration() {
    _cancelToken?.cancel();
    final session = state.session;
    if (session == null) return;

    final messages = session.messages.map((message) {
      if (message.status == MessageStatus.streaming) {
        return message.copyWith(
          status: MessageStatus.completed,
          content: message.content.isEmpty ? '(Stopped)' : message.content,
        );
      }
      return message;
    }).toList();

    final updated = session.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
    state = ChatState(session: updated, isGenerating: false);
    _pendingAssistantId = null;
    _repository.saveSession(updated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
    if (state.session?.id == sessionId) {
      state = ChatState();
    } else {
      state = ChatState(
        session: state.session,
        isGenerating: state.isGenerating,
        error: state.error,
      );
    }
  }

  Future<void> clearHistory() async {
    await _repository.clearAll();
    state = ChatState();
  }

  String _formatGenUiInteraction(genai.ChatMessage message) {
    final interaction = message.parts.uiInteractionParts.firstOrNull;
    if (interaction == null) {
      return message.text.isNotEmpty ? message.text : 'User UI interaction';
    }

    try {
      final decoded = jsonDecode(interaction.interaction) as Map<String, dynamic>;
      final action = decoded['action'] as Map<String, dynamic>?;
      if (action != null) {
        final name = action['name'] as String? ?? 'action';
        final context = action['context'] as Map<String, dynamic>? ?? {};
        if (context.isEmpty) return 'User action: $name';
        return 'User action: $name (${jsonEncode(context)})';
      }
    } catch (_) {
      // Fall through to generic label.
    }

    return 'User UI interaction';
  }

  String _sanitize(String text) {
    if (text.isEmpty) return '';

    const marker = '---a2ui_JSON---';

    if (text.contains(marker) || (text.length >= 3 && marker.startsWith(text))) {
      return '';
    }

    var result = text;
    for (var i = marker.length - 1; i > 0; i--) {
      final partial = marker.substring(0, i);
      if (result.endsWith(partial)) {
        result = result.substring(0, result.length - i);
        break;
      }
    }

    return result;
  }

  String _truncate(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...';
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

final chatSessionsProvider = Provider<List<ChatSession>>((ref) {
  ref.watch(chatProvider);
  return ref.watch(chatRepositoryProvider).getAllSessions();
});

final recentChatSessionsProvider = Provider<List<ChatSession>>((ref) {
  ref.watch(chatProvider);
  return ref.watch(chatRepositoryProvider).getRecentSessions();
});
