// lib/core/services/user_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Service for managing user preferences and app state
class UserPreferencesService {
  static SharedPreferences? _prefs;

  /// Initialize the service
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  static Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ============ First Launch & Onboarding ============

  /// Check if this is the first launch
  static Future<bool> get isFirstLaunch async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  /// Mark that the user has completed onboarding
  static Future<void> setOnboardingCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.keyFirstLaunch, false);
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString(
        'onboarding_completed_date', DateTime.now().toIso8601String());
  }

  /// Check if onboarding was completed
  static Future<bool> get hasCompletedOnboarding async {
    final prefs = await _preferences;
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Get onboarding completion date
  static Future<DateTime?> get onboardingCompletedDate async {
    final prefs = await _preferences;
    final dateString = prefs.getString('onboarding_completed_date');
    return dateString != null ? DateTime.tryParse(dateString) : null;
  }

  // ============ App Launch Tracking ============

  /// Get app launch count
  static Future<int> get launchCount async {
    final prefs = await _preferences;
    return prefs.getInt('launch_count') ?? 0;
  }

  /// Increment launch count
  static Future<void> incrementLaunchCount() async {
    final prefs = await _preferences;
    final currentCount = await launchCount;
    await prefs.setInt('launch_count', currentCount + 1);
    await prefs.setString('last_launch_date', DateTime.now().toIso8601String());
  }

  /// Get last launch date
  static Future<DateTime?> get lastLaunchDate async {
    final prefs = await _preferences;
    final dateString = prefs.getString('last_launch_date');
    return dateString != null ? DateTime.tryParse(dateString) : null;
  }

  // ============ Language Preferences ============

  /// Get selected source language
  static Future<String> get selectedSourceLanguage async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keySelectedSourceLanguage) ??
        AppConstants.defaultLanguageCode;
  }

  /// Set selected source language
  static Future<void> setSelectedSourceLanguage(String languageCode) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.keySelectedSourceLanguage, languageCode);
  }

  /// Get selected target language
  static Future<String> get selectedTargetLanguage async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keySelectedTargetLanguage) ?? 'es';
  }

  /// Set selected target language
  static Future<void> setSelectedTargetLanguage(String languageCode) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.keySelectedTargetLanguage, languageCode);
  }

  // ============ App Settings ============

  /// Get theme mode
  static Future<String> get themeMode async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  /// Set theme mode
  static Future<void> setThemeMode(String mode) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.keyThemeMode, mode);
  }

  // ============ Feature Flags & Tutorial ============

  /// Check if user has seen a specific tutorial
  static Future<bool> hasSeenTutorial(String tutorialKey) async {
    final prefs = await _preferences;
    return prefs.getBool('tutorial_$tutorialKey') ?? false;
  }

  /// Mark tutorial as seen
  static Future<void> markTutorialAsSeen(String tutorialKey) async {
    final prefs = await _preferences;
    await prefs.setBool('tutorial_$tutorialKey', true);
  }

  /// Check if feature was introduced
  static Future<bool> hasSeenFeatureIntro(String featureKey) async {
    final prefs = await _preferences;
    return prefs.getBool('feature_intro_$featureKey') ?? false;
  }

  /// Mark feature intro as seen
  static Future<void> markFeatureIntroAsSeen(String featureKey) async {
    final prefs = await _preferences;
    await prefs.setBool('feature_intro_$featureKey', true);
  }

  // ============ User Behavior Tracking ============

  /// Get translation count
  static Future<int> get translationCount async {
    final prefs = await _preferences;
    return prefs.getInt('translation_count') ?? 0;
  }

  /// Increment translation count
  static Future<void> incrementTranslationCount() async {
    final prefs = await _preferences;
    final currentCount = await translationCount;
    await prefs.setInt('translation_count', currentCount + 1);
  }

  /// Get favorite language pairs
  static Future<List<String>> get favoriteLanguagePairs async {
    final prefs = await _preferences;
    return prefs.getStringList('favorite_language_pairs') ?? [];
  }

  /// Add favorite language pair
  static Future<void> addFavoriteLanguagePair(
      String sourceLang, String targetLang) async {
    final prefs = await _preferences;
    final favorites = await favoriteLanguagePairs;
    final pair = '$sourceLang-$targetLang';

    if (!favorites.contains(pair)) {
      favorites.add(pair);
      await prefs.setStringList('favorite_language_pairs', favorites);
    }
  }

  // ============ Permissions & Privacy ============

  /// Check if permission was requested
  static Future<bool> wasPermissionRequested(String permission) async {
    final prefs = await _preferences;
    return prefs.getBool('permission_requested_$permission') ?? false;
  }

  /// Mark permission as requested
  static Future<void> markPermissionAsRequested(String permission) async {
    final prefs = await _preferences;
    await prefs.setBool('permission_requested_$permission', true);
  }

  /// Get privacy consent status
  static Future<bool> get hasPrivacyConsent async {
    final prefs = await _preferences;
    return prefs.getBool('privacy_consent') ?? false;
  }

  /// Set privacy consent
  static Future<void> setPrivacyConsent(bool consent) async {
    final prefs = await _preferences;
    await prefs.setBool('privacy_consent', consent);
    if (consent) {
      await prefs.setString(
          'privacy_consent_date', DateTime.now().toIso8601String());
    }
  }

  // ============ Debug & Development ============

  /// Clear all preferences (for testing/debugging)
  static Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await _preferences;
    await prefs.remove(AppConstants.keyFirstLaunch);
    await prefs.remove('onboarding_completed');
    await prefs.remove('onboarding_completed_date');
  }

  /// Get all stored preferences (for debugging)
  static Future<Map<String, dynamic>> getAllPreferences() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys();
    final Map<String, dynamic> allPrefs = {};

    for (String key in keys) {
      final value = prefs.get(key);
      allPrefs[key] = value;
    }

    return allPrefs;
  }

  /// Get app usage statistics
  static Future<Map<String, dynamic>> getUsageStats() async {
    return {
      'launchCount': await launchCount,
      'translationCount': await translationCount,
      'onboardingCompleted': await hasCompletedOnboarding,
      'onboardingDate': await onboardingCompletedDate,
      'lastLaunchDate': await lastLaunchDate,
      'favoriteLanguagePairs': await favoriteLanguagePairs,
    };
  }
}
