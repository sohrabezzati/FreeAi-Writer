import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'genui_theme.dart';

/// GenUI catalog item: glass-style card container for grouped content.
final glassCardCatalogItem = CatalogItem(
  name: 'GlassCard',
  dataSchema: S.object(
    description: 'A glassmorphism card with optional title and child.',
    properties: {
      'title': S.string(description: 'Optional card title.'),
      'subtitle': S.string(description: 'Optional card subtitle.'),
      'childText': S.string(description: 'Optional body text content.'),
    },
  ),
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final title = json['title'] as String?;
    final subtitle = json['subtitle'] as String?;
    final childText = json['childText'] as String?;

    return GenUiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(title, style: Theme.of(itemContext.buildContext).textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(itemContext.buildContext).textTheme.bodySmall,
            ),
          ],
          if (childText != null) ...[
            if (title != null || subtitle != null) const SizedBox(height: 12),
            Text(childText),
          ],
        ],
      ),
    );
  },
);

/// GenUI catalog item: empty / error state panel.
final emptyStateCatalogItem = CatalogItem(
  name: 'EmptyState',
  dataSchema: S.object(
    properties: {
      'icon': S.string(description: 'Material icon name, e.g. history'),
      'title': S.string(),
      'message': S.string(),
      'actionLabel': S.string(),
    },
    required: ['title'],
  ),
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    return GenUiEmptyState(
      icon: _iconFromName(json['icon'] as String? ?? 'info_outline'),
      title: json['title'] as String? ?? '',
      message: json['message'] as String?,
      actionLabel: json['actionLabel'] as String?,
      onAction: json['actionLabel'] != null ? () {} : null,
    );
  },
);

/// GenUI catalog item: loading indicator block.
final loadingStateCatalogItem = CatalogItem(
  name: 'LoadingState',
  dataSchema: S.object(
    properties: {
      'message': S.string(description: 'Optional loading message.'),
    },
  ),
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    return GenUiLoading(message: json['message'] as String?);
  },
);

/// GenUI catalog item: call-to-action banner.
final bannerCatalogItem = CatalogItem(
  name: 'Banner',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'message': S.string(),
      'actionLabel': S.string(),
    },
    required: ['title', 'message'],
  ),
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    return GenUiBanner(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      actionLabel: json['actionLabel'] as String?,
      onAction: () {},
    );
  },
);

/// GenUI catalog item: writing template tile.
final templateTileCatalogItem = CatalogItem(
  name: 'TemplateTile',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'description': S.string(),
      'icon': S.string(),
    },
    required: ['title', 'description'],
  ),
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    return GenUiCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconFromName(json['icon'] as String? ?? 'description'),
              color: Theme.of(itemContext.buildContext).colorScheme.primary,
            ),
            const Spacer(),
            Text(
            json['title'] as String? ?? '',
            style: Theme.of(itemContext.buildContext).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            json['description'] as String? ?? '',
            style: Theme.of(itemContext.buildContext).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        ),
      ),
    );
  },
);

IconData _iconFromName(String name) {
  return switch (name) {
    'history' => Icons.history_rounded,
    'key' => Icons.key_rounded,
    'chat' => Icons.chat_rounded,
    'settings' => Icons.settings_rounded,
    'article' => Icons.article_outlined,
    'email' => Icons.email_outlined,
    'search' => Icons.search_rounded,
    'share' => Icons.share_rounded,
    'auto_awesome' => Icons.auto_awesome_rounded,
    _ => Icons.info_outline_rounded,
  };
}

/// Static GenUI glass card used across the app and in catalog items.
class GenUiGlassCard extends StatelessWidget {
  const GenUiGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = GenUiCard(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      blur: 12,
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GenUiRadii.large),
      child: card,
    );
  }
}

/// Standard GenUI card with optional glass blur.
class GenUiCard extends StatelessWidget {
  const GenUiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return GenUiTheme.wrapAnimated(context, blur: blur, child: child, padding: padding, margin: margin);
  }
}

/// GenUI loading state widget.
class GenUiLoading extends StatelessWidget {
  const GenUiLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// GenUI empty / error state widget.
class GenUiEmptyState extends StatelessWidget {
  const GenUiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// GenUI banner for alerts and setup prompts.
class GenUiBanner extends StatelessWidget {
  const GenUiBanner({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.leadingIcon = Icons.key_rounded,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return GenUiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(leadingIcon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
          ],
        ],
      ),
    );
  }
}
