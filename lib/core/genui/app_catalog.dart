import 'package:genui/genui.dart';

import 'custom_catalog_items.dart';

/// FreeAI Writer widget catalog for GenUI surfaces and AI-generated UI.
abstract final class AppCatalog {
  AppCatalog._();

  static const String catalogId = 'https://a2ui.org/specification/v0_9/basic_catalog.json';

  static Catalog create({List<String> extraPromptFragments = const []}) {
    final basic = BasicCatalogItems.asNoAssetCatalog();
    final merged = basic.copyWith(
      catalogId: catalogId,
      newItems: [
        glassCardCatalogItem,
        emptyStateCatalogItem,
        loadingStateCatalogItem,
        bannerCatalogItem,
        templateTileCatalogItem,
      ],
    );

    return Catalog(
      merged.items,
      functions: merged.functions,
      catalogId: catalogId,
      systemPromptFragments: [
        ...merged.systemPromptFragments,
        'You are FreeAI Writer, a helpful writing assistant.',
        'Prefer GlassCard, Banner, TemplateTile, EmptyState, and LoadingState '
            'for app-specific layouts when appropriate.',
        ...extraPromptFragments,
      ],
    );
  }

  static List<Catalog> all({List<String> extraPromptFragments = const []}) {
    return [create(extraPromptFragments: extraPromptFragments)];
  }
}
