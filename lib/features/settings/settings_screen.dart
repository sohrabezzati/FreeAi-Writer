import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/genui/genui.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/glass_container.dart';
import '../../shared/models/app_settings.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/repositories/chat_repository.dart';
import '../chat/providers/chat_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _hfKeyController;
  late TextEditingController _orKeyController;
  late TextEditingController _togetherKeyController;
  late TextEditingController _groqKeyController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _hfKeyController = TextEditingController(text: settings.huggingFaceApiKey);
    _orKeyController = TextEditingController(text: settings.openRouterApiKey);
    _togetherKeyController = TextEditingController(
      text: settings.togetherApiKey,
    );
    _groqKeyController = TextEditingController(text: settings.groqApiKey);
  }

  @override
  void dispose() {
    _hfKeyController.dispose();
    _orKeyController.dispose();
    _togetherKeyController.dispose();
    _groqKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKeys() async {
    await ref
        .read(settingsProvider.notifier)
        .setApiKey(
          huggingFace: _hfKeyController.text.trim(),
          openRouter: _orKeyController.text.trim(),
          together: _togetherKeyController.text.trim(),
          groq: _groqKeyController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API keys saved')));
    }
  }

  Future<void> _exportChats() async {
    final sessions = ref.read(chatRepositoryProvider).getAllSessions();
    if (sessions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No chats to export')));
      return;
    }

    final json = jsonEncode(sessions.map((s) => s.toJson()).toList());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/freeai_writer_chats.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: '${AppConstants.appName} Chat Export',
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will permanently delete all chat history. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(chatProvider.notifier).clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat history cleared')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _saveApiKeys();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Settings'),
          actions: [
            TextButton(onPressed: _saveApiKeys, child: const Text('Save')),
          ],
        ),
        body: GenUiTheme.gradientBackground(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              GlassContainer(
                child: RadioGroup<ThemeModeOption>(
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .setThemeMode(value);
                    }
                  },
                  child: Column(
                    children: ThemeModeOption.values.map((mode) {
                      return RadioListTile<ThemeModeOption>(
                        title: Text(mode.name.capitalize),
                        value: mode,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AI Provider',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GlassContainer(
                child: RadioGroup<AiProviderType>(
                  groupValue: settings.preferredProvider,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .setPreferredProvider(value);
                    }
                  },
                  child: Column(
                    children: AiProviderType.values.map((provider) {
                      return RadioListTile<AiProviderType>(
                        title: Text(provider.displayName),
                        subtitle: Text(provider.description),
                        value: provider,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('API Keys', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Free APIs still need a free key. Add at least one below, then '
                'tap Save API Keys before chatting.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!settings.hasAnyApiKey) ...[
                const SizedBox(height: 12),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended: Groq (free & fast)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1. Go to console.groq.com\n'
                        '2. Create a free account\n'
                        '3. Copy your API key (starts with gsk_)\n'
                        '4. Paste it below and tap Save',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Saved: ${settings.configuredProviders.map((p) => p.displayName).join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              GlassContainer(
                child: Column(
                  children: [
                    _ApiKeyField(
                      label: 'Groq (recommended)',
                      controller: _groqKeyController,
                      hint: 'gsk_...',
                      isSaved: settings.groqApiKey.isNotEmpty,
                      onSubmitted: (_) => _saveApiKeys(),
                    ),
                    _ApiKeyField(
                      label: 'OpenRouter',
                      controller: _orKeyController,
                      hint: 'sk-or-...',
                      isSaved: settings.openRouterApiKey.isNotEmpty,
                      onSubmitted: (_) => _saveApiKeys(),
                    ),
                    _ApiKeyField(
                      label: 'Together AI',
                      controller: _togetherKeyController,
                      hint: '...',
                      isSaved: settings.togetherApiKey.isNotEmpty,
                      onSubmitted: (_) => _saveApiKeys(),
                    ),
                    _ApiKeyField(
                      label: 'Hugging Face',
                      controller: _hfKeyController,
                      hint: 'hf_...',
                      isSaved: settings.huggingFaceApiKey.isNotEmpty,
                      onSubmitted: (_) => _saveApiKeys(),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveApiKeys,
                        child: const Text('Save API Keys'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Data', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              GlassContainer(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_rounded),
                      title: const Text('Export Chats'),
                      subtitle: const Text('Share chat history as JSON'),
                      onTap: _exportChats,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: const Text('Clear History'),
                      subtitle: const Text('Delete all saved chats'),
                      onTap: _clearHistory,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '${AppConstants.appName} v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.label,
    required this.controller,
    required this.hint,
    this.isSaved = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isSaved;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GenUiFormField(
        controller: controller,
        label: label,
        hint: hint,
        obscureText: true,
        onSubmitted: onSubmitted,
        suffixIcon: isSaved
            ? Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }
}
