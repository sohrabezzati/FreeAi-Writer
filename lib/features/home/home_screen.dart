import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/template_constants.dart';
import '../../core/genui/genui.dart';
import '../../core/widgets/api_key_setup_banner.dart';
import '../../shared/models/app_settings.dart';
import '../../shared/providers/settings_provider.dart';
import '../chat/providers/chat_provider.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_chats.dart';
import 'widgets/template_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final recentChats = ref.watch(recentChatSessionsProvider);

    return GenUiScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(chatProvider.notifier).createSession();
          context.push('/chat');
        },
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Chat'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'What would you like to create?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
              ),
            ),
            if (!settings.hasAnyApiKey)
              const SliverToBoxAdapter(child: ApiKeySetupBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GenUiGlassCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.hub_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Provider',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              settings.preferredProvider.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<AiProviderType>(
                        value: settings.preferredProvider,
                        underline: const SizedBox.shrink(),
                        items: AiProviderType.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .setPreferredProvider(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: QuickActions()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Templates',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TemplateGrid(
                templates: TemplateConstants.templates,
                onTemplateTap: (template) {
                  ref.read(chatProvider.notifier).createSession(
                        templateId: template.id,
                        systemPrompt: template.systemPrompt,
                        initialTitle: template.title,
                      );
                  context.push('/chat');
                },
              ),
            ),
            if (recentChats.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Chats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.push('/history'),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RecentChats(
                  sessions: recentChats.take(5).toList(),
                  onTap: (session) {
                    ref.read(chatProvider.notifier).loadSession(session.id);
                    context.push('/chat', extra: {'sessionId': session.id});
                  },
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
