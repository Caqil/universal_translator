import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/exceptions.dart';
import '../models/speech_result_model.dart';

/// Abstract interface for speech data source
abstract class SpeechDataSource {
  /// Initialize speech recognition
  Future<bool> initializeSpeechToText();

  /// Initialize text-to-speech
  Future<bool> initializeTextToSpeech();

  /// Start listening for speech input
  Future<void> startListening({
    required String languageCode,
    required Function(SpeechResultModel) onResult,
    required Function(String) onError,
    bool partialResults = true,
  });

  /// Stop listening for speech input
  Future<void> stopListening();

  /// Check if speech recognition is available
  Future<bool> isSpeechRecognitionAvailable();

  /// Check if text-to-speech is available
  Future<bool> isTextToSpeechAvailable();

  /// Speak text using text-to-speech
  Future<void> speakText({
    required String text,
    required String languageCode,
    double rate = 0.5,
    double pitch = 1.0,
    double volume = 1.0,
  });

  /// Stop text-to-speech
  Future<void> stopSpeaking();

  /// Get available speech recognition languages
  Future<List<String>> getAvailableSpeechLanguages();

  /// Get available text-to-speech languages
  Future<List<String>> getAvailableTTSLanguages();

  /// Check microphone permission
  Future<bool> checkMicrophonePermission();

  /// Request microphone permission
  Future<bool> requestMicrophonePermission();

  /// Get speech recognition status
  String get speechStatus;

  /// Check if currently listening
  bool get isListening;

  /// Check if currently speaking
  bool get isSpeaking;
}

class SpeechDataSourceImpl implements SpeechDataSource {
  final stt.SpeechToText _speechToText;
  final FlutterTts _flutterTts;

  bool _isSTTInitialized = false;
  bool _isTTSInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _speechStatus = 'notListening';

  SpeechDataSourceImpl(this._speechToText, this._flutterTts);

  @override
  Future<bool> initializeSpeechToText() async {
    try {
      if (_isSTTInitialized) return true;

      final isAvailable = await _speechToText.initialize(
        onError: (error) => _speechStatus = 'error',
        onStatus: (status) => _speechStatus = status,
      );

      _isSTTInitialized = isAvailable;
      return isAvailable;
    } catch (e) {
      throw SpeechException(
        message: 'Failed to initialize speech recognition: ${e.toString()}',
        code: 'STT_INIT_FAILED',
      );
    }
  }

  @override
  Future<bool> initializeTextToSpeech() async {
    try {
      if (_isTTSInitialized) return true;

      // Set TTS completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Set TTS error handler
      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        throw SpeechException(
          message: 'Text-to-speech error: $message',
          code: 'TTS_ERROR',
        );
      });

