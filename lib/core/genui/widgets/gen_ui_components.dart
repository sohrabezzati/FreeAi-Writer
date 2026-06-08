import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../genui_theme.dart';

/// GenUI page scaffold with gradient background and optional app bar.
class GenUiScaffold extends StatelessWidget {
  const GenUiScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: GenUiTheme.gradientBackground(child: body),
    );
  }
}

/// GenUI form field aligned with catalog TextField styling.
class GenUiFormField extends StatelessWidget {
  const GenUiFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label.isEmpty ? null : label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// GenUI chat input row.
class GenUiChatComposer extends StatelessWidget {
  const GenUiChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.isGenerating = false,
    this.onStop,
    this.hintText = 'Ask anything...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool isGenerating;
  final VoidCallback? onStop;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GenUiFormField(
              controller: controller,
              label: '',
              hint: hintText,
              maxLines: 5,
              onSubmitted: isGenerating ? null : onSend,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isGenerating
                ? onStop
                : () => onSend(controller.text.trim()),
            icon: Icon(isGenerating ? Icons.stop_rounded : Icons.send_rounded),
            style: isGenerating
                ? IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// GenUI dialog helper.
Future<T?> showGenUiDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String? cancelLabel,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLabel),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true as T),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// GenUI chat bubble using catalog chat primitives styling.
class GenUiChatBubble extends StatelessWidget {
  const GenUiChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.trailing,
  });

  final String text;
  final bool isUser;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return ChatMessageView(
        text: text,
        icon: Icons.person_rounded,
        alignment: MainAxisAlignment.end,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatMessageView(
          text: text.isEmpty ? '...' : text,
          icon: Icons.auto_awesome_rounded,
          alignment: MainAxisAlignment.start,
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
