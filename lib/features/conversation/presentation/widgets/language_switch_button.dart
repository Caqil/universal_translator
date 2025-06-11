// lib/features/conversation/presentation/widgets/language_switch_button.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';

/// Widget for displaying and switching between source and target languages
class LanguageSwitchButton extends StatefulWidget {
  /// Current source language code
  final String sourceLanguage;

  /// Current target language code
  final String targetLanguage;

  /// Callback when languages should be swapped
  final VoidCallback? onSwap;

  /// Callback when source language is changed
  final Function(String)? onSourceLanguageChanged;

  /// Callback when target language is changed
  final Function(String)? onTargetLanguageChanged;

  /// Whether the swap button is enabled
  final bool canSwap;

  /// Custom styling for the button
  final ButtonStyle? style;

  /// Size of the button
  final Size? size;

  /// Whether to show language names or just codes
  final bool showLanguageNames;

  const LanguageSwitchButton({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.onSwap,
    this.onSourceLanguageChanged,
    this.onTargetLanguageChanged,
    this.canSwap = true,
    this.style,
    this.size,
    this.showLanguageNames = false,
  });

  @override
  State<LanguageSwitchButton> createState() => _LanguageSwitchButtonState();
}

class _LanguageSwitchButtonState extends State<LanguageSwitchButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border(brightness),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageButton(
              context,
              brightness,
              widget.sourceLanguage,
              isSource: true,
            ),
            _buildSwapButton(context, brightness),
            _buildLanguageButton(
              context,
              brightness,
              widget.targetLanguage,
              isSource: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    Brightness brightness,
    String languageCode, {
    required bool isSource,
  }) {
    final languageInfo = LanguageConstants.languages
        .firstWhere((lang) => lang.code == languageCode);

    return InkWell(
      onTap: () => _showLanguageSelector(context, isSource),
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language flag or icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary(brightness).withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  languageInfo.flag,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),

            // Language code or name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.showLanguageNames
                      ? languageInfo.name
                      : languageCode.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary(brightness),
                  ),
                ),
                if (widget.showLanguageNames)
                  Text(
                    languageCode.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.mutedForeground(brightness),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 4),
            Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: AppColors.mutedForeground(brightness),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context, Brightness brightness) {
    return Container(
      width: 1,
      color: AppColors.border(brightness),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 3.14159, // 180 degrees
            child: IconButton(
              onPressed: widget.canSwap ? _handleSwap : null,
              icon: Icon(
                Iconsax.arrow_swap_horizontal,
                size: 20,
                color: widget.canSwap
                    ? AppColors.primary(brightness)
                    : AppColors.mutedForeground(brightness),
              ),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              padding: EdgeInsets.zero,
            ),
          );
        },
      ),
    );
  }

  void _handleSwap() {
    if (!widget.canSwap) return;

    _rotationController.forward().then((_) {
      _rotationController.reset();
    });

    widget.onSwap?.call();
  }

  void _showLanguageSelector(BuildContext context, bool isSource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectorBottomSheet(
        currentLanguage:
            isSource ? widget.sourceLanguage : widget.targetLanguage,
        excludeLanguage:
            isSource ? widget.targetLanguage : widget.sourceLanguage,
        onLanguageSelected: (languageCode) {
          if (isSource) {
            widget.onSourceLanguageChanged?.call(languageCode);
          } else {
            widget.onTargetLanguageChanged?.call(languageCode);
          }
        },
        isSource: isSource,
      ),
    );
  }
}

/// Bottom sheet for selecting languages
class _LanguageSelectorBottomSheet extends StatefulWidget {
  final String currentLanguage;
  final String? excludeLanguage;
  final Function(String) onLanguageSelected;
  final bool isSource;

  const _LanguageSelectorBottomSheet({
    required this.currentLanguage,
    this.excludeLanguage,
    required this.onLanguageSelected,
    required this.isSource,
  });

  @override
  State<_LanguageSelectorBottomSheet> createState() =>
      _LanguageSelectorBottomSheetState();
}

class _LanguageSelectorBottomSheetState
    extends State<_LanguageSelectorBottomSheet> {
  late TextEditingController _searchController;
  List<LanguageInfo> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLanguages = LanguageConstants.languages;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLanguages = LanguageConstants.languages.where((language) {
        return language.name.toLowerCase().contains(query) ||
            language.code.toLowerCase().contains(query) ||
            language.nativeName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.mutedForeground(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                Text(
                  widget.isSource
                      ? 'select_source_language'.tr()
                      : 'select_target_language'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_languages'.tr(),
                    prefixIcon: const Icon(Iconsax.search_normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background(brightness),
                  ),
                ),
              ],
            ),
          ),

          // Language list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                final isSelected = language.code == widget.currentLanguage;
                final isExcluded = language.code == widget.excludeLanguage;

                return ListTile(
                  enabled: !isExcluded,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? AppColors.primary(brightness)
                          : AppColors.mutedForeground(brightness)
                              .withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    language.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isExcluded
                          ? AppColors.mutedForeground(brightness)
                          : AppColors.foreground(brightness),
                    ),
                  ),
                  subtitle: Text(
                    '${language.nativeName} • ${language.code.toUpperCase()}',
                    style: TextStyle(
                      color: isExcluded
                          ? AppColors.mutedForeground(brightness)
                          : AppColors.mutedForeground(brightness),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Iconsax.tick_circle,
                          color: AppColors.primary(brightness),
                        )
                      : isExcluded
                          ? Icon(
                              Iconsax.close_circle,
                              color: AppColors.mutedForeground(brightness),
                            )
                          : null,
                  onTap: isExcluded
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onLanguageSelected(language.code);
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
