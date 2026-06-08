import 'package:flutter/material.dart';

import '../genui/genui.dart';

/// Backward-compatible alias for [GenUiGlassCard].
typedef GlassContainer = GenUiGlassCard;

/// Backward-compatible gradient wrapper using GenUI theme.
class AnimatedGradientBackground extends StatelessWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.isDark,
  });

  final Widget child;
  final bool? isDark;

  @override
  Widget build(BuildContext context) {
    return GenUiTheme.gradientBackground(isDark: isDark, child: child);
  }
}

/// Backward-compatible loading state using GenUI.
typedef LoadingIndicator = GenUiLoading;

/// Backward-compatible empty/error state using GenUI.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return GenUiEmptyState(
      icon: Icons.error_outline_rounded,
      title: message,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}
