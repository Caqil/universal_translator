// lib/features/translation/presentation/widgets/voice_input_button.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/services/permission_service.dart';

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
        _startListeningFlow();
      } else if (!widget.isListening && _isListening) {
        _stopListening();
      }
    }
  }

  /// Main entry point for starting voice input - handles permissions first
  Future<void> _startListeningFlow() async {
    print('🎤 Voice button pressed - starting listening flow...');

    try {
      // Step 1: Check microphone permission
      final hasPermission = await PermissionService.hasMicrophonePermission;
      print('🎤 Current microphone permission: $hasPermission');

      if (!hasPermission) {
        await _requestPermissionAndStart();
      } else {
        await _checkPermissionAndInitialize();
        await _startListening();
      }
    } catch (e) {
      print('🎤 Error in listening flow: $e');
      _handleError('voice_error'.tr());
    }
  }

  /// Request microphone permission and start if granted
  Future<void> _requestPermissionAndStart() async {
    print('🎤 Microphone permission not granted, requesting...');

    final status = await PermissionService.requestMicrophonePermission();
    print('🎤 Permission request result: $status');

    if (status.isGranted) {
      print('🎤 Permission granted, proceeding with initialization...');
      _showPermissionGrantedMessage();
      await _checkPermissionAndInitialize();
      await _startListening();
    } else if (status.isPermanentlyDenied) {
      print('🎤 Permission permanently denied');
      _showPermissionDialog();
    } else {
      print('🎤 Permission denied');
      _handleError('voice_permission_denied'.tr());
    }
  }

  /// Check permission and initialize speech recognition
  Future<void> _checkPermissionAndInitialize() async {
    if (_isInitialized) {
      print('🎤 Already initialized, skipping...');
      return;
    }

    try {
      print('🎤 Initializing speech recognition...');

      // Double-check permission
      final hasPermission = await PermissionService.hasMicrophonePermission;
      if (!hasPermission) {
        _handleError('voice_permission_denied'.tr());
        return;
      }

      // Initialize speech recognition with debug logging
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true, // Enable for debugging
      );

      print('🎤 Speech recognition available: $available');

      if (mounted) {
        setState(() {
          _isAvailable = available;
          _isInitialized = true;
        });
      }

      if (!available) {
        _handleError('voice_not_available'.tr());
      } else {
        print('🎤 Speech recognition successfully initialized!');
      }
    } catch (e) {
      print('🎤 Speech initialization error: $e');
      _handleError('voice_error'.tr());
    }
  }

  /// Start listening for speech input
  Future<void> _startListening() async {
    if (!_isInitialized || !_isAvailable) {
      print(
          '🎤 Not ready to start listening (initialized: $_isInitialized, available: $_isAvailable)');
      await _checkPermissionAndInitialize();
      if (!_isAvailable) return;
    }

    if (_isListening) {
      print('🎤 Already listening, ignoring start request');
      return;
    }

    try {
      print('🎤 Starting speech recognition...');

      final localeId = _getLocaleId();
      print('🎤 Using locale: $localeId');

      // Clear previous results
      _recognizedText = '';
      _confidence = 0.0;

      // Start listening
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: widget.maxListeningDuration,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: localeId,
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      // Set timeout timer
      _maxDurationTimer = Timer(widget.maxListeningDuration, () {
        print('🎤 Maximum listening duration reached, stopping...');
        _stopListening();
        _handleError('voice_timeout'.tr());
      });

      print('🎤 Speech recognition started successfully');
    } catch (e) {
      print('🎤 Error starting speech recognition: $e');
      _handleError('voice_error'.tr());
    }
  }

  /// Stop listening for speech input
  Future<void> _stopListening() async {
    if (!_isListening && !_speechToText.isListening) {
      return;
    }

    try {
      print('🎤 Stopping speech recognition...');

      // Cancel timers
      _maxDurationTimer?.cancel();
      _debounceTimer?.cancel();

      // Stop speech recognition
      await _speechToText.stop();

      // Stop animations
      _stopAnimations();

      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }

      // Notify parent
      widget.onListeningChanged?.call(false);

      print('🎤 Speech recognition stopped');
    } catch (e) {
      print('🎤 Error stopping speech recognition: $e');
    }
  }

  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    if (!mounted) return;

    print('🎤 Speech status: $status');

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
          _finalizeSpeechInput();
        }
        break;
      case 'done':
        _finalizeSpeechInput();
        break;
    }
  }

  /// Handle speech recognition errors
  void _onSpeechError(dynamic error) {
    print('🎤 Speech error: $error');

    _stopListening();

    String errorMessage = 'voice_error'.tr();

    if (error != null) {
      final errorCode = error.errorMsg ?? error.toString();

      if (errorCode.contains('network')) {
        errorMessage = 'voice_network_error'.tr();
      } else if (errorCode.contains('no-speech')) {
        errorMessage = 'voice_no_speech'.tr();
      } else if (errorCode.contains('audio')) {
        errorMessage = 'voice_permission_denied'.tr();
      }
    }

    _handleError(errorMessage);
  }

  /// Handle speech recognition results
  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    if (!mounted) return;

    print(
        '🎤 Speech result: "${result.recognizedWords}" (confidence: ${result.confidence})');

    setState(() {
      _recognizedText = result.recognizedWords;
      _confidence = result.confidence;
    });

    // Debounce the final result to avoid multiple callbacks
    if (result.finalResult) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _finalizeSpeechInput();
      });
    }
  }

  /// Handle sound level changes for visual feedback
  void _onSoundLevelChange(double level) {
    // Update confidence visual indicator
    if (mounted && _isListening) {
      setState(() {
        _confidence = (level + 1) / 2; // Normalize to 0-1 range
      });
    }
  }

  /// Finalize and process speech input
  void _finalizeSpeechInput() {
    print('🎤 Finalizing speech input: "$_recognizedText"');

    _stopListening();

    if (_recognizedText.isNotEmpty) {
      widget.onVoiceInput(_recognizedText);
      _showSuccessMessage(_recognizedText);
    } else {
      _handleError('voice_no_speech'.tr());
    }
  }

  /// Start visual animations
  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.forward();
  }

  /// Stop visual animations
  void _stopAnimations() {
    _pulseController.stop();
    _waveController.reverse();
  }

  /// Get locale ID for speech recognition
  String _getLocaleId() {
    final language = widget.detectedLanguage ?? widget.sourceLanguage;

    // Map language codes to locale IDs
    const localeMap = {
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
      'nl': 'nl_NL',
      'pl': 'pl_PL',
      'sv': 'sv_SE',
      'da': 'da_DK',
      'no': 'no_NO',
      'fi': 'fi_FI',
      'cs': 'cs_CZ',
      'hu': 'hu_HU',
      'tr': 'tr_TR',
      'th': 'th_TH',
      'vi': 'vi_VN',
      'id': 'id_ID',
      'ms': 'ms_MY',
    };

    return localeMap[language] ?? 'en_US';
  }

  /// Show permission granted success message
  void _showPermissionGrantedMessage() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.tick_circle),
            const SizedBox(width: 8),
            Text('Microphone permission granted!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show success message when speech is recognized
  void _showSuccessMessage(String text) {
    HapticFeedback.lightImpact();
    print('🎤 SUCCESS: Voice input recognized: "$text"');
  }

  /// Show permission dialog when permanently denied
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('permission_required'.tr()),
        content: Text('microphone_needed'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: Text('permission_settings'.tr()),
          ),
        ],
      ),
    );
  }

  /// Handle errors with user-friendly messages
  void _handleError(String error) {
    print('🎤 ERROR: $error');

    HapticFeedback.heavyImpact();

    // Show user-friendly error messages
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.close_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: error.contains('permission')
            ? SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => PermissionService.openAppSettings(),
              )
            : null,
      ),
    );

    // Also use ShadCN UI toast if available
    try {
      final sonner = ShadSonner.of(context);
      sonner.show(
        ShadToast.destructive(
          description: Text(error),
          action: error.contains('permission')
              ? ShadButton.outline(
                  size: ShadButtonSize.sm,
                  child: Text('Settings'),
                  onPressed: () => PermissionService.openAppSettings(),
                )
              : null,
        ),
      );
    } catch (e) {
      // Fallback if ShadCN UI is not available
      print('🎤 Could not show ShadCN toast: $e');
    }

    widget.onError?.call(error);
  }

  /// Get button size based on size enum
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

    return Tooltip(
      message: widget.tooltip ??
          (_isListening ? 'stop_listening'.tr() : 'tap_to_speak'.tr()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main voice button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListeningFlow,
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
                          ? Colors.red
                          : (widget.color ?? AppColors.surface(brightness)),
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: (widget.color ??
                                        AppColors.primary(brightness))
                                    .withOpacity(0.3),
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
                      color: AppColors.primary(brightness),
                    ),
                  ),
                );
              },
            ),
          ),

          // Label (if enabled)
          if (widget.showLabel) ...[
            const SizedBox(height: 8),
            Text(
              _isListening ? 'listening'.tr() : 'tap_to_speak'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary(brightness),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Confidence indicator (when listening)
          if (_isListening && _confidence > 0) ...[
            const SizedBox(height: 6),
            Container(
              width: buttonSize * 0.8,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                color: Colors.grey[300],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _confidence.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green,
                        Colors.greenAccent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Processing indicator (when recognizing speech)
          if (_isListening && _recognizedText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _recognizedText,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