      // Set TTS start handler
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _isTTSInitialized = true;
      return true;
    } catch (e) {
      throw SpeechException(
        message: 'Failed to initialize text-to-speech: ${e.toString()}',
        code: 'TTS_INIT_FAILED',
      );
    }
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required Function(SpeechResultModel) onResult,
    required Function(String) onError,
    bool partialResults = true,
  }) async {
    try {
      if (!_isSTTInitialized) {
        final initialized = await initializeSpeechToText();
        if (!initialized) {
          throw SpeechException.notAvailable();
        }
      }

      // Check microphone permission
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw PermissionException.denied('microphone');
      }

      // Get locale ID for speech recognition
      final localeId = _getSpeechLocaleId(languageCode);

      await _speechToText.listen(
        onResult: (result) {
          final speechResult = SpeechResultModel(
            recognizedWords: result.recognizedWords,
            confidence: result.confidence,
            isFinal: result.finalResult,
            languageCode: languageCode,
            timestamp: DateTime.now(),
          );
          onResult(speechResult);
        },
        localeId: localeId,
        cancelOnError: true,
        partialResults: partialResults,
        listenMode: stt.ListenMode.confirmation,
      );

      _isListening = true;
    } catch (e) {
      _isListening = false;
      if (e is SpeechException || e is PermissionException) {
        rethrow;
      }
      throw SpeechException(
        message: 'Failed to start listening: ${e.toString()}',
        code: 'STT_START_FAILED',
      );
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      throw SpeechException(
        message: 'Failed to stop listening: ${e.toString()}',
        code: 'STT_STOP_FAILED',
      );
    }
  }

  @override
  Future<bool> isSpeechRecognitionAvailable() async {
    try {
      return await _speechToText.hasPermission;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isTextToSpeechAvailable() async {
    try {
      // TTS is generally available on most platforms
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> speakText({
    required String text,
    required String languageCode,
    double rate = 0.5,
    double pitch = 1.0,
    double volume = 1.0,
  }) async {
    try {
      if (!_isTTSInitialized) {
        final initialized = await initializeTextToSpeech();
        if (!initialized) {
          throw SpeechException(
            message: 'Text-to-speech not available',
            code: 'TTS_NOT_AVAILABLE',
          );
        }
      }

      // Set TTS parameters
      await _flutterTts.setLanguage(_getTTSLocaleId(languageCode));
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setVolume(volume);

      // Speak the text
      await _flutterTts.speak(text);
      _isSpeaking = true;
    } catch (e) {
      _isSpeaking = false;
      if (e is SpeechException) {
        rethrow;
      }
      throw SpeechException(
        message: 'Failed to speak text: ${e.toString()}',
        code: 'TTS_SPEAK_FAILED',
      );
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      throw SpeechException(
        message: 'Failed to stop speaking: ${e.toString()}',
        code: 'TTS_STOP_FAILED',
      );
    }
  }

  @override
  Future<List<String>> getAvailableSpeechLanguages() async {
    try {
      if (!_isSTTInitialized) {
        await initializeSpeechToText();
      }

      final locales = await _speechToText.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      throw SpeechException(
        message: 'Failed to get available speech languages: ${e.toString()}',
        code: 'STT_LANGUAGES_FAILED',
      );
    }
  }

  @override
  Future<List<String>> getAvailableTTSLanguages() async {
    try {
      if (!_isTTSInitialized) {
        await initializeTextToSpeech();
      }

      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      throw SpeechException(
        message: 'Failed to get available TTS languages: ${e.toString()}',
        code: 'TTS_LANGUAGES_FAILED',
      );
    }
  }

  @override
  Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      throw PermissionException(
        message: 'Failed to request microphone permission: ${e.toString()}',
        permission: 'microphone',
        code: 'MICROPHONE_PERMISSION_FAILED',
      );
    }
  }

  @override
  String get speechStatus => _speechStatus;

  @override
  bool get isListening => _isListening;

  @override
  bool get isSpeaking => _isSpeaking;

  /// Get speech locale ID from language code
  String _getSpeechLocaleId(String languageCode) {
    const localeMap = {
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
      'ar': 'ar-SA',
      'hi': 'hi-IN',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'sv': 'sv-SE',
      'da': 'da-DK',
      'no': 'no-NO',
      'fi': 'fi-FI',
      'cs': 'cs-CZ',
      'hu': 'hu-HU',
      'tr': 'tr-TR',
      'th': 'th-TH',
      'vi': 'vi-VN',
      'id': 'id-ID',
      'ms': 'ms-MY',
      'ca': 'ca-ES',
      'el': 'el-GR',
      'he': 'he-IL',
      'ro': 'ro-RO',
      'sk': 'sk-SK',
      'sl': 'sl-SI',
      'bg': 'bg-BG',
      'hr': 'hr-HR',
      'et': 'et-EE',
      'lv': 'lv-LV',
      'lt': 'lt-LT',
      'uk': 'uk-UA',
      'fa': 'fa-IR',
    };

    return localeMap[languageCode] ?? 'en-US';
  }

  /// Get TTS locale ID from language code
  String _getTTSLocaleId(String languageCode) {
    // For TTS, we can use the same mapping as STT
    return _getSpeechLocaleId(languageCode);
  }
}
