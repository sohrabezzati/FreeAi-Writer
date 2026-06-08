import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/genui/genui.dart';
import '../../../shared/models/chat_message.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onCopy,
    this.onRegenerate,
    this.showActions = false,
  });

  final ChatMessage message;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == MessageRole.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : (isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Directionality(
                textDirection: _isRtl(message.content)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              )
            else ...[
              if (message.surfaceId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GenUiSurfaceView(
                    controller: ref.watch(surfaceControllerProvider),
                    surfaceId: message.surfaceId!,
                  ),
                ),
              if (message.content.isNotEmpty)
                Directionality(
                  textDirection: _isRtl(message.content)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyMedium,
                      code: TextStyle(
                        backgroundColor: isDark
                            ? Colors.black26
                            : Colors.black.withValues(alpha: 0.05),
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isDark
                            ? atomOneDarkTheme['root']!.backgroundColor
                            : atomOneLightTheme['root']!.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
            if (message.status == MessageStatus.streaming)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _TypingDots(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (showActions && !isUser && message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: onCopy,
                  ),
                  if (onRegenerate != null) ...[
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.refresh_rounded,
                      label: 'Regenerate',
                      onTap: onRegenerate,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});
  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.3 + value * 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}

bool _isRtl(String text) {
  if (text.isEmpty) return false;
  final rtlRegex = RegExp(
    r'[\u0590-\u05FF\u0600-\u06FF\u0700-\u074F\u0750-\u077F\u0780-\u07BF\u0800-\u08FF\uFB1D-\uFB4F\uFB50-\uFDFF\uFE70-\uFEFF]'
  );
  return rtlRegex.hasMatch(text);
}
