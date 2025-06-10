class AppConstants {
  // App Info
  static const String appName = 'Universal Translator';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String packageName = 'com.example.translate_app';

  // App Settings
  static const String defaultLanguageCode = 'en';
  static const String autoDetectLanguageCode = 'auto';

  // Durations & Timeouts
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Duration speechTimeoutDuration = Duration(seconds: 30);
  static const Duration speechListeningDuration = Duration(seconds: 10);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration splashScreenDuration = Duration(seconds: 2);

  // Limits & Constraints
  static const int maxTextLength = 5000;
  static const int maxHistoryItems = 1000;
  static const int maxFavoriteItems = 500;
  static const int maxConversationMessages = 100;
  static const int minSearchQueryLength = 2;
  static const int maxRecentLanguages = 5;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double circleBorderRadius = 50.0;

  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeExtraLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeRegular = 24.0;
  static const double iconSizeMedium = 28.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Storage Keys - Hive Boxes
  static const String historyBoxName = 'history_box';
  static const String favoritesBoxName = 'favorites_box';
  static const String settingsBoxName = 'settings_box';
  static const String languagesBoxName = 'languages_box';
  static const String conversationsBoxName = 'conversations_box';

  // Storage Keys - SharedPreferences
  static const String keyFirstLaunch = 'first_launch';
  static const String keySelectedSourceLanguage = 'selected_source_language';
  static const String keySelectedTargetLanguage = 'selected_target_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyAutoDetectLanguage = 'auto_detect_language';
  static const String keyVoiceInputEnabled = 'voice_input_enabled';
  static const String keyTextToSpeechEnabled = 'text_to_speech_enabled';
  static const String keyOfflineMode = 'offline_mode';
  static const String keyLibreTranslateUrl = 'libretranslate_url';
  static const String keyLibreTranslateApiKey = 'libretranslate_api_key';
  static const String keyRecentLanguages = 'recent_languages';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyAutoSaveTranslations = 'auto_save_translations';
  static const String keyConversationMode = 'conversation_mode';
  static const String keyCameraTranslationEnabled =
      'camera_translation_enabled';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableCameraTranslation = true;
  static const bool enableConversationMode = true;
  static const bool enableVoiceTranslation = true;
  static const bool enableFavorites = true;
  static const bool enableHistory = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = false;

  // File Extensions
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp'
  ];
  static const List<String> supportedAudioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.m4a'
  ];

  // Regular Expressions
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlRegex =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';

  // Error Messages
  static const String errorGeneral = 'An unexpected error occurred';
  static const String errorNetwork =
      'Network error. Please check your connection';
  static const String errorServer = 'Server error. Please try again later';
  static const String errorCache = 'Local storage error';
  static const String errorPermission = 'Permission denied';
  static const String errorTimeout = 'Request timeout. Please try again';
  static const String errorNotFound = 'Resource not found';
  static const String errorInvalidInput = 'Invalid input provided';
  static const String errorEmptyText = 'Please enter text to translate';
  static const String errorLanguageNotSelected = 'Please select a language';
  static const String errorMicrophonePermission =
      'Microphone permission required';
  static const String errorCameraPermission = 'Camera permission required';
  static const String errorStoragePermission = 'Storage permission required';

  // Success Messages
  static const String successTranslationSaved =
      'Translation saved successfully';
  static const String successAddedToFavorites = 'Added to favorites';
  static const String successRemovedFromFavorites = 'Removed from favorites';
  static const String successSettingsSaved = 'Settings saved successfully';
  static const String successHistoryCleared = 'History cleared successfully';
  static const String successTextCopied = 'Text copied to clipboard';

  // Loading Messages
  static const String loadingTranslating = 'Translating...';
  static const String loadingDetectingLanguage = 'Detecting language...';
  static const String loadingListening = 'Listening...';
  static const String loadingProcessingImage = 'Processing image...';
  static const String loadingLoadingLanguages = 'Loading languages...';

  // Placeholder Texts
  static const String placeholderEnterText = 'Enter text to translate';
  static const String placeholderTranslation = 'Translation will appear here';
  static const String placeholderSearch = 'Search translations...';
  static const String placeholderEmptyHistory = 'No translation history yet';
  static const String placeholderEmptyFavorites =
      'No favorite translations yet';
  static const String placeholderEmptyConversation = 'Start a conversation';

  // Button Labels
  static const String buttonTranslate = 'Translate';
  static const String buttonListen = 'Listen';
  static const String buttonSpeak = 'Speak';
  static const String buttonCopy = 'Copy';
  static const String buttonShare = 'Share';
  static const String buttonSave = 'Save';
  static const String buttonCancel = 'Cancel';
  static const String buttonDelete = 'Delete';
  static const String buttonEdit = 'Edit';
  static const String buttonRetry = 'Retry';
  static const String buttonSettings = 'Settings';
  static const String buttonClear = 'Clear';
  static const String buttonDone = 'Done';
  static const String buttonNext = 'Next';
  static const String buttonPrevious = 'Previous';
  static const String buttonSkip = 'Skip';
  static const String buttonGetStarted = 'Get Started';

  // Action Labels
  static const String actionSwapLanguages = 'Swap Languages';
  static const String actionDetectLanguage = 'Auto-detect';
  static const String actionClearText = 'Clear Text';
  static const String actionClearHistory = 'Clear History';
  static const String actionSelectAll = 'Select All';
  static const String actionPasteFromClipboard = 'Paste';

  // Privacy & Legal
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'support@example.com';
  static const String githubUrl = 'https://github.com/example/translate_app';

  // App Store & Play Store
  static const String appStoreId = '123456789';
  static const String playStoreId = 'com.example.translate_app';

  // Social Media
  static const String twitterUrl = 'https://twitter.com/example';
  static const String facebookUrl = 'https://facebook.com/example';
  static const String linkedinUrl = 'https://linkedin.com/company/example';
}
