// lib/core/routes/route_names.dart

/// Route name constants for the application
class RouteNames {
  RouteNames._();

  // ============ Main Routes ============
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';

  // ============ Main Navigation Tabs ============
  static const String translation = '/translation';
  static const String camera = '/camera';
  static const String conversation = '/conversation';
  static const String history = '/history';
  static const String favorites = '/favorites';

  // ============ Feature Routes ============
  static const String settings = '/settings';
  static const String languageSelector = '/language-selector';
  static const String voiceInput = '/voice-input';
  static const String translationFullscreen = '/translation-fullscreen';

  // ============ Settings Sub-Routes ============
  static const String themeSettings = '/settings/theme';
  static const String languageSettings = '/settings/language';
  static const String speechSettings = '/settings/speech';
  static const String accessibilitySettings = '/settings/accessibility';
  static const String privacySettings = '/settings/privacy';
  static const String aboutSettings = '/settings/about';

  // ============ Help Routes ============
  static const String help = '/help';
  static const String faq = '/faq';

  // ============ Error Routes ============
  static const String error = '/error';
  static const String notFound = '/404';
}
