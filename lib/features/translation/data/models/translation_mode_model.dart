// lib/features/translation/data/models/translation_mode_model.dart
enum TranslationMode {
  online,
  offline,
  auto, // Automatically choose based on connectivity
}

extension TranslationModeExtension on TranslationMode {
  String get displayName {
    switch (this) {
      case TranslationMode.online:
        return 'Online';
      case TranslationMode.offline:
        return 'Offline';
      case TranslationMode.auto:
        return 'Auto';
    }
  }
}
