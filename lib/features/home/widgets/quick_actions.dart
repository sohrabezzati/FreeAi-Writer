import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/genui/genui.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(Icons.chat_rounded, 'Free Chat', Colors.indigo, '/chat'),
      _Action(Icons.history_rounded, 'History', Colors.purple, '/history'),
      _Action(Icons.settings_rounded, 'Settings', Colors.cyan, '/settings'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index < actions.length - 1 ? 12 : 0),
              child: GenUiGlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: InkWell(
                  onTap: () => context.push(action.route),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(action.icon, color: action.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideX(begin: 0.1, end: 0),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Action {
  const _Action(this.icon, this.label, this.color, this.route);
  final IconData icon;
  final String label;
  final Color color;
  final String route;
}
