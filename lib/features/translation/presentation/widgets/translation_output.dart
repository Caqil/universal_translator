import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation.dart';

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

  /// Callback when text-to-speech is requested
  final VoidCallback? onTextToSpeech;

  /// Whether text-to-speech is currently playing
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onCopyPressed() async {
    await Clipboard.setData(
        ClipboardData(text: widget.translation.translatedText));
    if (mounted) {
      context.showSuccess('text_copied'.tr());
    }
  }

  void _onSharePressed() async {
    final sourceLanguageName =
        LanguageConstants.getLanguageName(widget.translation.sourceLanguage);
    final targetLanguageName =
        LanguageConstants.getLanguageName(widget.translation.targetLanguage);

    final shareText = '''
${widget.translation.sourceText}

↓ $sourceLanguageName → $targetLanguageName

${widget.translation.translatedText}

${AppConstants.appName}
''';

    await Share.share(shareText, subject: 'translation_share_subject'.tr());
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

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with language info and confidence
            _buildHeader(context, brightness),

            const Divider(height: 1),

            // Translation text
            _buildTranslationText(context, brightness),

            // Alternatives (if available)
            if (widget.showAlternatives &&
                widget.translation.alternatives != null &&
                widget.translation.alternatives!.isNotEmpty) ...[
              const Divider(height: 1),
              _buildAlternatives(context, brightness),
            ],

            const Divider(height: 1),

            // Action buttons
            _buildActionButtons(context, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Brightness brightness) {
    final targetLanguageInfo = _getTargetLanguageInfo();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          // Target language info
          Row(
            children: [
              Text(
                targetLanguageInfo.flag,
                style: const TextStyle(fontSize: AppConstants.fontSizeLarge),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                targetLanguageInfo.name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Confidence score
          if (widget.showConfidence &&
              widget.translation.confidence != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: AppConstants.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color:
                    AppUtils.getConfidenceColor(widget.translation.confidence!)
                        .withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
                border: Border.all(
                  color: AppUtils.getConfidenceColor(
                      widget.translation.confidence!),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.verify,
                    size: AppConstants.iconSizeSmall,
                    color: AppUtils.getConfidenceColor(
                        widget.translation.confidence!),
                  ),
                  const SizedBox(width: AppConstants.smallPadding / 2),
                  Text(
                    AppUtils.formatConfidence(widget.translation.confidence!),
                    style: AppTextStyles.caption.copyWith(
                      color: AppUtils.getConfidenceColor(
                          widget.translation.confidence!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Full screen button
          IconButton(
            onPressed: _onFullScreenPressed,
            icon: const Icon(Iconsax.maximize_4),
            iconSize: AppConstants.iconSizeRegular,
            tooltip: 'view_fullscreen'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationText(BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SelectableText(
        widget.translation.translatedText,
        style: AppTextStyles.translationOutput.copyWith(
          color: AppColors.primary(brightness),
        ),
        textDirection: _getTextDirection(),
      ),
    );
  }

  Widget _buildAlternatives(BuildContext context, Brightness brightness) {
    final alternatives = widget.translation.alternatives!;
    final displayAlternatives =
        alternatives.take(3).toList(); // Show max 3 alternatives

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'alternatives'.tr(),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedForeground(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ...displayAlternatives.asMap().entries.map((entry) {
            final index = entry.key;
            final alternative = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < displayAlternatives.length - 1
                    ? AppConstants.smallPadding
                    : 0,
              ),
              child: InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: alternative));
                  if (mounted) {
                    context.showSuccess('alternative_copied'.tr());
                  }
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color:
                        AppColors.mutedForeground(brightness).withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallBorderRadius),
                    border: Border.all(
                      color: AppColors.border(brightness),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mutedForeground(brightness),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Text(
                          alternative,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary(brightness),
                          ),
                          textDirection: _getTextDirection(),
                        ),
                      ),
                      Icon(
                        Iconsax.copy,
                        size: AppConstants.iconSizeSmall,
                        color: AppColors.mutedForeground(brightness),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
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
            text: 'share'.tr(),
            onPressed: _onSharePressed,
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            icon: Iconsax.share,
          ),

          const Spacer(),

          // Text-to-speech button
          if (LanguageConstants.supportsTextToSpeech(
              widget.targetLanguage)) ...[
            IconButton(
              onPressed: widget.onTextToSpeech,
              icon: Icon(
                widget.isSpeaking ? Iconsax.pause : Iconsax.volume_high,
                color: widget.isSpeaking
                    ? AppColors.voiceActive
                    : AppColors.mutedForeground(brightness),
              ),
              iconSize: AppConstants.iconSizeRegular,
              tooltip:
                  widget.isSpeaking ? 'stop_speaking'.tr() : 'speak_text'.tr(),
            ),
          ],

          // Favorite button
          IconButton(
            onPressed: widget.onFavoriteToggled,
            icon: Icon(
              widget.isFavorite ? Iconsax.heart5 : Iconsax.heart,
              color: widget.isFavorite
                  ? AppColors.voiceActive
                  : AppColors.mutedForeground(brightness),
            ),
            iconSize: AppConstants.iconSizeRegular,
            tooltip: widget.isFavorite
                ? 'remove_from_favorites'.tr()
                : 'add_to_favorites'.tr(),
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
      // Fallback to LTR if there's any issue
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
      backgroundColor: AppColors.background(brightness),
      child: Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Iconsax.close_circle),
          ),
          title: Text(
            'translation_fullscreen'.tr(),
            style: AppTextStyles.titleLarge,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: translation.translatedText));
                if (context.mounted) {
                  context.showSuccess('text_copied'.tr());
                }
              },
              icon: const Icon(Iconsax.copy),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Center(
              child: SelectableText(
                translation.translatedText,
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.primary(brightness),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                textDirection: _getTextDirection(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
