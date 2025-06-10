import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Voice input button sizes
enum VoiceInputSize {
  small,
  medium,
  large,
}

/// Voice input button with speech-to-text functionality
class VoiceInputButton extends StatefulWidget {
  /// Callback when voice input is completed
  final ValueChanged<String> onVoiceInput;

  /// Source language code for speech recognition
  final String sourceLanguage;

  /// Detected language code (if auto-detect)
  final String? detectedLanguage;

  /// Whether voice input is currently active
  final bool isListening;

  /// Button size
  final VoiceInputSize size;

  /// Custom color
  final Color? color;

  /// Whether to show text label
  final bool showLabel;

  /// Custom tooltip
  final String? tooltip;

  /// Callback when listening state changes
  final ValueChanged<bool>? onListeningChanged;

  /// Callback when error occurs
  final ValueChanged<String>? onError;

  /// Maximum listening duration
  final Duration maxListeningDuration;

  const VoiceInputButton({
    super.key,
    required this.onVoiceInput,
    required this.sourceLanguage,
    this.detectedLanguage,
    this.isListening = false,
    this.size = VoiceInputSize.medium,
    this.color,
    this.showLabel = false,
    this.tooltip,
    this.onListeningChanged,
    this.onError,
    this.maxListeningDuration = const Duration(seconds: 30),
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speechToText;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  bool _isAvailable = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _initializeSpeechToText();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _timeoutTimer?.cancel();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initializeSpeechToText() async {
    try {
      final isAvailable = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      setState(() {
        _isAvailable = isAvailable;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _isInitialized = true;
      });
      _showError('speech_init_failed'.tr());
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showError('microphone_permission_required'.tr());
      return;
    }
  }

  void _onSpeechError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
    _waveController.stop();
    _timeoutTimer?.cancel();
    widget.onListeningChanged?.call(false);

    String errorMessage = 'speech_recognition_error'.tr();
    if (error.toString().contains('network')) {
      errorMessage = 'speech_network_error'.tr();
    } else if (error.toString().contains('no_match')) {
      errorMessage = 'speech_no_match_error'.tr();
    }

    _showError(errorMessage);
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _stopListening();
    }
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      _confidence = result.confidence;
    });

    if (result.finalResult) {
      _stopListening();
      if (_recognizedText.isNotEmpty) {
        widget.onVoiceInput(_recognizedText);
      }
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !_isAvailable) {
      _showError('speech_not_available'.tr());
      return;
    }

    // Request microphone permission
    await _requestMicrophonePermission();

    // Determine language for speech recognition
    final languageCode = _getEffectiveLanguageCode();
    if (!LanguageConstants.supportsSpeechToText(languageCode)) {
      _showError('speech_language_not_supported'.tr());
      return;
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _getSpeechLocaleId(languageCode),
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );

      setState(() {
        _isListening = true;
        _recognizedText = '';
        _confidence = 0.0;
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat();
      widget.onListeningChanged?.call(true);

      // Set timeout
      _timeoutTimer = Timer(widget.maxListeningDuration, () {
        _stopListening();
        _showError('speech_timeout_error'.tr());
      });
    } catch (e) {
      _showError('speech_start_failed'.tr());
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
    _timeoutTimer?.cancel();
    widget.onListeningChanged?.call(false);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  String _getEffectiveLanguageCode() {
    return widget.detectedLanguage ??
        (widget.sourceLanguage == 'auto' ? 'en' : widget.sourceLanguage);
  }

  String _getSpeechLocaleId(String languageCode) {
    // Map language codes to speech recognition locale IDs
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
    };

    return localeMap[languageCode] ?? 'en-US';
  }

  void _showError(String message) {
    widget.onError?.call(message);
    if (mounted) {
      context.showError(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    if (!_isInitialized) {
      return _buildLoadingButton(brightness);
    }

    if (!_isAvailable) {
      return _buildDisabledButton(brightness);
    }

    return _buildVoiceButton(context, brightness);
  }

  Widget _buildLoadingButton(Brightness brightness) {
    return _buildBaseButton(
      context: context,
      brightness: brightness,
      icon: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      isEnabled: false,
    );
  }

  Widget _buildDisabledButton(Brightness brightness) {
    return _buildBaseButton(
      context: context,
      brightness: brightness,
      icon: Icon(
        Iconsax.microphone_slash,
        size: _getIconSize(),
        color: AppColors.mutedForeground(brightness),
      ),
      isEnabled: false,
    );
  }

  Widget _buildVoiceButton(BuildContext context, Brightness brightness) {
    final effectiveColor = widget.color ??
        (_isListening ? AppColors.voiceActive : AppColors.voiceInactive);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wave effect when listening
              if (_isListening) ...[
                for (int i = 0; i < 3; i++)
                  Transform.scale(
                    scale: 1.0 + (i * 0.3) + _scaleAnimation.value * 0.2,
                    child: Container(
                      width: _getButtonSize() + (i * 20),
                      height: _getButtonSize() + (i * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: effectiveColor.withOpacity(0.3 - (i * 0.1)),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],

              // Main button
              _buildBaseButton(
                context: context,
                brightness: brightness,
                icon: Icon(
                  _isListening ? Iconsax.microphone : Iconsax.microphone,
                  size: _getIconSize(),
                  color: _isListening ? AppColors.white90 : effectiveColor,
                ),
                backgroundColor: _isListening ? effectiveColor : null,
                isEnabled: true,
                onPressed: _toggleListening,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBaseButton({
    required BuildContext context,
    required Brightness brightness,
    required Widget icon,
    required bool isEnabled,
    Color? backgroundColor,
    VoidCallback? onPressed,
  }) {
    if (widget.showLabel) {
      return CustomButton(
        text: _isListening ? 'listening'.tr() : 'voice_input'.tr(),
        onPressed: isEnabled ? (onPressed ?? _toggleListening) : null,
        variant: backgroundColor != null
            ? ButtonVariant.primary
            : ButtonVariant.outline,
        size: _getButtonSize() == 32 ? ButtonSize.small : ButtonSize.medium,
        icon: icon is Icon ? icon.icon : null,
        backgroundColor: backgroundColor,
        isDisabled: !isEnabled,
      );
    }

    return IconButton(
      onPressed: isEnabled ? (onPressed ?? _toggleListening) : null,
      icon: icon,
      iconSize: _getIconSize(),
      tooltip: widget.tooltip ??
          (_isListening ? 'stop_listening'.tr() : 'start_voice_input'.tr()),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ??
            (isEnabled ? AppColors.surface(brightness) : null),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getButtonSize() / 2),
          side: backgroundColor == null
              ? BorderSide(
                  color: AppColors.border(brightness),
                  width: 1,
                )
              : BorderSide.none,
        ),
        minimumSize: Size(_getButtonSize(), _getButtonSize()),
        maximumSize: Size(_getButtonSize(), _getButtonSize()),
      ),
    );
  }

  double _getButtonSize() {
    switch (widget.size) {
      case VoiceInputSize.small:
        return 32;
      case VoiceInputSize.medium:
        return 48;
      case VoiceInputSize.large:
        return 64;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case VoiceInputSize.small:
        return AppConstants.iconSizeSmall;
      case VoiceInputSize.medium:
        return AppConstants.iconSizeRegular;
      case VoiceInputSize.large:
        return AppConstants.iconSizeLarge;
    }
  }
}
