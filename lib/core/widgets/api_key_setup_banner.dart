import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/genui/genui.dart';

class ApiKeySetupBanner extends StatelessWidget {
  const ApiKeySetupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GenUiBanner(
        title: 'API key required',
        message:
            '${AppConstants.appName} uses free AI APIs, but each provider '
            'still needs a free API key. The fastest option is Groq.',
        actionLabel: 'Add API Key in Settings',
        onAction: () => context.push('/settings'),
      ),
    );
  }
}
