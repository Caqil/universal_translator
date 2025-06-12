// lib/features/translation/presentation/widgets/translation_output.dart - WITH MODAL
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation.dart';
import 'alternatives_modal.dart'; // Import the modal

/// Translation output widget displaying translated text with actions
class TranslationOutput extends StatefulWidget {
  /// Translation result
  final Translation translation;

  /// Target language code
  final String targetLanguage;

  /// List of supported languages
  final List<Language> supportedLanguages;

  /// Whether to show confidence score
  final bool showConfidence;

  /// Whether to show alternatives
  final bool showAlternatives;

  /// Whether the translation is favorited
  final bool isFavorite;

  /// Callback when favorite is toggled
  final VoidCallback? onFavoriteToggled;

  /// Callback when text-to-speech is requested (optional)
  final VoidCallback? onTextToSpeech;

  /// Whether text-to-speech is currently playing (not used, we manage internally)
  final bool isSpeaking;

  const TranslationOutput({
    super.key,
    required this.translation,
    required this.targetLanguage,
    required this.supportedLanguages,
    this.showConfidence = true,
    this.showAlternatives = true,
    this.isFavorite = false,
    this.onFavoriteToggled,
    this.onTextToSpeech,
    this.isSpeaking = false,
  });

  @override
  State<TranslationOutput> createState() => _TranslationOutputState();
}

