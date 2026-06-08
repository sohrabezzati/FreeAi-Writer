import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genui/genui.dart';

import '../theme/app_colors.dart';

/// GenUI design tokens and theme helpers for FreeAI Writer.
abstract final class GenUiTheme {
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 20;

  static ThemeData apply(ThemeData base) {
    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: base.cardColor,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }

  static Widget wrapAnimated(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double blur = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.cardDark : AppColors.cardLight;

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GenUiRadii.large),
        color: blur > 0 ? surface.withValues(alpha: 0.72) : surface,
        border: Border.all(
          color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
              .withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(GenUiRadii.large),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    return content.animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  static Widget gradientBackground({required Widget child, bool? isDark}) {
    return _GenUiGradientBackground(isDark: isDark, child: child);
  }
}

abstract final class GenUiRadii {
  static const double small = GenUiTheme.radiusSmall;
  static const double medium = GenUiTheme.radiusMedium;
  static const double large = GenUiTheme.radiusLarge;
}

class _GenUiGradientBackground extends StatelessWidget {
  const _GenUiGradientBackground({required this.child, this.isDark});

  final Widget child;
  final bool? isDark;

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    final colors = dark ? AppColors.gradientDark : AppColors.gradientLight;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors[0].withValues(alpha: dark ? 0.3 : 0.08),
                colors[1].withValues(alpha: dark ? 0.2 : 0.05),
                colors[2].withValues(alpha: dark ? 0.15 : 0.03),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Shows a GenUI [Surface] for a given surface id.
class GenUiSurfaceView extends StatelessWidget {
  const GenUiSurfaceView({
    super.key,
    required this.controller,
    required this.surfaceId,
    this.fallback,
  });

  final SurfaceController controller;
  final String surfaceId;
  final WidgetBuilder? fallback;

  @override
  Widget build(BuildContext context) {
    return Surface(
      surfaceContext: controller.contextFor(surfaceId),
      defaultBuilder: fallback,
    );
  }
}
