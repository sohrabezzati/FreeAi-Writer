import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import 'app_catalog.dart';

final appCatalogProvider = Provider<Catalog>((ref) {
  return AppCatalog.create();
});

final surfaceControllerProvider = Provider<SurfaceController>((ref) {
  final controller = SurfaceController(catalogs: AppCatalog.all());
  ref.onDispose(controller.dispose);
  return controller;
});

final promptBuilderProvider = Provider<PromptBuilder>((ref) {
  final catalog = ref.watch(appCatalogProvider);
  return PromptBuilder.chat(
    catalog: catalog,
    systemPromptFragments: [
      'You are a helpful writing assistant that uses rich UI surfaces.',
      'IMPORTANT: When creating a UI, you MUST send TWO blocks in order:',
      '1. A "createSurface" message to initialize the area.',
      '2. An "updateComponents" message to populate it with widgets.',
      'Always send both blocks immediately in the same response.',
      'Always wrap your A2UI JSON blocks with "---a2ui_JSON---" delimiters like this:',
      '---a2ui_JSON---',
      '{ "version": "v0.9", "createSurface": { ... } }',
      '---a2ui_JSON---',
    ],
  );
});
