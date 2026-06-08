import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions.dart';
import '../../core/genui/genui.dart';
import '../../core/widgets/glass_container.dart';
import '../chat/providers/chat_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(chatSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chat History'),
      ),
      body: GenUiTheme.gradientBackground(
        child: sessions.isEmpty
            ? const GenUiEmptyState(
                icon: Icons.history_rounded,
                title: 'No chat history yet',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: sessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),

                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Dismissible(
                    key: ValueKey(session.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      await ref
                          .read(chatProvider.notifier)
                          .deleteSession(session.id);
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(chatProvider.notifier)
                              .loadSession(session.id);
                          context.push(
                            '/chat',
                            extra: {'sessionId': session.id},
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${session.messages.length} messages · ${session.updatedAt.formatted}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
