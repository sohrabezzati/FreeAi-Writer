import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/free_models.dart';
import '../../../core/genui/genui.dart';
import '../../../shared/models/app_settings.dart';
import '../../../shared/providers/settings_provider.dart';

Future<void> showModelPicker(
  BuildContext context,
  WidgetRef ref,
  FreeAiModel selected,
) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Choose AI Model',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  for (final group in FreeModelsCatalog.groupedByProvider) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text(
                        group.provider.displayName.toUpperCase(),
                        style: Theme.of(sheetContext).textTheme.labelSmall
                            ?.copyWith(
                              letterSpacing: 0.8,
                              color: Theme.of(
                                sheetContext,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    for (final model in group.models)
                      _ModelPickerTile(
                        model: model,
                        isSelected: model.id == selected.id,
                        onTap: () => Navigator.pop(sheetContext, model.id),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  if (!context.mounted) return;
  if (picked != null && picked != selected.id) {
    await ref.read(settingsProvider.notifier).setSelectedModel(picked);
  }
}

class _ModelPickerTile extends StatelessWidget {
  const _ModelPickerTile({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  final FreeAiModel model;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(model.displayName),
      subtitle: Text(model.provider.displayName),
      selected: isSelected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GenUiRadii.medium),
      ),
      onTap: onTap,
    );
  }
}

class ModelSelectorButton extends ConsumerWidget {
  const ModelSelectorButton({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModelId = ref.watch(
      settingsProvider.select((settings) => settings.selectedModelId),
    );
    final selected = FreeModelsCatalog.resolve(selectedModelId);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'AI model: ${selected.labelWithProvider}. Tap to change.',
      child: Tooltip(
        message: selected.labelWithProvider,
        waitDuration: const Duration(milliseconds: 400),
        child: IconButton(
          onPressed: enabled
              ? () => showModelPicker(context, ref, selected)
              : null,
          icon: const Icon(Icons.auto_awesome_rounded),
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),

            foregroundColor: enabled
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.32),
          ),
        ),
      ),
    );
  }
}
