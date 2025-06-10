import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../constants/language_constants.dart';
import '../themes/app_colors.dart';
import 'app_utils.dart';

// ============ String Extensions ============

extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => AppUtils.isNullOrEmpty(this);

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => AppUtils.isNotNullOrEmpty(this);

  /// Capitalize first letter
  String get capitalized => AppUtils.capitalize(this);

  /// Capitalize first letter of each word
  String get capitalizedWords => AppUtils.capitalizeWords(this);

  /// Clean string (remove extra whitespaces)
  String get cleaned => AppUtils.cleanString(this);

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    return AppUtils.truncate(this, maxLength, suffix: suffix);
  }

  /// Get initials from string
  String get initials => AppUtils.getInitials(this);

  /// Convert to slug format
  String get slug => AppUtils.toSlug(this);

  /// Count words
  int get wordCount => AppUtils.countWords(this);

  /// Count characters (excluding spaces by default)
  int characterCount({bool includeSpaces = false}) {
    return AppUtils.countCharacters(this, includeSpaces: includeSpaces);
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(AppConstants.emailRegex).hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    return RegExp(AppConstants.urlRegex).hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhoneNumber {
    return RegExp(AppConstants.phoneRegex).hasMatch(this);
  }

  /// Check if string contains only digits
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Check if string contains only letters
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string is alphanumeric
  bool get isAlphaNumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Remove HTML tags
  String get removeHtmlTags {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Reverse string
  String get reversed {
    return split('').reversed.join('');
  }

  /// Convert to integer safely
  int? get toIntOrNull {
    return int.tryParse(this);
  }

  /// Convert to double safely
  double? get toDoubleOrNull {
    return double.tryParse(this);
  }

  /// Convert to DateTime safely
  DateTime? get toDateTimeOrNull {
    return DateTime.tryParse(this);
  }

  /// Check if string is a supported language code
  bool get isSupportedLanguage {
    return LanguageConstants.isLanguageSupported(this);
  }

  /// Get language name from code
  String get languageName {
    return LanguageConstants.getLanguageName(this);
  }

  /// Get language native name from code
  String get languageNativeName {
    return LanguageConstants.getLanguageNativeName(this);
  }

  /// Get language flag from code
  String get languageFlag {
    return LanguageConstants.getLanguageFlag(this);
  }

  /// Check if language is RTL
  bool get isRtlLanguage {
    return LanguageConstants.isRtlLanguage(this);
  }

  /// Mask sensitive information (e.g., email, phone)
  String mask(
      {int visibleStart = 2, int visibleEnd = 2, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;

    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final maskLength = length - visibleStart - visibleEnd;

    return start + (maskChar * maskLength) + end;
  }

  /// Extract numbers from string
  String get numbersOnly {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Extract letters from string
  String get lettersOnly {
    return replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Check if string exceeds maximum translation length
  bool get exceedsMaxTranslationLength {
    return AppUtils.exceedsMaxLength(this);
  }

  /// Clean text for translation
  String get cleanedForTranslation {
    return AppUtils.cleanTextForTranslation(this);
  }

  /// Split text for translation
  List<String> splitForTranslation({int maxChunkSize = 4000}) {
    return AppUtils.splitTextForTranslation(this, maxChunkSize: maxChunkSize);
  }
}

// ============ Nullable String Extensions ============

extension NullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => AppUtils.isNullOrEmpty(this);

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => AppUtils.isNotNullOrEmpty(this);

  /// Get string or default value
  String orDefault([String defaultValue = '']) {
    return isNullOrEmpty ? defaultValue : this!;
  }

  /// Get initials or default
  String initialsOrDefault([String defaultValue = '??']) {
    return isNullOrEmpty ? defaultValue : this!.initials;
  }
}

// ============ Number Extensions ============

extension IntExtensions on int {
  /// Format with thousand separators
  String get formatted => AppUtils.formatNumber(this);

  /// Convert to ordinal string (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';

    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Check if number is even
  bool get isEven => this % 2 == 0;

  /// Check if number is odd
  bool get isOdd => this % 2 != 0;

  /// Convert milliseconds to Duration
  Duration get milliseconds => Duration(milliseconds: this);

  /// Convert seconds to Duration
  Duration get seconds => Duration(seconds: this);

  /// Convert minutes to Duration
  Duration get minutes => Duration(minutes: this);

  /// Convert hours to Duration
  Duration get hours => Duration(hours: this);

  /// Convert days to Duration
  Duration get days => Duration(days: this);
}

extension DoubleExtensions on double {
  /// Format with thousand separators
  String get formatted => AppUtils.formatNumber(this);

  /// Format as currency
  String currency({String locale = 'en_US', String symbol = '\$'}) {
    return AppUtils.formatCurrency(this, locale: locale, symbol: symbol);
  }

  /// Format as percentage
  String percentage({int decimalPlaces = 1}) {
    return AppUtils.formatPercentage(this, decimalPlaces: decimalPlaces);
  }

  /// Round to decimal places
  double roundToDecimals(int decimalPlaces) {
    return AppUtils.roundToDecimalPlaces(this, decimalPlaces);
  }

  /// Check if number is between min and max
  bool isBetween(double min, double max) {
    return this >= min && this <= max;
  }

  /// Clamp between min and max
  double clampTo(double min, double max) {
    return AppUtils.clamp(this, min, max);
  }

  /// Convert to radians
  double get radians => this * pi / 180;

  /// Convert to degrees
  double get degrees => this * 180 / pi;
}

// ============ DateTime Extensions ============

extension DateTimeExtensions on DateTime {
  /// Format for display
  String format([String pattern = 'MMM dd, yyyy']) {
    return AppUtils.formatDate(this, pattern: pattern);
  }

  /// Format time
  String formatTime({bool use24Hour = false}) {
    return AppUtils.formatTime(this, use24Hour: use24Hour);
  }

  /// Format date and time
  String formatDateTime([String pattern = 'MMM dd, yyyy h:mm a']) {
    return AppUtils.formatDateTime(this, pattern: pattern);
  }

  /// Get relative time
  String get relativeTime => AppUtils.getRelativeTime(this);

  /// Check if date is today
  bool get isToday => AppUtils.isToday(this);

  /// Check if date is yesterday
  bool get isYesterday => AppUtils.isYesterday(this);

  /// Check if date is this week
  bool get isThisWeek => AppUtils.isThisWeek(this);

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999, 999);
  }

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1));
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday));
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999, 999);
  }

  /// Get age from this date
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    DateTime date = this;
    int addedDays = 0;

    while (addedDays < days) {
      date = date.add(const Duration(days: 1));
      if (date.weekday <= 5) {
        // Monday to Friday
        addedDays++;
      }
    }

    return date;
  }

  /// Check if date is weekend
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if date is weekday
  bool get isWeekday => !isWeekend;
}

