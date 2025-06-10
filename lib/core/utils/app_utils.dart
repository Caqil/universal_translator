// lib/core/utils/app_utils.dart
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_constants.dart';
import '../constants/language_constants.dart';
import '../themes/app_colors.dart';

/// Utility class containing commonly used helper functions throughout the app
class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  // ============ String Utilities ============

  /// Check if a string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if a string is not null and not empty
  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  /// Capitalize first letter of a string
  static String capitalize(String value) {
    if (isNullOrEmpty(value)) return '';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String value) {
    if (isNullOrEmpty(value)) return '';
    return value.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Remove extra whitespaces and trim
  static String cleanString(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Truncate string with ellipsis if it exceeds maxLength
  static String truncate(String value, int maxLength, {String suffix = '...'}) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Extract initials from a string (e.g., "John Doe" -> "JD")
  static String getInitials(String value, {int maxInitials = 2}) {
    if (isNullOrEmpty(value)) return '';
    
    final words = cleanString(value).split(' ');
    final initials = words
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .where((initial) => initial.isNotEmpty)
        .join();
    
    return initials;
  }

  /// Generate a random string of specified length
  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Convert string to slug format (URL-friendly)
  static String toSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'[-\s]+'), '-'); // Replace spaces and hyphens
  }

  /// Count words in a string
  static int countWords(String value) {
    if (isNullOrEmpty(value)) return 0;
    return cleanString(value).split(' ').length;
  }

  /// Count characters excluding whitespace
  static int countCharacters(String value, {bool includeSpaces = true}) {
    if (isNullOrEmpty(value)) return 0;
    return includeSpaces ? value.length : value.replaceAll(' ', '').length;
  }

  // ============ Number & Math Utilities ============

  /// Format number with thousand separators
  static String formatNumber(num value, {String locale = 'en_US'}) {
    final formatter = NumberFormat('#,##0', locale);
    return formatter.format(value);
  }

  /// Format currency
  static String formatCurrency(double value, {String locale = 'en_US', String symbol = '\$'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(value);
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    final formatter = NumberFormat.percentPattern();
    formatter.minimumFractionDigits = decimalPlaces;
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }

  /// Round to specific decimal places
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  /// Clamp value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Generate random number within range
  static int randomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  /// Generate random double within range
  static double randomDouble(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }

  // ============ DateTime Utilities ============

  /// Format date for display
  static String formatDate(DateTime date, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Format time for display
  static String formatTime(DateTime time, {bool use24Hour = false}) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern).format(time);
  }

  /// Format DateTime for display
  static String formatDateTime(DateTime dateTime, {String pattern = 'MMM dd, yyyy h:mm a'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// Get relative time (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.isNegative) {
      // Future dates
      final futureDiff = dateTime.difference(now);
      if (futureDiff.inDays > 0) {
        return 'in ${futureDiff.inDays} day${futureDiff.inDays == 1 ? '' : 's'}';
      } else if (futureDiff.inHours > 0) {
        return 'in ${futureDiff.inHours} hour${futureDiff.inHours == 1 ? '' : 's'}';
      } else if (futureDiff.inMinutes > 0) {
        return 'in ${futureDiff.inMinutes} minute${futureDiff.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'in a few seconds';
      }
    } else {
      // Past dates
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'just now';
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // ============ Platform & Device Utilities ============

  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  /// Check if running on desktop (Windows, macOS, or Linux)
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// Check if running on web
  static bool get isWeb => identical(0, 0.0);

  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;

  /// Get device info
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    Map<String, dynamic> info = {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      info.addAll({
        'platform': 'Android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'androidVersion': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      info.addAll({
        'platform': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemVersion': iosInfo.systemVersion,
        'identifierForVendor': iosInfo.identifierForVendor,
      });
    }
    
    return info;
  }

  // ============ UI Utilities ============

  /// Show snackbar with custom styling
  static void showSnackBar(
    BuildContext context, 
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = AppConstants.toastDuration,
    SnackBarAction? action,
  }) {
    final brightness = Theme.of(context).brightness;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? AppColors.primary(brightness)),
              const SizedBox(width: AppConstants.smallPadding),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.surface(brightness),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.lightSuccess,
      textColor: AppColors.lightSuccessForeground,
      icon: Icons.check_circle,
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    final brightness = Theme.of(context).brightness;
    showSnackBar(
      context,
      message,
      backgroundColor: brightness == Brightness.light 
          ? AppColors.lightDestructive 
          : AppColors.darkDestructive,
      textColor: brightness == Brightness.light 
          ? AppColors.lightDestructiveForeground 
          : AppColors.darkDestructiveForeground,
      icon: Icons.error,
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    final brightness = Theme.of(context).brightness;
    showSnackBar(
      context,
      message,
      backgroundColor: brightness == Brightness.light 
          ? AppColors.lightWarning 
          : AppColors.darkWarning,
      textColor: brightness == Brightness.light 
          ? AppColors.lightWarningForeground 
          : AppColors.darkWarningForeground,
      icon: Icons.warning,
    );
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Check if screen is small (phone)
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context).width <= 600;
  }

  /// Check if screen is medium (tablet)
  static bool isMediumScreen(BuildContext context) {
    final width = getScreenSize(context).width;
    return width > 600 && width <= 1024;
  }

  /// Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return getScreenSize(context).width > 1024;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // ============ Clipboard Utilities ============

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Paste text from clipboard
  static Future<String?> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    return clipboardData?.text;
  }

  // ============ URL & Sharing Utilities ============

  /// Launch URL
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }

  /// Launch email
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'),
    );
    
    return await launchURL(uri.toString());
  }

  /// Launch phone dialer
  static Future<bool> launchPhone(String phoneNumber) async {
    return await launchURL('tel:$phoneNumber');
  }

  /// Share text
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Share files
  static Future<void> shareFiles(List<String> paths, {String? text, String? subject}) async {
    await Share.shareXFiles(
      paths.map((path) => XFile(path)).toList(),
      text: text,
      subject: subject,
    );
  }

  // ============ Vibration & Haptics ============

  /// Trigger light haptic feedback
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Trigger medium haptic feedback
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Trigger heavy haptic feedback
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Trigger selection haptic feedback
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // ============ JSON & Encoding Utilities ============

  /// Safe JSON encode
  static String? safeJsonEncode(dynamic object) {
    try {
      return jsonEncode(object);
    } catch (e) {
      return null;
    }
  }

  /// Safe JSON decode
  static dynamic safeJsonDecode(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Encode string to Base64
  static String encodeBase64(String text) {
    return base64Encode(utf8.encode(text));
  }

  /// Decode Base64 string
  static String? decodeBase64(String base64Text) {
    try {
      return utf8.decode(base64Decode(base64Text));
    } catch (e) {
      return null;
    }
  }

  // ============ Color Utilities ============

  /// Generate random color
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  /// Get contrast color (black or white) for given background
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Darken color by percentage
  static Color darkenColor(Color color, double percentage) {
    assert(percentage >= 0 && percentage <= 1);
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness * (1 - percentage)).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  /// Lighten color by percentage
  static Color lightenColor(Color color, double percentage) {
    assert(percentage >= 0 && percentage <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + (1 - hsl.lightness) * percentage).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  // ============ Translation App Specific Utilities ============

  /// Get language display name
  static String getLanguageDisplayName(String languageCode) {
    if (languageCode == LanguageConstants.autoDetectCode) {
      return LanguageConstants.autoDetectName;
    }
    return LanguageConstants.getLanguageName(languageCode);
  }

  /// Get language native name
  static String getLanguageNativeName(String languageCode) {
    if (languageCode == LanguageConstants.autoDetectCode) {
      return LanguageConstants.autoDetectNativeName;
    }
    return LanguageConstants.getLanguageNativeName(languageCode);
  }

  /// Get language flag emoji
  static String getLanguageFlag(String languageCode) {
    if (languageCode == LanguageConstants.autoDetectCode) {
      return '🌍';
    }
    return LanguageConstants.getLanguageFlag(languageCode);
  }

  /// Format translation confidence score
  static String formatConfidence(double confidence) {
    final percentage = (confidence * 100).round();
    return '$percentage%';
  }

  /// Get confidence color based on score
  static Color getConfidenceColor(double confidence) {
    if (confidence >= LanguageConstants.highConfidenceThreshold) {
      return AppColors.highConfidence;
    } else if (confidence >= LanguageConstants.mediumConfidenceThreshold) {
      return AppColors.mediumConfidence;
    } else {
      return AppColors.lowConfidence;
    }
  }

  /// Check if text exceeds maximum translation length
  static bool exceedsMaxLength(String text) {
    return text.length > AppConstants.maxTextLength;
  }

  /// Get translation text length warning message
  static String? getLengthWarningMessage(String text) {
    final length = text.length;
    final maxLength = AppConstants.maxTextLength;
    
    if (length > maxLength) {
      return 'Text exceeds maximum length of $maxLength characters';
    } else if (length > maxLength * 0.9) {
      final remaining = maxLength - length;
      return '$remaining characters remaining';
    }
    
    return null;
  }

  /// Estimate translation time based on text length
  static Duration estimateTranslationTime(String text) {
    final words = countWords(text);
    final baseTime = 500; // 500ms base time
    final timePerWord = 50; // 50ms per word
    
    final totalMs = baseTime + (words * timePerWord);
    return Duration(milliseconds: totalMs);
  }

  /// Generate unique translation ID
  static String generateTranslationId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${generateRandomString(8)}';
  }

  /// Clean text for translation (remove extra spaces, normalize)
  static String cleanTextForTranslation(String text) {
    return cleanString(text)
        .replaceAll(RegExp(r'\n+'), '\n') // Normalize line breaks
        .replaceAll(RegExp(r'\t+'), ' '); // Replace tabs with spaces
  }

  /// Split long text into chunks for translation
  static List<String> splitTextForTranslation(String text, {int maxChunkSize = 4000}) {
    if (text.length <= maxChunkSize) return [text];
    
    final chunks = <String>[];
    final sentences = text.split(RegExp(r'[.!?]+\s*'));
    
    String currentChunk = '';
    for (final sentence in sentences) {
      if ((currentChunk + sentence).length <= maxChunkSize) {
        currentChunk += (currentChunk.isEmpty ? '' : '. ') + sentence;
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk);
          currentChunk = sentence;
        } else {
          // Single sentence too long, split by words
          final words = sentence.split(' ');
          String wordChunk = '';
          for (final word in words) {
            if ((wordChunk + word).length <= maxChunkSize) {
              wordChunk += (wordChunk.isEmpty ? '' : ' ') + word;
            } else {
              if (wordChunk.isNotEmpty) {
                chunks.add(wordChunk);
                wordChunk = word;
              } else {
                // Single word too long, add as is
                chunks.add(word);
              }
            }
          }
          if (wordChunk.isNotEmpty) {
            currentChunk = wordChunk;
          }
        }
      }
    }
    
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }
    
    return chunks;
  }

  // ============ Debug & Development Utilities ============

  /// Log debug message (only in debug mode)
  static void debugLog(String message, {String? tag}) {
    assert(() {
      final timestamp = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
      final logTag = tag ?? 'AppUtils';
      print('[$timestamp] [$logTag] $message');
      return true;
    }());
  }

  /// Pretty print JSON (only in debug mode)
  static void debugPrintJson(dynamic object, {String? tag}) {
    assert(() {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyString = encoder.convert(object);
        debugLog('JSON:\n$prettyString', tag: tag);
      } catch (e) {
        debugLog('Failed to pretty print JSON: $e', tag: tag);
      }
      return true;
    }());
  }
}
