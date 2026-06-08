import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/network_info.dart';
import '../../core/genui/genui.dart';
import '../../core/widgets/api_key_setup_banner.dart';
import '../../shared/models/app_settings.dart';
import '../../shared/providers/settings_provider.dart';
import 'providers/chat_provider.dart';
import '../../shared/models/chat_message.dart';
import 'widgets/chat_input.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    this.sessionId,
    this.templateId,
    this.systemPrompt,
    this.initialTitle,
  });

  final String? sessionId;
  final String? templateId;
  final String? systemPrompt;
  final String? initialTitle;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  void _initSession() {
    if (_initialized) return;
    _initialized = true;

    final notifier = ref.read(chatProvider.notifier);
    if (widget.sessionId != null) {
      notifier.loadSession(widget.sessionId!);
    } else if (ref.read(chatProvider).session == null) {
      notifier.createSession(
        templateId: widget.templateId,
        systemPrompt: widget.systemPrompt,
        initialTitle: widget.initialTitle,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _scrollToBottomIfNeeded() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final isNearBottom = (pos.maxScrollExtent - pos.pixels) < 120;
    if (isNearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settings = ref.watch(settingsProvider);
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final session = chatState.session;
    final messages = session?.messages ?? [];

    ref.listen(chatProvider, (previous, next) {
      final prevMessages = previous?.session?.messages ?? [];
      final nextMessages = next.session?.messages ?? [];

      if (nextMessages.length > prevMessages.length) {
        _scrollToBottom();
      } else if (next.isGenerating) {
        _scrollToBottomIfNeeded();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(session?.title ?? 'Chat'),
        actions: [
          if (!isOnline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(Icons.wifi_off_rounded, size: 16),
                label: Text('Offline'),
              ),
            ),
        ],
      ),
      body: GenUiTheme.gradientBackground(
        child: Column(
          children: [
            if (chatState.error != null)
              MaterialBanner(
                content: Text(chatState.error!),
                actions: [
                  if (!settings.hasAnyApiKey)
                    TextButton(
                      onPressed: () => context.push('/settings'),
                      child: const Text('Settings'),
                    ),
                  TextButton(
                    onPressed: () =>
                        ref.read(chatProvider.notifier).clearError(),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            if (!settings.hasAnyApiKey) const ApiKeySetupBanner(),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start a conversation',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              settings.hasAnyApiKey
                                  ? 'Type a message below to generate AI text'
                                  : 'Add a free Groq API key in Settings first, '
                                      'then come back to chat.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isLast = index == messages.length - 1;
                        final isAssistant =
                            message.role == MessageRole.assistant;

                        return MessageBubble(
                          message: message,
                          showActions: isLast &&
                              isAssistant &&
                              !chatState.isGenerating,
                          onCopy: () {
                            Clipboard.setData(
                              ClipboardData(text: message.content),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                          onRegenerate: chatState.isGenerating
                              ? null
                              : () => ref
                                  .read(chatProvider.notifier)
                                  .regenerateLastResponse(),
                        );
                      },
                    ),
            ),
            ChatInput(
              isGenerating: chatState.isGenerating,
              onSend: (text) =>
                  ref.read(chatProvider.notifier).sendMessage(text),
              onStop: () => ref.read(chatProvider.notifier).stopGeneration(),
            ),
          ],
        ),
      ),
    );
  }
}
