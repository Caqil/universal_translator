import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/speech_bloc.dart';
import '../bloc/speech_event.dart';
import '../bloc/speech_state.dart';
import 'speech_animation.dart';

/// Speech button modes
enum SpeechButtonMode {
  speechToText,
  textToSpeech,
  both,
}

/// Speech button sizes
enum SpeechButtonSize {
  small,
  medium,
  large,
}

/// Speech button with integrated speech recognition and text-to-speech
class SpeechButton extends StatefulWidget {
  /// Mode of the speech button
  final SpeechButtonMode mode;

  /// Size of the button
  final SpeechButtonSize size;

  /// Language code for speech operations
  final String languageCode;

  /// Text to speak (for TTS mode)
  final String? textToSpeak;

  /// Callback when speech recognition result is received
  final ValueChanged<String>? onSpeechResult;

  /// Callback when speech recognition starts
  final VoidCallback? onSpeechStart;

  /// Callback when speech recognition stops
  final VoidCallback? onSpeechStop;

  /// Callback when TTS starts
  final VoidCallback? onTTSStart;

  /// Callback when TTS stops
  final VoidCallback? onTTSStop;

  /// Callback when error occurs
  final ValueChanged<String>? onError;

  /// Whether to show partial results
  final bool partialResults;

  /// Whether to show confidence indicator
  final bool showConfidence;

  /// Whether to show text label
  final bool showLabel;

  /// Custom label text
  final String? customLabel;

  /// Custom color
  final Color? color;

  /// Whether the button is enabled
  final bool enabled;

  /// Speech rate for TTS (0.1 to 2.0)
  final double speechRate;

  /// Speech pitch for TTS (0.5 to 2.0)
  final double speechPitch;

  /// Speech volume for TTS (0.0 to 1.0)
  final double speechVolume;

  const SpeechButton({
    super.key,
    required this.languageCode,
    this.mode = SpeechButtonMode.speechToText,
    this.size = SpeechButtonSize.medium,
    this.textToSpeak,
    this.onSpeechResult,
    this.onSpeechStart,
    this.onSpeechStop,
    this.onTTSStart,
    this.onTTSStop,
    this.onError,
    this.partialResults = true,
    this.showConfidence = false,
    this.showLabel = false,
    this.customLabel,
    this.color,
    this.enabled = true,
    this.speechRate = 0.5,
    this.speechPitch = 1.0,
    this.speechVolume = 1.0,
  });

