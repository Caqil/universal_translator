import 'package:equatable/equatable.dart';
import '../../../translation/data/models/translation_mode_model.dart';
import '../../../translation/domain/entities/download_status.dart';
import '../../data/models/app_settings_model.dart';

/// Base class for all settings states
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when settings bloc is created
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// State when settings are being loaded
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// State when settings have been loaded successfully
class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  final TranslationMode translationMode;
  final bool isOfflineModeEnabled;
  final bool autoDownloadEnabled;
  final List<DownloadStatus> downloadedLanguages;
  const SettingsLoaded({
    required this.settings,
    required this.translationMode,
    required this.isOfflineModeEnabled,
    required this.autoDownloadEnabled,
    required this.downloadedLanguages,
  });

  @override
  List<Object?> get props => [
        settings,
        translationMode,
        isOfflineModeEnabled,
        autoDownloadEnabled,
        downloadedLanguages,
      ];
  SettingsLoaded copyWith({
    AppSettings? settings,
    TranslationMode? translationMode,
    bool? isOfflineModeEnabled,
    bool? autoDownloadEnabled,
    List<DownloadStatus>? downloadedLanguages,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      translationMode: translationMode ?? this.translationMode,
      isOfflineModeEnabled: isOfflineModeEnabled ?? this.isOfflineModeEnabled,
      autoDownloadEnabled: autoDownloadEnabled ?? this.autoDownloadEnabled,
      downloadedLanguages: downloadedLanguages ?? this.downloadedLanguages,
    );
  }
}

/// State when settings are being updated
class SettingsUpdating extends SettingsState {
  final AppSettings currentSettings;

  const SettingsUpdating(this.currentSettings);

  @override
  List<Object?> get props => [currentSettings];
}

/// State when settings have been updated successfully
class SettingsUpdated extends SettingsState {
  final AppSettings settings;
  final String? message;

  const SettingsUpdated(this.settings, {this.message});

  @override
  List<Object?> get props => [settings, message];
}

/// State when settings are being reset
class SettingsResetting extends SettingsState {
  const SettingsResetting();
}

/// State when settings have been reset successfully
class SettingsReset extends SettingsState {
  final AppSettings settings;

  const SettingsReset(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// State when settings are being exported
class SettingsExporting extends SettingsState {
  const SettingsExporting();
}

/// State when settings have been exported successfully
class SettingsExported extends SettingsState {
  final Map<String, dynamic> exportData;

  const SettingsExported(this.exportData);

  @override
  List<Object?> get props => [exportData];
}

/// State when settings are being imported
class SettingsImporting extends SettingsState {
  const SettingsImporting();
}

/// State when settings have been imported successfully
class SettingsImported extends SettingsState {
  final AppSettings settings;

  const SettingsImported(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// State when an error occurs with settings operations
class SettingsError extends SettingsState {
  final String message;
  final String? code;
  final AppSettings? currentSettings;

  const SettingsError(
    this.message, {
    this.code,
    this.currentSettings,
  });

  @override
  List<Object?> get props => [message, code, currentSettings];
}

/// State when settings validation fails
class SettingsValidationError extends SettingsState {
  final String message;
  final Map<String, String> fieldErrors;
  final AppSettings currentSettings;

  const SettingsValidationError(
    this.message,
    this.fieldErrors,
    this.currentSettings,
  );

  @override
  List<Object?> get props => [message, fieldErrors, currentSettings];
}

/// State when settings operation is completed with a message
class SettingsOperationCompleted extends SettingsState {
  final String message;
  final AppSettings settings;
  final SettingsOperationType operationType;

  const SettingsOperationCompleted(
    this.message,
    this.settings,
    this.operationType,
  );

  @override
  List<Object?> get props => [message, settings, operationType];
}

/// Types of settings operations
enum SettingsOperationType {
  update,
  reset,
  import,
  export,
  themeChange,
  languageChange,
  backup,
  restore,
}

/// Extension to provide user-friendly operation names
extension SettingsOperationTypeExtension on SettingsOperationType {
  String get displayName {
    switch (this) {
      case SettingsOperationType.update:
        return 'Settings Updated';
      case SettingsOperationType.reset:
        return 'Settings Reset';
      case SettingsOperationType.import:
        return 'Settings Imported';
      case SettingsOperationType.export:
        return 'Settings Exported';
      case SettingsOperationType.themeChange:
        return 'Theme Changed';
      case SettingsOperationType.languageChange:
        return 'Language Changed';
      case SettingsOperationType.backup:
        return 'Settings Backed Up';
      case SettingsOperationType.restore:
        return 'Settings Restored';
    }
  }

  String get description {
    switch (this) {
      case SettingsOperationType.update:
        return 'Your settings have been successfully updated.';
      case SettingsOperationType.reset:
        return 'All settings have been reset to default values.';
      case SettingsOperationType.import:
        return 'Settings have been imported successfully.';
      case SettingsOperationType.export:
        return 'Settings have been exported for backup.';
      case SettingsOperationType.themeChange:
        return 'App theme has been changed successfully.';
      case SettingsOperationType.languageChange:
        return 'App language has been changed successfully.';
      case SettingsOperationType.backup:
        return 'Settings backup has been created.';
      case SettingsOperationType.restore:
        return 'Settings have been restored from backup.';
    }
  }
}
