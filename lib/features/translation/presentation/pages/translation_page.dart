// lib/features/translation/presentation/pages/translation_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:translate_app/core/utils/extensions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
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
    with TickerProviderStateMixin {
  late TextEditingController _inputController;
  late AnimationController _swapAnimationController;
  late Animation<double> _swapAnimation;

  // Add debouncing for text changes
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
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
  }

  void _setupListeners() {
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Critical: Dispose all resources properly
    _debounceTimer?.cancel();
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _swapAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Debounce text changes to prevent excessive bloc events
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        final text = _inputController.text;
        context.read<TranslationBloc>().add(SetSourceTextEvent(text));
      }
    });
  }

  void _onTranslatePressed() {
    final state = context.read<TranslationBloc>().state;
    if (state.canTranslate) {
      // Cancel any pending debounce timer before translating
      _debounceTimer?.cancel();

      context.read<TranslationBloc>().add(TranslateTextEvent(
            text: state.sourceText,
            sourceLanguage: state.sourceLanguage,
            targetLanguage: state.targetLanguage,
          ));
    }
  }

  void _onSwapLanguages() async {
    // Prevent multiple rapid taps
    if (_swapAnimationController.isAnimating) return;

    await _swapAnimationController.forward();
    if (mounted) {
      context.read<TranslationBloc>().add(const SwapLanguagesEvent());
      await _swapAnimationController.reverse();
    }
  }

  void _onClearText() {
    _debounceTimer?.cancel();
    _inputController.clear();
    context.read<TranslationBloc>().add(const ClearTranslationEvent());
  }

  void _onVoiceInput(String text) {
    _debounceTimer?.cancel();
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
    final sonner = ShadSonner.of(context);
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
        // Optimize listener to only handle errors and specific state changes
        listenWhen: (previous, current) {
          return current.hasError ||
              (previous.status != current.status &&
                  current.status == TranslationStatus.initial);
        },
        listener: (context, state) {
          if (state.hasError) {
            sonner.show(
              ShadToast.destructive(
                description: Text(state.errorMessage ?? 'error_general'.tr()),
              ),
            );
          }

          // Update input text when swapping languages
          if (state.status == TranslationStatus.initial &&
              state.sourceText.isNotEmpty &&
              _inputController.text != state.sourceText) {
            _inputController.text = state.sourceText;
          }
        },
        // Optimize builder to reduce unnecessary rebuilds
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.supportedLanguages != current.supportedLanguages ||
              previous.sourceLanguage != current.sourceLanguage ||
              previous.targetLanguage != current.targetLanguage ||
              previous.currentTranslation != current.currentTranslation;
        },
        builder: (context, state) {
          if (state.status == TranslationStatus.loadingLanguages) {
            return CustomLoadingWidget.page(
              message: 'app.loading'.tr(),
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
                        _buildSourceTextInput(context, state, brightness),

                        const SizedBox(height: AppConstants.defaultPadding),

                        // Translation Output
                        if (state.currentTranslation != null)
                          _buildTranslationOutput(context, state, brightness),

                        const SizedBox(height: AppConstants.defaultPadding * 2),

                        // Translate Button
                        _buildTranslateButton(context, state, brightness),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.surface(brightness),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: LanguageSelector(
              selectedLanguage: state.sourceLanguage,
              supportedLanguages: state.supportedLanguages,
              //detectedLanguage: state.detectedLanguage,
              onLanguageSelected: (language) {
                context.read<TranslationBloc>().add(
                      SetSourceLanguageEvent(language),
                    );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding / 2,
            ),
            child: AnimatedBuilder(
              animation: _swapAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _swapAnimation.value * 3.14159,
                  child: IconButton(
                    onPressed: _onSwapLanguages,
                    icon: const Icon(Iconsax.arrow_swap_horizontal),
                    tooltip: 'translation.swap_languages'.tr(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: LanguageSelector(
              selectedLanguage: state.targetLanguage,
              supportedLanguages: state.supportedLanguages,
              onLanguageSelected: (language) {
                context.read<TranslationBloc>().add(
                      SetTargetLanguageEvent(language),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTextInput(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    return Card(
      elevation: 2,
      child: TranslationInput(
        controller: _inputController,
        onVoiceInput: _onVoiceInput,
        sourceLanguage: state.sourceLanguage,
        detectedLanguage: state.detectedLanguage,
        isListening: false, // Manage voice input state separately
        onTextCleared: _onClearText,
      ),
    );
  }

  Widget _buildTranslationOutput(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    return Card(
      elevation: 2,
      child: TranslationOutput(
        translation: state.currentTranslation!,
        targetLanguage: state.targetLanguage,
        supportedLanguages: state.supportedLanguages,
      ),
    );
  }

  Widget _buildTranslateButton(
    BuildContext context,
    TranslationState state,
    Brightness brightness,
  ) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'translation.translate'.tr(),
        onPressed: state.canTranslate ? _onTranslatePressed : null,
        isLoading: state.status == TranslationStatus.translating,
        icon: Iconsax.language_circle,
      ),
    );
  }
}
