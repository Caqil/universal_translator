class ApiConstants {
  static const String defaultLibreTranslateUrl = 'https://libretranslate.com';
  static const String localLibreTranslateUrl = 'http://localhost:5000';

  // Updated example URL from the documentation
  static const String exampleLibreTranslateUrl = 'http://20.51.237.146:5000';

  // API Endpoints - Direct endpoints without /api/v1
  static const String translateEndpoint = '/translate';
  static const String detectEndpoint = '/detect';
  static const String languagesEndpoint = '/languages';
  static const String frontendSettingsEndpoint = '/frontend/settings';

  // Query Parameters
  static const String paramQ = 'q'; // Text to translate
  static const String paramSource = 'source'; // Source language
  static const String paramTarget = 'target'; // Target language
  static const String paramFormat = 'format'; // Format (text/html)
  static const String paramApiKey = 'api_key'; // API key (required in body)
  static const String paramAlternatives =
      'alternatives'; // Number of alternatives

  // Default Parameter Values
  static const String defaultFormat = 'text';
  static const int defaultAlternatives = 3;
  static const String defaultApiKey = ''; // Empty string for no auth

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const List<int> retryStatusCodes = [500, 502, 503, 504];

  // Cache Configuration
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const Duration cacheStaleWhileRevalidate = Duration(hours: 1);
  static const String cacheControlMaxAge = 'max-age=86400';

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const Duration rateLimitWindow = Duration(minutes: 1);

  // Request/Response Limits
  static const int maxResponseSize = 10 * 1024 * 1024; // 10MB
  static const int maxRequestBodySize = 5 * 1024 * 1024; // 5MB
  static const int maxTextLengthForTranslation = 5000;
  static const int maxBatchTranslationItems = 100;

  // API Response Status Codes
  static const int statusCodeOk = 200;
  static const int statusCodeCreated = 201;
  static const int statusCodeAccepted = 202;
  static const int statusCodeNoContent = 204;
  static const int statusCodeBadRequest = 400;
  static const int statusCodeUnauthorized = 401;
  static const int statusCodeForbidden = 403;
  static const int statusCodeNotFound = 404;
  static const int statusCodeMethodNotAllowed = 405;
  static const int statusCodeConflict = 409;
  static const int statusCodeTooManyRequests = 429;
  static const int statusCodeInternalServerError = 500;
  static const int statusCodeBadGateway = 502;
  static const int statusCodeServiceUnavailable = 503;
  static const int statusCodeGatewayTimeout = 504;

  // API Error Codes (LibreTranslate specific)
  static const String errorCodeInvalidApiKey = 'INVALID_API_KEY';
  static const String errorCodeLanguageNotSupported = 'LANGUAGE_NOT_SUPPORTED';
  static const String errorCodeTextTooLong = 'TEXT_TOO_LONG';
  static const String errorCodeRateLimitExceeded = 'RATE_LIMIT_EXCEEDED';
  static const String errorCodeServiceUnavailable = 'SERVICE_UNAVAILABLE';
  static const String errorCodeInvalidRequest = 'INVALID_REQUEST';

  static const bool defaultIncludeConfidence = true;

  // OCR API Configuration (if using external OCR service)
  static const String ocrApiUrl = 'https://api.ocr.space/parse/image';
  static const String ocrApiKey = 'YOUR_OCR_API_KEY';
  static const String ocrLanguageParam = 'language';
  static const String ocrOverlayRequiredParam = 'isOverlayRequired';
  static const String ocrFileTypeParam = 'filetype';

  // Speech API Configuration (if using external speech service)
  static const String speechApiUrl =
      'https://speech.googleapis.com/v1/speech:recognize';
  static const String speechApiKey = 'YOUR_SPEECH_API_KEY';
  static const String speechLanguageCodeParam = 'languageCode';
  static const String speechSampleRateParam = 'sampleRateHertz';
  static const String speechEncodingParam = 'encoding';

  // Text-to-Speech API Configuration
  static const String ttsApiUrl =
      'https://texttospeech.googleapis.com/v1/text:synthesize';
  static const String ttsApiKey = 'YOUR_TTS_API_KEY';
  static const String ttsLanguageCodeParam = 'languageCode';
  static const String ttsVoiceNameParam = 'name';
  static const String ttsSsmlGenderParam = 'ssmlGender';

  // Offline Mode Configuration
  static const String offlineModelsPath = 'assets/models/';
  static const String offlineLanguageModelsPrefix = 'translate_';
  static const String offlineLanguageModelsSuffix = '.tflite';

  // Analytics & Monitoring
  static const String analyticsEndpoint =
      'https://analytics.example.com/api/v1/events';
  static const String crashReportingEndpoint =
      'https://crashlytics.example.com/api/v1/crashes';
  static const String performanceMonitoringEndpoint =
      'https://performance.example.com/api/v1/metrics';
}
