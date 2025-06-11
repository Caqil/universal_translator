import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'dart:ui' as ui;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'voice_input_button.dart';

/// Translation input widget with text field and voice input
class TranslationInput extends StatefulWidget {
  /// Text editing controller
  final TextEditingController controller;

  /// Callback when voice input is completed
  final ValueChanged<String> onVoiceInput;

  /// Source language code
  final String sourceLanguage;

  /// Detected language code (if auto-detect)
  final String? detectedLanguage;

  /// Whether voice input is currently active
  final bool isListening;

  /// Whether to show character count
  final bool showCharacterCount;

  /// Whether to show paste button
  final bool showPasteButton;

  /// Whether to show clear button
  final bool showClearButton;

  /// Custom placeholder text
  final String? placeholder;

  /// Callback when text is pasted
  final ValueChanged<String>? onTextPasted;

  /// Callback when text is cleared
  final VoidCallback? onTextCleared;

  const TranslationInput({
    super.key,
    required this.controller,
    required this.onVoiceInput,
    required this.sourceLanguage,
    this.detectedLanguage,
    this.isListening = false,
    this.showCharacterCount = true,
    this.showPasteButton = true,
    this.showClearButton = true,
    this.placeholder,
    this.onTextPasted,
    this.onTextCleared,
  });

  @override
  State<TranslationInput> createState() => _TranslationInputState();
}

class _TranslationInputState extends State<TranslationInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late FocusNode _focusNode;

  bool _isFocused = false;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
    _lastText = widget.controller.text;

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TranslationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final currentText = widget.controller.text;
    if (currentText != _lastText) {
      setState(() {
        _lastText = currentText;
      });
    }
  }

  void _onPastePressed() async {
    final sonner = ShadSonner.of(context);
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!;
        widget.controller.text = text;
        widget.onTextPasted?.call(text);

        // Show feedback
        if (mounted) {
          sonner.show(
            ShadToast.raw(
              variant: ShadToastVariant.primary,
              description: Text('text_pasted'.tr()),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        sonner.show(
          ShadToast.destructive(
            description: Text('paste_failed'.tr()),
          ),
        );
      }
    }
  }

  void _onClearPressed() {
    widget.controller.clear();
    widget.onTextCleared?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final isTextEmpty = widget.controller.text.isEmpty;
    final characterCount = widget.controller.text.length;
    final isNearLimit = characterCount > AppConstants.maxTextLength * 0.8;
    final isOverLimit = characterCount > AppConstants.maxTextLength;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(
                color: widget.isListening
                    ? AppColors.voiceActive
                    : _isFocused
                        ? AppColors.primary(brightness)
                        : AppColors.border(brightness),
                width: widget.isListening ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main text input area
                TextField(
                  onTapUpOutside: (event) => _focusNode.unfocus(),
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 4,
                  maxLength: AppConstants.maxTextLength,
                  style: AppTextStyles.translationInput.copyWith(
                    color: AppColors.primary(brightness),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder ??
                        'translation.enter_text_to_translate'.tr(),
                    hintStyle: AppTextStyles.translationInput.copyWith(
                      color: AppColors.mutedForeground(brightness),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.all(AppConstants.defaultPadding),
                    counterText: '', // Hide default counter
                  ),
                  textDirection: _getTextDirection(),
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                ),

                // Detected language info
                if (widget.detectedLanguage != null &&
                    widget.sourceLanguage == 'auto' &&
                    !isTextEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary(brightness).withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border(brightness),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.search_status,
                          size: AppConstants.iconSizeSmall,
                          color: AppColors.primary(brightness),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          'detected_language'.tr(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary(brightness),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          LanguageConstants.getLanguageFlag(
                              widget.detectedLanguage!),
                          style: const TextStyle(
                              fontSize: AppConstants.fontSizeRegular),
                        ),
                        const SizedBox(width: AppConstants.smallPadding / 2),
                        Text(
                          LanguageConstants.getLanguageName(
                              widget.detectedLanguage!),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary(brightness),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Bottom bar with actions and character count
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border(brightness),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Voice input button
                      VoiceInputButton(
                        onVoiceInput: widget.onVoiceInput,
                        sourceLanguage: widget.sourceLanguage,
                        detectedLanguage: widget.detectedLanguage,
                        isListening: widget.isListening,
                        size: VoiceInputSize.small,
                      ),

                      const SizedBox(width: AppConstants.smallPadding),

                      // Paste button
                      if (widget.showPasteButton && isTextEmpty) ...[
                        CustomButton(
                          text: 'paste'.tr(),
                          onPressed: _onPastePressed,
                          variant: ButtonVariant.ghost,
                          size: ButtonSize.small,
                          icon: Iconsax.clipboard_text,
                        ),
                      ],

                      // Clear button
                      if (widget.showClearButton && !isTextEmpty) ...[
                        CustomButton(
                          text: 'clear'.tr(),
                          onPressed: _onClearPressed,
                          variant: ButtonVariant.ghost,
                          size: ButtonSize.small,
                          icon: Iconsax.close_circle,
                        ),
                      ],

                      const Spacer(),

                      // Character count
                      if (widget.showCharacterCount) ...[
                        Text(
                          '$characterCount/${AppConstants.maxTextLength}',
                          style: AppTextStyles.caption.copyWith(
                            color: isOverLimit
                                ? (brightness == Brightness.light
                                    ? AppColors.lightDestructive
                                    : AppColors.darkDestructive)
                                : isNearLimit
                                    ? (brightness == Brightness.light
                                        ? AppColors.lightWarning
                                        : AppColors.darkWarning)
                                    : AppColors.mutedForeground(brightness),
                            fontWeight: isNearLimit || isOverLimit
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Length warning
                if (isOverLimit) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: brightness == Brightness.light
                          ? AppColors.lightDestructive.withOpacity(0.1)
                          : AppColors.darkDestructive.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.warning_2,
                          size: AppConstants.iconSizeSmall,
                          color: brightness == Brightness.light
                              ? AppColors.lightDestructive
                              : AppColors.darkDestructive,
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: Text(
                            'text_too_long_warning'.tr(),
                            style: AppTextStyles.caption.copyWith(
                              color: brightness == Brightness.light
                                  ? AppColors.lightDestructive
                                  : AppColors.darkDestructive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isNearLimit) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: brightness == Brightness.light
                          ? AppColors.lightWarning.withOpacity(0.1)
                          : AppColors.darkWarning.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          size: AppConstants.iconSizeSmall,
                          color: brightness == Brightness.light
                              ? AppColors.lightWarning
                              : AppColors.darkWarning,
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: Text(
                            AppUtils.getLengthWarningMessage(
                                    widget.controller.text) ??
                                'approaching_text_limit'.tr(),
                            style: AppTextStyles.caption.copyWith(
                              color: brightness == Brightness.light
                                  ? AppColors.lightWarning
                                  : AppColors.darkWarning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  ui.TextDirection _getTextDirection() {
    // Determine text direction based on detected language or source language
    final languageCode = widget.detectedLanguage ?? widget.sourceLanguage;
    if (languageCode != 'auto' &&
        LanguageConstants.isRtlLanguage(languageCode)) {
      return ui.TextDirection.rtl;
    }
    return ui.TextDirection.ltr;
  }
}
