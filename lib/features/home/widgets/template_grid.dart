import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/genui/genui.dart';
import '../../../shared/models/text_template.dart';

class TemplateGrid extends StatelessWidget {
  const TemplateGrid({
    super.key,
    required this.templates,
    required this.onTemplateTap,
  });

  final List<TextTemplate> templates;
  final ValueChanged<TextTemplate> onTemplateTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: templates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),

        itemBuilder: (context, index) {
          final template = templates[index];
          return SizedBox(
            width: 160,
            child: GenUiGlassCard(
                  padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () => onTemplateTap(template),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _iconForName(template.iconName),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Spacer(),
                            Text(
                              template.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0),
          );
        },
      ),
    );
  }

  IconData _iconForName(String name) {
    return switch (name) {
      'article' => Icons.article_outlined,
      'email' => Icons.email_outlined,
      'shopping_bag' => Icons.shopping_bag_outlined,
      'search' => Icons.search_rounded,
      'share' => Icons.share_rounded,
      'camera_alt' => Icons.camera_alt_outlined,
      'work' => Icons.work_outline_rounded,
      'play_circle' => Icons.play_circle_outline_rounded,
      'auto_stories' => Icons.auto_stories_outlined,
      'translate' => Icons.translate_rounded,
      'summarize' => Icons.summarize_rounded,
      _ => Icons.description_outlined,
    };
  }
}
