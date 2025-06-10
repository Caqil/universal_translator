import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:translate_app/core/utils/extensions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/translation_bloc.dart';
import '../bloc/translation_event.dart';
import '../bloc/translation_state.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_input.dart';
import '../widgets/translation_output.dart';

class TranslationPage extends StatelessWidget {
  const TranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.get<TranslationBloc>()
        ..add(const LoadSupportedLanguagesEvent()),
      child: const TranslationView(),
    );
  }
}

class TranslationView extends StatefulWidget {
  const TranslationView({super.key});

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _inputController;
  late AnimationController _swapAnimationController;
  late Animation<double> _swapAnimation;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _swapAnimationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _swapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swapAnimationController,
      curve: Curves.easeInOut,
    ));

    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _swapAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _inputController.text;
    context.read<TranslationBloc>().add(SetSourceTextEvent(text));
  }

  void _onTranslatePressed() {
    final state = context.read<TranslationBloc>().state;
    if (state.canTranslate) {
      context.read<TranslationBloc>().add(TranslateTextEvent(
            text: state.sourceText,
            sourceLanguage: state.sourceLanguage,
            targetLanguage: state.targetLanguage,
          ));
    }
  }

  void _onSwapLanguages() {
    _swapAnimationController.forward().then((_) {
      context.read<TranslationBloc>().add(const SwapLanguagesEvent());
      _swapAnimationController.reverse();
    });
  }

  void _onClearText() {
    _inputController.clear();
    context.read<TranslationBloc>().add(const ClearTranslationEvent());
  }

  void _onVoiceInput(String text) {
    _inputController.text = text;
    context.read<TranslationBloc>().add(SetSourceTextEvent(text));
  }

  void _onDetectLanguage() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      context.read<TranslationBloc>().add(DetectLanguageEvent(text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: CustomAppBar(
        title: 'translation_title'.tr(),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onClearText,
            icon: const Icon(Iconsax.refresh),
            tooltip: 'translation_clear'.tr(),
          ),
        ],
      ),
      body: BlocConsumer<TranslationBloc, TranslationState>(
        listener: (context, state) {
          if (state.hasError) {
            context.showError(state.errorMessage ?? 'error_general'.tr());
          }

          // Update input text when swapping languages
          if (state.status == TranslationStatus.initial &&
              state.sourceText.isNotEmpty &&
              _inputController.text != state.sourceText) {
            _inputController.text = state.sourceText;
          }
        },
        builder: (context, state) {
          if (state.status == TranslationStatus.loadingLanguages) {
            return CustomLoadingWidget.page(
              message: 'loading_languages'.tr(),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Language Selection Header
                _buildLanguageSelectionHeader(context, state, brightness),

                // Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        // Source Text Input
                        _buildSourceSection(context, state, brightness),

                        const SizedBox(height: AppConstants.largePadding),

                        // Translate Button
                        _buildTranslateButton(context, state, brightness),

                        const SizedBox(height: AppConstants.largePadding),

                        // Translation Output
                        _buildOutputSection(context, state, brightness),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelectionHeader(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Source Language Selector
          Expanded(
            child: LanguageSelector(
              selectedLanguage: state.sourceLanguage,
              supportedLanguages: state.supportedLanguages,
              showAutoDetect: true,
              onLanguageSelected: (languageCode) {
                context
                    .read<TranslationBloc>()
                    .add(SetSourceLanguageEvent(languageCode));
              },
              label: 'source_language'.tr(),
            ),
          ),

          // Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
            ),
            child: AnimatedBuilder(
              animation: _swapAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _swapAnimation.value * 3.14159,
                  child: IconButton(
                    onPressed: state.canSwapLanguages ? _onSwapLanguages : null,
                    icon: const Icon(Iconsax.arrow_swap_horizontal),
                    iconSize: AppConstants.iconSizeLarge,
                    tooltip: 'swap_languages'.tr(),
                    style: IconButton.styleFrom(
                      backgroundColor: state.canSwapLanguages
                          ? AppColors.primary(brightness).withOpacity(0.1)
                          : AppColors.mutedForeground(brightness)
                              .withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Target Language Selector
          Expanded(
            child: LanguageSelector(
              selectedLanguage: state.targetLanguage,
              supportedLanguages: state.supportedLanguages,
              showAutoDetect: false,
              onLanguageSelected: (languageCode) {
                context
                    .read<TranslationBloc>()
                    .add(SetTargetLanguageEvent(languageCode));
              },
              label: 'target_language'.tr(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    return Container(
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
          // Header with actions
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'enter_text'.tr(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (state.sourceLanguage == 'auto' &&
                    _inputController.text.isNotEmpty) ...[
                  CustomButton(
                    text: 'detect_language'.tr(),
                    onPressed: _onDetectLanguage,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    icon: Iconsax.search_status,
                    isLoading:
                        state.status == TranslationStatus.detectingLanguage,
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Text Input
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TranslationInput(
              controller: _inputController,
              onVoiceInput: _onVoiceInput,
              sourceLanguage: state.sourceLanguage,
              detectedLanguage: state.detectedLanguage,
              isListening: false, // This would come from speech bloc
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    return CustomButton(
      text: 'translate'.tr(),
      onPressed: state.canTranslate ? _onTranslatePressed : null,
      variant: ButtonVariant.primary,
      size: ButtonSize.large,
      fullWidth: true,
      icon: Iconsax.translate,
      isLoading: state.status == TranslationStatus.translating,
      isDisabled: !state.canTranslate,
    );
  }

  Widget _buildOutputSection(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    if (state.status == TranslationStatus.translating) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomLoadingWidget.translation(
            message: 'translating_text'.tr(),
          ),
        ),
      );
    }

    if (state.hasError) {
      return CustomErrorWidget.translation(
        message: state.errorMessage,
        onRetry: _onTranslatePressed,
        variant: ErrorVariant.card,
      );
    }

    if (!state.hasTranslation) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.translate,
                size: AppConstants.iconSizeExtraLarge,
                color: AppColors.mutedForeground(brightness),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'translation_placeholder'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedForeground(brightness),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return TranslationOutput(
      translation: state.currentTranslation!,
      targetLanguage: state.targetLanguage,
      supportedLanguages: state.supportedLanguages,
    );
  }
}
