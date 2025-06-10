import '../constants/app_constants.dart';
import '../constants/language_constants.dart';
import 'app_utils.dart';

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorCode;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorCode,
  });

  /// Create a valid result
  const ValidationResult.valid() : this(isValid: true);

  /// Create an invalid result with error message
  const ValidationResult.invalid(String errorMessage, [String? errorCode])
      : this(isValid: false, errorMessage: errorMessage, errorCode: errorCode);

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: $errorMessage';
  }
}

/// Validator function type
typedef Validator<T> = ValidationResult Function(T value);

/// Utility class for common validation functions
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // ============ Basic Validators ============

  /// Validate that value is not null
  static ValidationResult required<T>(T? value, [String? fieldName]) {
    if (value == null) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Field'} is required',
        'REQUIRED',
      );
    }
    return const ValidationResult.valid();
  }

  /// Validate that string is not null or empty
  static ValidationResult requiredString(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Field'} is required',
        'REQUIRED',
      );
    }
    return const ValidationResult.valid();
  }

  /// Validate string length
  static ValidationResult stringLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null) return const ValidationResult.valid();

    final length = value.length;
    final field = fieldName ?? 'Field';

    if (minLength != null && length < minLength) {
      return ValidationResult.invalid(
        '$field must be at least $minLength characters long',
        'MIN_LENGTH',
      );
    }

    if (maxLength != null && length > maxLength) {
      return ValidationResult.invalid(
        '$field must not exceed $maxLength characters',
        'MAX_LENGTH',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate numeric range
  static ValidationResult numericRange<T extends num>(
    T? value, {
    T? min,
    T? max,
    String? fieldName,
  }) {
    if (value == null) return const ValidationResult.valid();

    final field = fieldName ?? 'Value';

    if (min != null && value < min) {
      return ValidationResult.invalid(
        '$field must be at least $min',
        'MIN_VALUE',
      );
    }

    if (max != null && value > max) {
      return ValidationResult.invalid(
        '$field must not exceed $max',
        'MAX_VALUE',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate using regular expression
  static ValidationResult pattern(
    String? value,
    RegExp pattern,
    String errorMessage, [
    String? errorCode,
  ]) {
    if (value == null || value.isEmpty) return const ValidationResult.valid();

    if (!pattern.hasMatch(value)) {
      return ValidationResult.invalid(errorMessage, errorCode);
    }

    return const ValidationResult.valid();
  }

  // ============ Email Validators ============

  /// Validate email format
  static ValidationResult email(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    return pattern(
      value,
      RegExp(AppConstants.emailRegex),
      '${fieldName ?? 'Email'} format is invalid',
      'INVALID_EMAIL',
    );
  }

  /// Validate required email
  static ValidationResult requiredEmail(String? value, [String? fieldName]) {
    final requiredResult = requiredString(value, fieldName ?? 'Email');
    if (!requiredResult.isValid) return requiredResult;

    return email(value, fieldName);
  }

  // ============ URL Validators ============

  /// Validate URL format
  static ValidationResult url(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    return pattern(
      value,
      RegExp(AppConstants.urlRegex),
      '${fieldName ?? 'URL'} format is invalid',
      'INVALID_URL',
    );
  }

  /// Validate required URL
  static ValidationResult requiredUrl(String? value, [String? fieldName]) {
    final requiredResult = requiredString(value, fieldName ?? 'URL');
    if (!requiredResult.isValid) return requiredResult;

    return url(value, fieldName);
  }

  // ============ Phone Number Validators ============

  /// Validate phone number format
  static ValidationResult phoneNumber(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    return pattern(
      value,
      RegExp(AppConstants.phoneRegex),
      '${fieldName ?? 'Phone number'} format is invalid',
      'INVALID_PHONE',
    );
  }

  /// Validate required phone number
  static ValidationResult requiredPhoneNumber(String? value,
      [String? fieldName]) {
    final requiredResult = requiredString(value, fieldName ?? 'Phone number');
    if (!requiredResult.isValid) return requiredResult;

    return phoneNumber(value, fieldName);
  }

  // ============ Password Validators ============

  /// Validate password strength
  static ValidationResult password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
    String? fieldName,
  }) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    final field = fieldName ?? 'Password';
    final password = value!;

    // Check minimum length
    if (password.length < minLength) {
      return ValidationResult.invalid(
        '$field must be at least $minLength characters long',
        'PASSWORD_TOO_SHORT',
      );
    }

    // Check for uppercase letter
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(password)) {
      return ValidationResult.invalid(
        '$field must contain at least one uppercase letter',
        'PASSWORD_MISSING_UPPERCASE',
      );
    }

    // Check for lowercase letter
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(password)) {
      return ValidationResult.invalid(
        '$field must contain at least one lowercase letter',
        'PASSWORD_MISSING_LOWERCASE',
      );
    }

    // Check for numbers
    if (requireNumbers && !RegExp(r'[0-9]').hasMatch(password)) {
      return ValidationResult.invalid(
        '$field must contain at least one number',
        'PASSWORD_MISSING_NUMBER',
      );
    }

    // Check for special characters
    if (requireSpecialChars &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return ValidationResult.invalid(
        '$field must contain at least one special character',
        'PASSWORD_MISSING_SPECIAL',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate required password
  static ValidationResult requiredPassword(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
    String? fieldName,
  }) {
    final requiredResult = requiredString(value, fieldName ?? 'Password');
    if (!requiredResult.isValid) return requiredResult;

    return password(
      value,
      minLength: minLength,
      requireUppercase: requireUppercase,
      requireLowercase: requireLowercase,
      requireNumbers: requireNumbers,
      requireSpecialChars: requireSpecialChars,
      fieldName: fieldName,
    );
  }

  /// Validate password confirmation
  static ValidationResult confirmPassword(
    String? password,
    String? confirmPassword, [
    String? fieldName,
  ]) {
    if (AppUtils.isNullOrEmpty(confirmPassword)) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Password confirmation'} is required',
        'REQUIRED',
      );
    }

    if (password != confirmPassword) {
      return ValidationResult.invalid(
        'Passwords do not match',
        'PASSWORD_MISMATCH',
      );
    }

    return const ValidationResult.valid();
  }

  // ============ Numeric Validators ============

  /// Validate integer
  static ValidationResult integer(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    if (int.tryParse(value!) == null) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Value'} must be a valid integer',
        'INVALID_INTEGER',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate decimal number
  static ValidationResult decimal(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    if (double.tryParse(value!) == null) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Value'} must be a valid number',
        'INVALID_DECIMAL',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate positive number
  static ValidationResult positiveNumber(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    final number = double.tryParse(value!);
    if (number == null) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Value'} must be a valid number',
        'INVALID_NUMBER',
      );
    }

    if (number <= 0) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Value'} must be a positive number',
        'NOT_POSITIVE',
      );
    }

    return const ValidationResult.valid();
  }

  // ============ Date Validators ============

  /// Validate date format
  static ValidationResult date(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    if (DateTime.tryParse(value!) == null) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Date'} format is invalid',
        'INVALID_DATE',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate date is in the past
  static ValidationResult pastDate(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    final dateResult = date(value, fieldName);
    if (!dateResult.isValid) return dateResult;

    final parsedDate = DateTime.parse(value!);
    if (!parsedDate.isBefore(DateTime.now())) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Date'} must be in the past',
        'NOT_PAST_DATE',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate date is in the future
  static ValidationResult futureDate(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    final dateResult = date(value, fieldName);
    if (!dateResult.isValid) return dateResult;

    final parsedDate = DateTime.parse(value!);
    if (!parsedDate.isAfter(DateTime.now())) {
      return ValidationResult.invalid(
        '${fieldName ?? 'Date'} must be in the future',
        'NOT_FUTURE_DATE',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate age
  static ValidationResult age(
    String? value, {
    int minAge = 0,
    int maxAge = 150,
    String? fieldName,
  }) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    final dateResult = date(value, fieldName);
    if (!dateResult.isValid) return dateResult;

    final birthDate = DateTime.parse(value!);
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;

    if (age < minAge) {
      return ValidationResult.invalid(
        'Age must be at least $minAge years',
        'AGE_TOO_YOUNG',
      );
    }

    if (age > maxAge) {
      return ValidationResult.invalid(
        'Age must not exceed $maxAge years',
        'AGE_TOO_OLD',
      );
    }

    return const ValidationResult.valid();
  }

  // ============ Translation App Specific Validators ============

  /// Validate translation text
  static ValidationResult translationText(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) {
      return ValidationResult.invalid(
        AppConstants.errorEmptyText,
        'EMPTY_TEXT',
      );
    }

    final cleanText = value!.trim();

    // Check minimum length
    if (cleanText.length < AppConstants.minSearchQueryLength) {
      return ValidationResult.invalid(
        'Text must be at least ${AppConstants.minSearchQueryLength} characters long',
        'TEXT_TOO_SHORT',
      );
    }

    // Check maximum length
    if (cleanText.length > AppConstants.maxTextLength) {
      return ValidationResult.invalid(
        'Text exceeds maximum length of ${AppConstants.maxTextLength} characters',
        'TEXT_TOO_LONG',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate language code
  static ValidationResult languageCode(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) {
      return ValidationResult.invalid(
        AppConstants.errorLanguageNotSelected,
        'LANGUAGE_NOT_SELECTED',
      );
    }

    if (value != LanguageConstants.autoDetectCode &&
        !LanguageConstants.isLanguageSupported(value!)) {
      return ValidationResult.invalid(
        'Language code "$value" is not supported',
        'LANGUAGE_NOT_SUPPORTED',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate LibreTranslate API URL
  static ValidationResult libreTranslateUrl(String? value,
      [String? fieldName]) {
    final requiredResult =
        requiredString(value, fieldName ?? 'LibreTranslate URL');
    if (!requiredResult.isValid) return requiredResult;

    final urlResult = url(value, fieldName);
    if (!urlResult.isValid) return urlResult;

    // Additional validation for LibreTranslate URL
    final uri = Uri.tryParse(value!);
    if (uri == null) {
      return ValidationResult.invalid(
        'Invalid URL format',
        'INVALID_URL_FORMAT',
      );
    }

    if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
      return ValidationResult.invalid(
        'URL must start with http:// or https://',
        'INVALID_URL_SCHEME',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate API key format
  static ValidationResult apiKey(String? value, [String? fieldName]) {
    if (AppUtils.isNullOrEmpty(value)) return const ValidationResult.valid();

    final key = value!.trim();

    // Check minimum length for API key
    if (key.length < 8) {
      return ValidationResult.invalid(
        'API key must be at least 8 characters long',
        'API_KEY_TOO_SHORT',
      );
    }

    // Check maximum length for API key
    if (key.length > 128) {
      return ValidationResult.invalid(
        'API key must not exceed 128 characters',
        'API_KEY_TOO_LONG',
      );
    }

    // Check for valid characters (alphanumeric, hyphens, underscores)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(key)) {
      return ValidationResult.invalid(
        'API key contains invalid characters',
        'API_KEY_INVALID_CHARS',
      );
    }

    return const ValidationResult.valid();
  }

  // ============ Composite Validators ============

  /// Combine multiple validators with AND logic
  static Validator<T> and<T>(List<Validator<T>> validators) {
    return (T value) {
      for (final validator in validators) {
        final result = validator(value);
        if (!result.isValid) return result;
      }
      return const ValidationResult.valid();
    };
  }

  /// Combine multiple validators with OR logic
  static Validator<T> or<T>(List<Validator<T>> validators) {
    return (T value) {
      final errors = <String>[];

      for (final validator in validators) {
        final result = validator(value);
        if (result.isValid) return result;
        if (result.errorMessage != null) {
          errors.add(result.errorMessage!);
        }
      }

      return ValidationResult.invalid(
        'All validations failed: ${errors.join(', ')}',
        'ALL_VALIDATIONS_FAILED',
      );
    };
  }

  /// Create conditional validator
  static Validator<T> when<T>(
    bool Function(T) condition,
    Validator<T> validator,
  ) {
    return (T value) {
      if (condition(value)) {
        return validator(value);
      }
      return const ValidationResult.valid();
    };
  }

  // ============ Form Validation Helpers ============

  /// Validate multiple fields
  static Map<String, ValidationResult> validateFields(
    Map<String, Validator> validators,
    Map<String, dynamic> values,
  ) {
    final results = <String, ValidationResult>{};

    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final value = values[fieldName];

      results[fieldName] = validator(value);
    }

    return results;
  }

  /// Check if all validation results are valid
  static bool areAllValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  /// Get first error message from validation results
  static String? getFirstErrorMessage(Map<String, ValidationResult> results) {
    for (final result in results.values) {
      if (!result.isValid && result.errorMessage != null) {
        return result.errorMessage;
      }
    }
    return null;
  }

  /// Get all error messages from validation results
  static List<String> getAllErrorMessages(
      Map<String, ValidationResult> results) {
    return results.values
        .where((result) => !result.isValid && result.errorMessage != null)
        .map((result) => result.errorMessage!)
        .toList();
  }

  /// Get validation errors as map
  static Map<String, String> getErrorMap(
      Map<String, ValidationResult> results) {
    return Map.fromEntries(
      results.entries
          .where((entry) =>
              !entry.value.isValid && entry.value.errorMessage != null)
          .map((entry) => MapEntry(entry.key, entry.value.errorMessage!)),
    );
  }
}