  @override
  State<SpeechButton> createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> {
  @override
  void initState() {
    super.initState();
    // Initialize speech services if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final speechBloc = context.read<SpeechBloc>();
      if (speechBloc.state.status == SpeechStatus.initial) {
        speechBloc.add(const InitializeSpeechEvent());
      }
    });
  }

  void _handleButtonPress(SpeechState state) {
    if (!widget.enabled) return;

    switch (widget.mode) {
      case SpeechButtonMode.speechToText:
        _handleSpeechToText(state);
        break;
      case SpeechButtonMode.textToSpeech:
        _handleTextToSpeech(state);
        break;
      case SpeechButtonMode.both:
        _handleBothModes(state);
        break;
    }
  }

  void _handleSpeechToText(SpeechState state) {
    if (state.isListening) {
      context.read<SpeechBloc>().add(const StopListeningEvent());
      widget.onSpeechStop?.call();
    } else if (state.canStartListening) {
      context.read<SpeechBloc>().add(StartListeningEvent(
            languageCode: widget.languageCode,
            partialResults: widget.partialResults,
          ));
      widget.onSpeechStart?.call();
    } else if (!state.hasMicrophonePermission) {
      context.read<SpeechBloc>().add(const RequestMicrophonePermissionEvent());
    } else {
      _showError('speech_not_available'.tr());
    }
  }

  void _handleTextToSpeech(SpeechState state) {
    if (state.isSpeaking) {
      context.read<SpeechBloc>().add(const StopSpeakingEvent());
      widget.onTTSStop?.call();
    } else if (state.canSpeak && widget.textToSpeak != null) {
      context.read<SpeechBloc>().add(SpeakTextEvent(
            text: widget.textToSpeak!,
            languageCode: widget.languageCode,
            rate: widget.speechRate,
            pitch: widget.speechPitch,
            volume: widget.speechVolume,
          ));
      widget.onTTSStart?.call();
    } else {
      _showError('tts_not_available'.tr());
    }
  }

  void _handleBothModes(SpeechState state) {
    if (state.isListening || state.isSpeaking) {
      // Stop any current operation
      if (state.isListening) {
        context.read<SpeechBloc>().add(const StopListeningEvent());
        widget.onSpeechStop?.call();
      }
      if (state.isSpeaking) {
        context.read<SpeechBloc>().add(const StopSpeakingEvent());
        widget.onTTSStop?.call();
      }
    } else {
      // Default to speech-to-text for both mode
      _handleSpeechToText(state);
    }
  }

  void _showError(String message) {
    final sonner = ShadSonner.of(context);
    widget.onError?.call(message);
    sonner.show(
      ShadToast.destructive(
        description: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpeechBloc, SpeechState>(
      listener: (context, state) {
        // Handle speech recognition results
        if (state.hasRecognizedText &&
            state.status == SpeechStatus.completed &&
            widget.onSpeechResult != null) {
          widget.onSpeechResult!(state.recognizedText);
        }

        // Handle errors
        if (state.hasError && widget.onError != null) {
          widget.onError!(state.errorMessage ?? 'unknown_error'.tr());
        }
      },
      builder: (context, state) {
        return _buildButton(context, state);
      },
    );
  }

  Widget _buildButton(BuildContext context, SpeechState state) {
    final brightness = context.brightness;
    final isActive = state.isListening || state.isSpeaking;
    final isLoading = state.isInitializing || state.isProcessing;

    if (widget.showLabel) {
      return _buildLabeledButton(
          context, state, brightness, isActive, isLoading);
    } else {
      return _buildIconButton(context, state, brightness, isActive, isLoading);
    }
  }

  Widget _buildLabeledButton(
    BuildContext context,
    SpeechState state,
    Brightness brightness,
    bool isActive,
    bool isLoading,
  ) {
    final buttonSize = _getButtonSize();
    final label = _getButtonLabel(state);
    final variant =
        isActive ? ButtonVariant.destructive : ButtonVariant.primary;

    return CustomButton(
      text: label,
      onPressed:
          widget.enabled && !isLoading ? () => _handleButtonPress(state) : null,
      variant: variant,
      size: buttonSize,
      icon: _getButtonIcon(state),
      isLoading: isLoading,
      isDisabled: !widget.enabled || !_canInteract(state),
      backgroundColor: widget.color,
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    SpeechState state,
    Brightness brightness,
    bool isActive,
    bool isLoading,
  ) {
    final buttonSize = _getIconButtonSize();
    final effectiveColor =
        widget.color ?? _getEffectiveColor(state, brightness);

    return GestureDetector(
      onTap:
          widget.enabled && !isLoading ? () => _handleButtonPress(state) : null,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? effectiveColor : effectiveColor.withOpacity(0.1),
          border: Border.all(
            color: effectiveColor,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animation layer
            if (isActive) ...[
              SpeechAnimation(
                type: _getAnimationType(state),
                size: buttonSize * 0.8,
                color: effectiveColor,
                isActive: isActive,
                showConfidence: widget.showConfidence,
                confidence: state.confidence,
              ),
            ],

            // Icon layer
            if (!isActive || !_shouldShowAnimation(state)) ...[
              if (isLoading) ...[
                SizedBox(
                  width: buttonSize * 0.3,
                  height: buttonSize * 0.3,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActive ? Colors.white : effectiveColor,
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  _getButtonIcon(state),
                  size: buttonSize * 0.4,
                  color: isActive ? Colors.white : effectiveColor,
                ),
              ],
            ],

            // Confidence indicator
            if (widget.showConfidence &&
                state.hasRecognizedText &&
                !isActive) ...[
              Positioned(
                bottom: 0,
                child: _buildConfidenceChip(state, brightness),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChip(SpeechState state, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(
          color: AppColors.border(brightness),
          width: 1,
        ),
      ),
      child: Text(
        '${state.confidencePercentage}%',
        style: AppTextStyles.caption.copyWith(
          color: _getConfidenceColor(state.confidence),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper methods
  ButtonSize _getButtonSize() {
    switch (widget.size) {
      case SpeechButtonSize.small:
        return ButtonSize.small;
      case SpeechButtonSize.medium:
        return ButtonSize.medium;
      case SpeechButtonSize.large:
        return ButtonSize.large;
    }
  }

  double _getIconButtonSize() {
    switch (widget.size) {
      case SpeechButtonSize.small:
        return 48.0;
      case SpeechButtonSize.medium:
        return 64.0;
      case SpeechButtonSize.large:
        return 80.0;
    }
  }

  String _getButtonLabel(SpeechState state) {
    if (widget.customLabel != null) return widget.customLabel!;

    switch (widget.mode) {
      case SpeechButtonMode.speechToText:
        if (state.isListening) return 'stop_listening'.tr();
        return 'translation.start_listening'.tr();
      case SpeechButtonMode.textToSpeech:
        if (state.isSpeaking) return 'stop_speaking'.tr();
        return 'translation.speak_text'.tr();
      case SpeechButtonMode.both:
        if (state.isListening) return 'stop_listening'.tr();
        if (state.isSpeaking) return 'stop_speaking'.tr();
        return 'voice.voice_input'.tr();
    }
  }

  IconData _getButtonIcon(SpeechState state) {
    switch (widget.mode) {
      case SpeechButtonMode.speechToText:
        if (state.isListening) return Iconsax.microphone_slash;
        return Iconsax.microphone;
      case SpeechButtonMode.textToSpeech:
        if (state.isSpeaking) return Iconsax.pause;
        return Iconsax.volume_high;
      case SpeechButtonMode.both:
        if (state.isListening) return Iconsax.microphone_slash;
        if (state.isSpeaking) return Iconsax.pause;
        return Iconsax.microphone;
    }
  }

  Color _getEffectiveColor(SpeechState state, Brightness brightness) {
    if (state.isListening) return AppColors.voiceActive;
    if (state.isSpeaking) return AppColors.voiceListening;
    return AppColors.primary(brightness);
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.highConfidence;
    if (confidence >= 0.5) return AppColors.mediumConfidence;
    return AppColors.lowConfidence;
  }

  SpeechAnimationType _getAnimationType(SpeechState state) {
    if (state.isListening) return SpeechAnimationType.listening;
    if (state.isSpeaking) return SpeechAnimationType.speaking;
    if (state.isProcessing) return SpeechAnimationType.processing;
    return SpeechAnimationType.pulse;
  }

  bool _shouldShowAnimation(SpeechState state) {
    return state.isListening || state.isSpeaking || state.isProcessing;
  }

  bool _canInteract(SpeechState state) {
    switch (widget.mode) {
      case SpeechButtonMode.speechToText:
        return state.isSpeechRecognitionAvailable;
      case SpeechButtonMode.textToSpeech:
        return state.isTextToSpeechAvailable && widget.textToSpeak != null;
      case SpeechButtonMode.both:
        return state.isSpeechRecognitionAvailable ||
            (state.isTextToSpeechAvailable && widget.textToSpeak != null);
    }
  }
}
