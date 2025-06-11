import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';

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
  Timer? _maxDurationTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeAnimations();
  }

  void _initializeSpeech() {
    _speechToText = stt.SpeechToText();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    // Critical: Dispose all resources properly
    _stopListening();
    _maxDurationTimer?.cancel();
    _debounceTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external listening state changes
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening && !_isListening) {
        _startListening();
      } else if (!widget.isListening && _isListening) {
        _stopListening();
      }
    }
  }

  Future<void> _checkPermissionAndInitialize() async {
    if (_isInitialized) return;

    try {
      // Check microphone permission
      final permission = await Permission.microphone.status;
      if (permission.isDenied) {
        final result = await Permission.microphone.request();
        if (result.isDenied) {
          _handleError('microphone_permission_denied'.tr());
          return;
        }
      }

      // Initialize speech recognition
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false, // Disable in production
      );

      if (mounted) {
        setState(() {
          _isAvailable = available;
          _isInitialized = true;
        });
      }

      if (!available) {
        _handleError('speech_recognition_not_available'.tr());
      }
    } catch (e) {
      _handleError('speech_initialization_failed'.tr());
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;

    switch (status) {
      case 'listening':
        setState(() {
          _isListening = true;
        });
        _startAnimations();
        widget.onListeningChanged?.call(true);
        break;
      case 'notListening':
        if (_isListening) {
          _stopListening();
        }
        break;
      case 'done':
        _finalizeSpeechInput();
        break;
    }
  }

  void _onSpeechError(dynamic error) {
    _stopListening();
    final errorMessage = error?.errorMsg ?? 'speech_recognition_error'.tr();
    _handleError(errorMessage);
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _recognizedText = result.recognizedWords;
      _confidence = result.confidence;
    });

    // Debounce partial results
    if (!result.finalResult) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && _recognizedText.isNotEmpty) {
          widget.onVoiceInput(_recognizedText);
        }
      });
    } else {
      _debounceTimer?.cancel();
      _finalizeSpeechInput();
    }
  }

  void _finalizeSpeechInput() {
    if (_recognizedText.isNotEmpty) {
      widget.onVoiceInput(_recognizedText);
    }
    _stopListening();
  }

  Future<void> _startListening() async {
    if (_isListening || !_isInitialized) return;

    await _checkPermissionAndInitialize();
    if (!_isAvailable) return;

    try {
      final localeId = _getLocaleId();

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: widget.maxListeningDuration,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: localeId,
      );

      // Set maximum duration timer
      _maxDurationTimer?.cancel();
      _maxDurationTimer = Timer(widget.maxListeningDuration, () {
        if (_isListening) {
          _stopListening();
        }
      });
    } catch (e) {
      _handleError('failed_to_start_listening'.tr());
    }
  }

  void _stopListening() {
    if (!_isListening) return;

    _maxDurationTimer?.cancel();
    _debounceTimer?.cancel();

    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    _stopAnimations();

    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }

    widget.onListeningChanged?.call(false);
  }

  void _startAnimations() {
    if (!mounted) return;
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
  }

  void _stopAnimations() {
    if (!mounted) return;
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
  }

  String _getLocaleId() {
    final language = widget.detectedLanguage ?? widget.sourceLanguage;

    // Map language codes to locale IDs
    final localeMap = {
      'en': 'en_US',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'it': 'it_IT',
      'pt': 'pt_BR',
      'ru': 'ru_RU',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'zh': 'zh_CN',
      'ar': 'ar_SA',
      'hi': 'hi_IN',
    };

    return localeMap[language] ?? 'en_US';
  }

  void _handleError(String error) {
    final sonner = ShadSonner.of(context);
    widget.onError?.call(error);
    if (mounted) {
      sonner.show(
        ShadToast.destructive(
          description: Text('alternative_copied'.tr()),
        ),
      );
      context.showError(error);
    }
  }

  double _getButtonSize() {
    switch (widget.size) {
      case VoiceInputSize.small:
        return 40.0;
      case VoiceInputSize.medium:
        return 56.0;
      case VoiceInputSize.large:
        return 72.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final buttonSize = _getButtonSize();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isListening ? _stopListening : _startListening,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _waveController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening
                    ? _pulseAnimation.value * _scaleAnimation.value
                    : 1.0,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? AppColors.lightDestructive
                        : (widget.color ?? AppColors.primary(brightness)),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: AppColors.surface(brightness)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Icon(
                    _isListening
                        ? Iconsax.microphone_slash
                        : Iconsax.microphone,
                    size: buttonSize * 0.4,
                  ),
                ),
              );
            },
          ),
        ),

        if (widget.showLabel) ...[
          const SizedBox(height: 8),
          Text(
            _isListening ? 'voice_listening'.tr() : 'voice_tap_to_speak'.tr(),
            textAlign: TextAlign.center,
          ),
        ],

        // Show confidence indicator when listening
        if (_isListening && _confidence > 0) ...[
          const SizedBox(height: 4),
          Container(
            width: buttonSize * 0.8,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: AppColors.surface(brightness),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _confidence,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
