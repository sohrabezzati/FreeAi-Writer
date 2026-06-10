# FreeAI Writer

A production-ready Flutter application that generates text using completely free public AI APIs. Built with clean architecture, Riverpod state management, and a modern GenUI-inspired design.

## Features

- **Multi-provider AI** — Hugging Face, OpenRouter, Together AI, and Groq with automatic fallback
- **Streaming responses** — Real-time text generation with stop/regenerate controls
- **11 writing templates** — Blog, email, SEO, social media, translator, summarizer, and more
- **ChatGPT-like UI** — Message bubbles, markdown rendering, code blocks
- **Local storage** — Chat history and settings persisted with Hive
- **Dark/light themes** — System-aware theme switching
- **Cross-platform** — Android, iOS, Web, Windows, macOS, Linux

## Architecture

```
lib/
├── core/           # Network, theme, constants, services, widgets, utils
├── features/       # chat, history, settings, onboarding, home
├── shared/         # models, repositories, providers
├── router/         # GoRouter configuration
├── app.dart
└── main.dart
```

## GenUI Integration

This app uses the official [GenUI SDK for Flutter](https://docs.flutter.dev/ai/genui/get-started) (`genui` package) for its design system and AI-generated UI surfaces.

### GenUI Architecture

```
lib/core/genui/
├── app_catalog.dart          # BasicCatalog + custom catalog items
├── custom_catalog_items.dart # GlassCard, Banner, EmptyState, LoadingState, TemplateTile
├── genui_providers.dart      # SurfaceController, Catalog, PromptBuilder providers
├── genui_theme.dart          # Design tokens, gradient backgrounds, Surface view
├── genui.dart                # Barrel export
└── widgets/gen_ui_components.dart  # Scaffold, forms, chat bubbles, dialogs
```

### Custom Catalog Items

| Component | Use |
|-----------|-----|
| `GlassCard` | Glassmorphism cards across home, settings, history |
| `Banner` | API key setup prompts |
| `EmptyState` | Empty history, error states |
| `LoadingState` | Loading indicators |
| `TemplateTile` | AI-generatable template cards |

### Dependencies

- `genui` — GenUI framework (Conversation, Surface, Catalog)
- `json_schema_builder` — Catalog item schemas


## Getting Started

### Prerequisites

- Flutter SDK 3.11+
- At least one free API key (see below)

### Installation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### API Keys (Free Tiers)

Add keys in **Settings** inside the app:

| Provider | Sign up |
|----------|---------|
| Hugging Face | [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) |
| OpenRouter | [openrouter.ai/keys](https://openrouter.ai/keys) |
| Together AI | [api.together.xyz](https://api.together.xyz/) |
| Groq | [console.groq.com](https://console.groq.com/) |

Set **AI Provider** to **Auto (Fallback)** to try providers in order until one succeeds.

## Screens

| Screen | Description |
|--------|-------------|
| Splash | Animated logo intro |
| Onboarding | 3-page welcome flow |
| Home | Templates, quick actions, recent chats |
| Chat | Streaming AI conversation |
| History | Local chat archive |
| Settings | Theme, provider, API keys, export |

## Error Handling

- Offline detection via `connectivity_plus`
- Automatic provider fallback and retry (3 attempts)
- Rate limit handling with backoff

## Screen shots

<img width="320" height="700" alt="image" src="https://github.com/user-attachments/assets/fe0edfbb-7fe5-434e-9e55-e210fc3912ac" />
<img width="320" height="700" alt="image" src="https://github.com/user-attachments/assets/35fc1f9a-8621-476e-81a8-cfb17f974fbc" />
<img width="320" height="700" alt="image" src="https://github.com/user-attachments/assets/8c0c4a4c-c5ea-41e0-8870-da2e6c3c9fec" />
<img width="320" height="700" alt="image" src="https://github.com/user-attachments/assets/f134cd72-4f4c-4d2a-9174-aae6d30f70a1" />
<img width="320" height="700" alt="image" src="https://github.com/user-attachments/assets/8737bea8-2f5a-49a6-88ac-946e9229a921" />


## License

MIT