class _TranslationOutputState extends State<TranslationOutput>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Single TTS instance
  FlutterTts? _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _initializeTTS();
  }

  @override
  void dispose() {
    _tts?.stop();
    _fadeController.dispose();
    super.dispose();
  }

  // Initialize TTS once
  Future<void> _initializeTTS() async {
    _tts = FlutterTts();

    // Set completion handler - stops when done
    _tts!.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });

    // Set error handler
    _tts!.setErrorHandler((msg) {
      if (mounted) {
        setState(() => _isSpeaking = false);
        context.showError('TTS Error: $msg');
      }
    });

    // Set start handler
    _tts!.setStartHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = true);
      }
    });
  }

  // Simple TTS function - only runs once per click
  Future<void> _handleTTSClick() async {
    if (_tts == null) return;

    try {
      if (_isSpeaking) {
        // Stop if currently speaking
        await _tts!.stop();
        setState(() => _isSpeaking = false);
        return;
      }

      // Start speaking the translated text
      final languageCode =
          LocalizationHelper.mapLanguageCode(widget.targetLanguage);

      await _tts!.setLanguage(languageCode);
      await _tts!.setSpeechRate(0.5);
      await _tts!.setPitch(1.0);
      await _tts!.setVolume(1.0);

      final result = await _tts!.speak(widget.translation.translatedText);

      if (result != 1) {
        // TTS failed to start
        setState(() => _isSpeaking = false);
        if (mounted) {
          context.showError('Failed to start text-to-speech');
        }
      }
    } catch (e) {
      setState(() => _isSpeaking = false);
      if (mounted) {
        context.showError('TTS Error: ${e.toString()}');
      }
    }
  }

  void _onCopyPressed() async {
    final sonner = ShadSonner.of(context);
    await Clipboard.setData(
        ClipboardData(text: widget.translation.translatedText));
    if (mounted) {
      sonner.show(
        ShadToast.raw(
          variant: ShadToastVariant.primary,
          description: Text('translation.copy_translation'.tr()),
        ),
      );
    }
  }

  void _onSharePressed() async {
    final sourceLanguageName =
        LanguageConstants.getLanguageName(widget.translation.sourceLanguage);
    final targetLanguageInfo = _getTargetLanguageInfo();

    final shareText = '''
${'translation.source_text'.tr()}: ${widget.translation.sourceText}
${'translation.translated_text'.tr()}: ${widget.translation.translatedText}
$sourceLanguageName → ${targetLanguageInfo.name}
${widget.showConfidence && widget.translation.confidence != null ? '${'translation.confidence'.tr()}: ${(widget.translation.confidence! * 100).toStringAsFixed(1)}%' : ''}
    ''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        context.showError('Share failed');
      }
    }
  }

  void _onFavoritePressed() async {
    final sonner = ShadSonner.of(context);

    try {
      if (widget.isFavorite) {
        sonner.show(
          ShadToast.raw(
            variant: ShadToastVariant.primary,
            description: Text('favorites.favorite_removed'.tr()),
          ),
        );
      } else {
        sonner.show(
          ShadToast.raw(
            variant: ShadToastVariant.primary,
            description: Text('favorites.favorite_added'.tr()),
          ),
        );
      }

      widget.onFavoriteToggled?.call();
    } catch (e) {
      sonner.show(
        ShadToast.destructive(
          description: Text('Favorite toggle failed'),
        ),
      );
    }
  }

  void _onFullScreenPressed() {
    showDialog(
      context: context,
      builder: (context) => _FullScreenTranslationDialog(
        translation: widget.translation,
        targetLanguage: widget.targetLanguage,
      ),
    );
  }

  // Open alternatives modal
  void _onAlternativesPressed() {
    showDialog(
      context: context,
      builder: (context) => AlternativesModal(
        alternatives: widget.translation.alternatives!,
        targetLanguage: widget.targetLanguage,
        primaryTranslation: widget.translation.translatedText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.card(brightness),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(brightness),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, brightness),
            _buildTranslationContent(context, brightness),
            if (widget.showConfidence && widget.translation.confidence != null)
              _buildConfidenceIndicator(context, brightness),
            if (widget.showAlternatives &&
                widget.translation.alternatives!.isNotEmpty)
              _buildAlternativesPreview(context, brightness),
            _buildActionButtons(context, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Brightness brightness) {
    final targetLanguageInfo = _getTargetLanguageInfo();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.muted(brightness),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.defaultBorderRadius),
          topRight: Radius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Text(
            targetLanguageInfo.flag,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  targetLanguageInfo.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground(brightness),
                  ),
                ),
                if (targetLanguageInfo.nativeName != targetLanguageInfo.name)
                  Text(
                    targetLanguageInfo.nativeName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedForeground(brightness),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _onFullScreenPressed,
            icon: Icon(
              Iconsax.maximize_1,
              color: AppColors.mutedForeground(brightness),
            ),
            iconSize: AppConstants.iconSizeSmall,
            tooltip: 'View fullscreen',
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationContent(BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SelectableText(
        widget.translation.translatedText,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.foreground(brightness),
          height: 1.5,
        ),
        textDirection: _getTextDirection(),
      ),
    );
  }

  Widget _buildConfidenceIndicator(
      BuildContext context, Brightness brightness) {
    final confidence = widget.translation.confidence!;
    final percentage = (confidence * 100).round();

    Color getConfidenceColor() {
      if (confidence >= 0.8) return AppColors.success(brightness);
      if (confidence >= 0.6) return AppColors.warning(brightness);
      return AppColors.destructive(brightness);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            size: AppConstants.iconSizeSmall,
            color: AppColors.mutedForeground(brightness),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'translation.confidence'.tr(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: AppColors.muted(brightness),
              valueColor: AlwaysStoppedAnimation<Color>(getConfidenceColor()),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            '$percentage%',
            style: AppTextStyles.bodySmall.copyWith(
              color: getConfidenceColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Clean alternatives preview - shows summary and button to open modal
  Widget _buildAlternativesPreview(
      BuildContext context, Brightness brightness) {
    final alternativesCount = widget.translation.alternatives!.length;
    final previewText = widget.translation.alternatives!.first;
    final maxPreviewLength = 60;
    final truncatedPreview = previewText.length > maxPreviewLength
        ? '${previewText.substring(0, maxPreviewLength)}...'
        : previewText;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.muted(brightness).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.border(brightness),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: _onAlternativesPressed,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Icon and count
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$alternativesCount',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alternative Translations',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground(brightness),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      truncatedPreview,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground(brightness),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Iconsax.arrow_right_3,
                size: AppConstants.iconSizeSmall,
                color: AppColors.mutedForeground(brightness),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          // Copy button
          CustomButton(
            text: 'copy'.tr(),
            onPressed: _onCopyPressed,
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            icon: Iconsax.copy,
          ),

          const SizedBox(width: AppConstants.smallPadding),

          // Share button
          CustomButton(
            text: 'app.share'.tr(),
            onPressed: _onSharePressed,
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            icon: Iconsax.share,
          ),

          const Spacer(),

          // Text-to-speech button - SINGLE IMPLEMENTATION
          IconButton(
            onPressed: _handleTTSClick, // Only calls once per click
            icon: Icon(
              _isSpeaking ? Iconsax.pause : Iconsax.volume_high,
              color: _isSpeaking
                  ? AppColors.voiceActive
                  : AppColors.mutedForeground(brightness),
            ),
            iconSize: AppConstants.iconSizeRegular,
            tooltip: _isSpeaking ? 'Stop speaking' : 'Speak text',
          ),

          // Favorite button
          IconButton(
            onPressed: _onFavoritePressed,
            icon: Icon(
              widget.isFavorite ? Iconsax.heart5 : Iconsax.heart,
              color: widget.isFavorite
                  ? AppColors.voiceActive
                  : AppColors.mutedForeground(brightness),
            ),
            iconSize: AppConstants.iconSizeRegular,
            tooltip: widget.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),
        ],
      ),
    );
  }

  _LanguageInfo _getTargetLanguageInfo() {
    final language = widget.supportedLanguages
        .where((lang) => lang.code == widget.targetLanguage)
        .firstOrNull;

    if (language != null) {
      return _LanguageInfo(
        code: language.code,
        name: language.name,
        nativeName: language.nativeName,
        flag: language.flag,
      );
    }

    // Fallback to constants
    return _LanguageInfo(
      code: widget.targetLanguage,
      name: LanguageConstants.getLanguageName(widget.targetLanguage),
      nativeName:
          LanguageConstants.getLanguageNativeName(widget.targetLanguage),
      flag: LanguageConstants.getLanguageFlag(widget.targetLanguage),
    );
  }

  ui.TextDirection? _getTextDirection() {
    try {
      if (LanguageConstants.isRtlLanguage(widget.targetLanguage)) {
        return ui.TextDirection.rtl;
      }
      return ui.TextDirection.ltr;
    } catch (e) {
      return ui.TextDirection.ltr;
    }
  }
}

class _FullScreenTranslationDialog extends StatelessWidget {
  final Translation translation;
  final String targetLanguage;

  const _FullScreenTranslationDialog({
    required this.translation,
    required this.targetLanguage,
  });

  ui.TextDirection? _getTextDirection() {
    try {
      if (LanguageConstants.isRtlLanguage(targetLanguage)) {
        return ui.TextDirection.rtl;
      }
      return ui.TextDirection.ltr;
    } catch (e) {
      return ui.TextDirection.ltr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          title: Text('Translated Text'),
          backgroundColor: AppColors.background(brightness),
          foregroundColor: AppColors.foreground(brightness),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Iconsax.arrow_left),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Source text
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.muted(brightness),
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source Text',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground(brightness),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    SelectableText(
                      translation.sourceText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.foreground(brightness),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Translated text
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.card(brightness),
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(
                      color: AppColors.border(brightness),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translated Text',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mutedForeground(brightness),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            translation.translatedText,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.foreground(brightness),
                              height: 1.6,
                            ),
                            textDirection: _getTextDirection(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class for language information
class _LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const _LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