// ============ Duration Extensions ============

extension DurationExtensions on Duration {
  /// Format duration as human readable string
  String get formatted {
    if (inDays > 0) {
      return '${inDays}d ${inHours.remainder(24)}h ${inMinutes.remainder(60)}m';
    } else if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    } else if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Format as short string (e.g., "2h 30m")
  String get shortFormat {
    if (inDays > 0) {
      return '${inDays}d';
    } else if (inHours > 0) {
      return '${inHours}h';
    } else if (inMinutes > 0) {
      return '${inMinutes}m';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Format as time string (HH:MM:SS)
  String get timeFormat {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

// ============ List Extensions ============

extension ListExtensions<T> on List<T> {
  /// Get random element from list
  T? get randomElement {
    if (isEmpty) return null;
    final random = Random();
    return this[random.nextInt(length)];
  }

  /// Get multiple random elements
  List<T> randomElements(int count) {
    if (isEmpty || count <= 0) return [];
    final shuffled = List<T>.from(this)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Check if list has duplicates
  bool get hasDuplicates => length != toSet().length;

  /// Remove duplicates while preserving order
  List<T> get withoutDuplicates {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }

  /// Split list into chunks of specified size
  List<List<T>> chunk(int size) {
    if (size <= 0) return [];

    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, math.min(i + size, length)));
    }
    return chunks;
  }

  /// Get element at index or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get element at index or default value
  T elementAtOrDefault(int index, T defaultValue) {
    return elementAtOrNull(index) ?? defaultValue;
  }

  /// Check if all elements satisfy condition
  bool all(bool Function(T) predicate) {
    return every(predicate);
  }

  /// Check if any element satisfies condition
  bool any(bool Function(T) predicate) {
    return any(predicate);
  }

  /// Get first element or null if empty
  T? get firstOrNull => isNotEmpty ? first : null;

  /// Get last element or null if empty
  T? get lastOrNull => isNotEmpty ? last : null;

  /// Get second element or null if less than 2 elements
  T? get secondOrNull => length >= 2 ? this[1] : null;

  /// Get second to last element or null
  T? get secondToLastOrNull => length >= 2 ? this[length - 2] : null;
}

// ============ Map Extensions ============

extension MapExtensions<K, V> on Map<K, V> {
  /// Get value or default if key doesn't exist
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  /// Get value or null if key doesn't exist
  V? getOrNull(K key) {
    return this[key];
  }

  /// Filter map by predicate
  Map<K, V> whereKey(bool Function(K) predicate) {
    return Map.fromEntries(entries.where((entry) => predicate(entry.key)));
  }

  /// Filter map by value predicate
  Map<K, V> whereValue(bool Function(V) predicate) {
    return Map.fromEntries(entries.where((entry) => predicate(entry.value)));
  }

  /// Transform values while keeping keys
  Map<K, R> mapValues<R>(R Function(V) transform) {
    return map((key, value) => MapEntry(key, transform(value)));
  }

  /// Transform keys while keeping values
  Map<R, V> mapKeys<R>(R Function(K) transform) {
    return map((key, value) => MapEntry(transform(key), value));
  }
}

// ============ BuildContext Extensions ============

extension BuildContextExtensions on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Get bottom padding (for keyboards, etc.)
  double get bottomPadding => mediaQuery.viewInsets.bottom;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => bottomPadding > 0;

  /// Check if device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Check if screen is small (phone)
  bool get isSmallScreen => AppUtils.isSmallScreen(this);

  /// Check if screen is medium (tablet)
  bool get isMediumScreen => AppUtils.isMediumScreen(this);

  /// Check if screen is large (desktop)
  bool get isLargeScreen => AppUtils.isLargeScreen(this);

  /// Hide keyboard
  void hideKeyboard() => AppUtils.hideKeyboard(this);

  /// Show success snackbar
  void showSuccess(String message) =>
      AppUtils.showSuccessSnackBar(this, message);

  /// Show error snackbar
  void showError(String message) => AppUtils.showErrorSnackBar(this, message);

  /// Show warning snackbar
  void showWarning(String message) =>
      AppUtils.showWarningSnackBar(this, message);

  /// Show info snackbar
  void showInfo(String message) => AppUtils.showSnackBar(this, message);

  /// Get brightness
  Brightness get brightness => theme.brightness;

  /// Check if dark mode
  bool get isDarkMode => brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => brightness == Brightness.light;

  /// Get adaptive color
  Color adaptiveColor({required Color light, required Color dark}) {
    return AppColors.adaptive(light: light, dark: dark, brightness: brightness);
  }

  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push and remove until
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Pop current route
  void pop<T>([T? result]) => Navigator.of(this).pop<T>(result);

  /// Check if can pop
  bool get canPop => Navigator.of(this).canPop();
}

// ============ Color Extensions ============

extension ColorExtensions on Color {
  /// Get contrast color (black or white)
  Color get contrastColor => AppUtils.getContrastColor(this);

  /// Darken color by percentage
  Color darken(double percentage) => AppUtils.darkenColor(this, percentage);

  /// Lighten color by percentage
  Color lighten(double percentage) => AppUtils.lightenColor(this, percentage);

  /// Convert to hex string
  String get hexString {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Get luminance level description
  String get luminanceDescription {
    final luminance = computeLuminance();
    if (luminance > 0.7) return 'Very Light';
    if (luminance > 0.5) return 'Light';
    if (luminance > 0.3) return 'Medium';
    if (luminance > 0.1) return 'Dark';
    return 'Very Dark';
  }
}
