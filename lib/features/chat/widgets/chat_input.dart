import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'model_selector.dart';

class ChatInput extends ConsumerStatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    this.isGenerating = false,
    this.onStop,
    this.hintText = 'Ask anything...',
  });

  final ValueChanged<String> onSend;
  final bool isGenerating;
  final VoidCallback? onStop;
  final String hintText;

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  bool get _canSend =>
      !widget.isGenerating && _controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    final text = _controller.text.trim();
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
            .withValues(alpha: 0.18);
    final fillColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        // color: theme.colorScheme.surface.withValues(alpha: 0.96),
        // border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ModelSelectorButton(enabled: !widget.isGenerating),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isGenerating,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _canSend ? (_) => _send() : null,
                ),
              ),
              _ComposerActionButton(
                isGenerating: widget.isGenerating,
                canSend: _canSend,
                onSend: _send,
                onStop: widget.onStop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerActionButton extends StatelessWidget {
  const _ComposerActionButton({
    required this.isGenerating,
    required this.canSend,
    required this.onSend,
    this.onStop,
  });

  final bool isGenerating;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isGenerating
          ? Semantics(
              key: const ValueKey('stop'),
              button: true,
              label: 'Stop generating',
              child: IconButton.filled(
                onPressed: onStop,
                icon: const Icon(Icons.stop_rounded),
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  backgroundColor: colorScheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          : Semantics(
              key: const ValueKey('send'),
              button: true,
              enabled: canSend,
              label: 'Send message',
              child: IconButton.filled(
                onPressed: canSend ? onSend : null,
                icon: const Icon(Icons.arrow_upward_rounded),
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  disabledBackgroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.08,
                  ),
                  disabledForegroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
            ),
    );
  }
}
