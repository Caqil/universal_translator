
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/history/presentation/pages/history_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/translation/presentation/pages/translation_page.dart';
import '../../shared/pages/main_wrapper_page.dart';
import 'route_names.dart';

/// Global router configuration
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

/// Main app router using GoRouter
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,

  // Error handling
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: ErrorPage(errorMessage: state.error.toString()),
  ),

  routes: [
    // ============ Initial Routes ============

    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // ============ Main Shell with Bottom Navigation ============

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainWrapperPage();
      },
      routes: [
        // Translation tab (home)
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          builder: (context, state) => const TranslationPage(),
        ),

        // Camera tab
        // GoRoute(
        //   path: RouteNames.camera,
        //   name: 'camera',
        //   builder: (context, state) => const CameraPage(),
        // ),

        // History tab
        GoRoute(
          path: RouteNames.history,
          name: 'history',
          builder: (context, state) => const HistoryPage(),
        ),

        // Favorites tab
        GoRoute(
          path: RouteNames.favorites,
          name: 'favorites',
          builder: (context, state) => const FavoritesPage(),
        ),
      ],
    ),

    // ============ Feature Routes (Full Screen) ============

    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        // Settings sub-routes
        GoRoute(
          path: '/theme',
          name: 'theme-settings',
          builder: (context, state) => const ThemeSettingsPage(),
        ),
        GoRoute(
          path: '/language',
          name: 'language-settings',
          builder: (context, state) => const LanguageSettingsPage(),
        ),
        GoRoute(
          path: '/speech',
          name: 'speech-settings',
          builder: (context, state) => const SpeechSettingsPage(),
        ),
        GoRoute(
          path: '/accessibility',
          name: 'accessibility-settings',
          builder: (context, state) => const AccessibilitySettingsPage(),
        ),
        GoRoute(
          path: '/privacy',
          name: 'privacy-settings',
          builder: (context, state) => const PrivacySettingsPage(),
        ),
        GoRoute(
          path: '/about',
          name: 'about-settings',
          builder: (context, state) => const AboutSettingsPage(),
        ),
      ],
    ),

    GoRoute(
      path: RouteNames.languageSelector,
      name: 'language-selector',
      builder: (context, state) {
        final sourceLanguage = state.uri.queryParameters['source'];
        final targetLanguage = state.uri.queryParameters['target'];
        final showAutoDetect =
            state.uri.queryParameters['autoDetect'] == 'true';

        return LanguageSelectorPage(
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          showAutoDetect: showAutoDetect,
        );
      },
    ),

    GoRoute(
      path: RouteNames.voiceInput,
      name: 'voice-input',
      builder: (context, state) {
        final languageCode = state.uri.queryParameters['language'];
        return VoiceInputPage(languageCode: languageCode);
      },
    ),

    GoRoute(
      path: '${RouteNames.translationFullscreen}/:translationId',
      name: 'translation-fullscreen',
      builder: (context, state) {
        final translationId = state.pathParameters['translationId']!;
        return TranslationFullscreenPage(translationId: translationId);
      },
    ),

    GoRoute(
      path: RouteNames.help,
      name: 'help',
      builder: (context, state) => const HelpPage(),
    ),

    GoRoute(
      path: RouteNames.faq,
      name: 'faq',
      builder: (context, state) => const FAQPage(),
    ),

    // ============ Error Routes ============

    GoRoute(
      path: RouteNames.error,
      name: 'error',
      builder: (context, state) {
        final message = state.uri.queryParameters['message'];
        return ErrorPage(errorMessage: message);
      },
    ),

    GoRoute(
      path: RouteNames.notFound,
      name: 'not-found',
      builder: (context, state) => const NotFoundPage(),
    ),
  ],
);

// ============ Navigation Extensions ============

extension AppRouterExtension on BuildContext {
  /// Go to a named route
  void goNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters}) {
    GoRouter.of(this).goNamed(name,
        pathParameters: pathParameters!, queryParameters: queryParameters!);
  }

  /// Push a named route
  void pushNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters}) {
    GoRouter.of(this).pushNamed(name,
        pathParameters: pathParameters!, queryParameters: queryParameters!);
  }

  /// Go to a path
  void go(String path) {
    GoRouter.of(this).go(path);
  }

  /// Push a path
  void push(String path) {
    GoRouter.of(this).push(path);
  }

  /// Pop the current route
  void pop() {
    GoRouter.of(this).pop();
  }

  /// Check if can pop
  bool canPop() {
    return GoRouter.of(this).canPop();
  }
}

// ============ Placeholder Pages (to be implemented) ============

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: const Center(child: Text('Theme Settings - To be implemented')),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language Settings')),
      body: const Center(child: Text('Language Settings - To be implemented')),
    );
  }
}

class SpeechSettingsPage extends StatelessWidget {
  const SpeechSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech Settings')),
      body: const Center(child: Text('Speech Settings - To be implemented')),
    );
  }
}

class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Settings')),
      body: const Center(
          child: Text('Accessibility Settings - To be implemented')),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: const Center(child: Text('Privacy Settings - To be implemented')),
    );
  }
}

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(child: Text('About - To be implemented')),
    );
  }
}

class LanguageSelectorPage extends StatelessWidget {
  final String? sourceLanguage;
  final String? targetLanguage;
  final bool showAutoDetect;

  const LanguageSelectorPage({
    super.key,
    this.sourceLanguage,
    this.targetLanguage,
    this.showAutoDetect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: const Center(child: Text('Language Selector - To be implemented')),
    );
  }
}

class VoiceInputPage extends StatelessWidget {
  final String? languageCode;

  const VoiceInputPage({super.key, this.languageCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Input')),
      body: const Center(child: Text('Voice Input - To be implemented')),
    );
  }
}

class TranslationFullscreenPage extends StatelessWidget {
  final String translationId;

  const TranslationFullscreenPage({super.key, required this.translationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translation')),
      body: Center(child: Text('Translation Fullscreen: $translationId')),
    );
  }
}


class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('Favorites - To be implemented')),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Center(child: Text('Help - To be implemented')),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: const Center(child: Text('FAQ - To be implemented')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ErrorPage({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something went wrong'),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(errorMessage!),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => AppRouterExtension(context).go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => AppRouterExtension(context).go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
