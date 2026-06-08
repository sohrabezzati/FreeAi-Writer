import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  ChatState build() {
    _repository = ref.watch(chatRepositoryProvider);
    _aiService = ref.watch(aiServiceProvider);
    _surfaceController = ref.watch(surfaceControllerProvider);
    _promptBuilder = ref.watch(promptBuilderProvider);

    ref.onDispose(() {
      _cancelToken?.cancel();
    });

    return const ChatState();
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
    AppLogger.info('sendMessage: Starting message generation. Content: "${_truncate(content, 30)}"');
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

    state = ChatState(session: session, isGenerating: true);
    await _repository.saveSession(session);

    _cancelToken = AiCancelToken();
    final settings = ref.read(settingsProvider);
    final assistantId = assistantMessage.id;
    var currentSession = session;

    // GenUI Integration using Conversation facade
    final transport = A2uiTransportAdapter(onSend: (_) async {});
    final conversation = Conversation(
      controller: _surfaceController,
      transport: transport,
    );

    String? detectedSurfaceId;
    final eventSubscription = conversation.events.listen((event) {
      if (event is ConversationSurfaceAdded) {
        AppLogger.info('sendMessage: GenUI Conversation surface added: ${event.surfaceId}');
        detectedSurfaceId = event.surfaceId as String?;
      }
    });

    try {
      // Combine custom system prompt with GenUI fragments
      final baseSystemPrompt = currentSession.systemPrompt ?? '';
      final genUiSystemPrompt = _promptBuilder.systemPrompt().join('\n');
      final finalSystemPrompt = baseSystemPrompt.isEmpty
          ? genUiSystemPrompt
          : '$baseSystemPrompt\n\n$genUiSystemPrompt';

      final request = AiCompletionRequest(
        messages: updatedMessages
            .where((m) => m.id != assistantId)
            .toList(),
        systemPrompt: finalSystemPrompt,
      );

      var accumulatedRawText = '';
      AppLogger.info('sendMessage: Starting stream from fallback providers...');
      await for (final chunk in _aiService.streamWithFallback(
        request: request,
        settings: settings,
        cancelToken: _cancelToken!,
      )) {
        accumulatedRawText += chunk;
        transport.addChunk(chunk);

        updatedMessages = updatedMessages.map((m) {
          if (m.id == assistantId) {
            final displayContent = _sanitize(accumulatedRawText);
            return m.copyWith(
              content: displayContent.isEmpty ? '...' : displayContent,
              surfaceId: detectedSurfaceId,
            );
          }
          return m;
        }).toList();

        currentSession = currentSession.copyWith(
          messages: updatedMessages,
          updatedAt: DateTime.now(),
        );
        state = ChatState(session: currentSession, isGenerating: true);
      }

      AppLogger.info('sendMessage: Stream completed successfully.');
      updatedMessages = updatedMessages.map((m) {
        if (m.id == assistantId) {
          final finalContent = _sanitize(accumulatedRawText);
          return m.copyWith(
            content: finalContent,
            status: MessageStatus.completed,
            surfaceId: detectedSurfaceId,
          );
        }
        return m;
      }).toList();

      currentSession = currentSession.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      state = ChatState(session: currentSession, isGenerating: false);
      await _repository.saveSession(currentSession);
    } on AiProviderException catch (e, stack) {
      AppLogger.warning('sendMessage: AI provider failed: ${e.message}', e, stack);
      updatedMessages = updatedMessages
          .where((m) => m.id != assistantId)
          .toList();
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
      await eventSubscription.cancel();
      transport.dispose();
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

    final messages = session.messages.map((m) {
      if (m.status == MessageStatus.streaming) {
        return m.copyWith(
          status: MessageStatus.completed,
          content: m.content.isEmpty ? '(Stopped)' : m.content,
        );
      }
      return m;
    }).toList();

    final updated = session.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
    state = ChatState(session: updated, isGenerating: false);
    _repository.saveSession(updated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _sanitize(String text) {
    if (text.isEmpty) return '';

    const marker = '---a2ui_JSON---';

    // If this is a GenUI response (contains marker or starts with its specific prefix),
    // we do not show any simple text.
    if (text.contains(marker) || (text.length >= 3 && marker.startsWith(text))) {
      return '';
    }

    // Hide any partial marker at the end of the string
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
