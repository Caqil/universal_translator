import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/language.dart';

/// Language selector widget with dropdown or modal selection
class LanguageSelector extends StatefulWidget {
  /// Currently selected language code
  final String selectedLanguage;

  /// List of supported languages
  final List<Language> supportedLanguages;

  /// Whether to show auto-detect option
  final bool showAutoDetect;

  /// Callback when language is selected
  final ValueChanged<String> onLanguageSelected;

  /// Label text
  final String? label;

  /// Whether to use compact style
  final bool isCompact;

  /// Filter for popular languages only
  final bool showPopularOnly;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.supportedLanguages,
    required this.onLanguageSelected,
    this.showAutoDetect = false,
    this.label,
    this.isCompact = false,
    this.showPopularOnly = false,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final selectedLanguageInfo = _getSelectedLanguageInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && !widget.isCompact) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],
        _buildLanguageButton(context, selectedLanguageInfo, brightness),
      ],
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    _LanguageInfo selectedLanguageInfo,
    Brightness brightness,
  ) {
    return InkWell(
      onTap: () => _showLanguageSelector(context),
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: EdgeInsets.all(
          widget.isCompact
              ? AppConstants.smallPadding
              : AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            // Flag
            Text(
              selectedLanguageInfo.flag,
              style: TextStyle(
                fontSize: widget.isCompact
                    ? AppConstants.fontSizeMedium
                    : AppConstants.fontSizeLarge,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),

            // Language name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguageInfo.name,
                    style: (widget.isCompact
                            ? AppTextStyles.bodySmall
                            : AppTextStyles.bodyMedium)
                        .copyWith(
                      color: AppColors.primary(brightness),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!widget.isCompact &&
                      selectedLanguageInfo.nativeName !=
                          selectedLanguageInfo.name) ...[
                    const SizedBox(height: 2),
                    Text(
                      selectedLanguageInfo.nativeName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground(brightness),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Dropdown arrow
            Icon(
              Iconsax.arrow_down_1,
              size: widget.isCompact
                  ? AppConstants.iconSizeSmall
                  : AppConstants.iconSizeRegular,
              color: AppColors.mutedForeground(brightness),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectorModal(
        selectedLanguage: widget.selectedLanguage,
        supportedLanguages: widget.supportedLanguages,
        showAutoDetect: widget.showAutoDetect,
        showPopularOnly: widget.showPopularOnly,
      ),
    ).then((selectedLanguage) {
      if (selectedLanguage != null) {
        widget.onLanguageSelected(selectedLanguage);
      }
    });
  }

  _LanguageInfo _getSelectedLanguageInfo() {
    if (widget.selectedLanguage == LanguageConstants.autoDetectCode) {
      return _LanguageInfo(
        code: LanguageConstants.autoDetectCode,
        name: LanguageConstants.autoDetectName,
        nativeName: LanguageConstants.autoDetectNativeName,
        flag: '🌍',
      );
    }

    final language = widget.supportedLanguages
        .where((lang) => lang.code == widget.selectedLanguage)
        .firstOrNull;

    if (language != null) {
      return _LanguageInfo(
        code: language.code,
        name: language.name,
        nativeName: language.nativeName,
        flag: language.flag,
      );
    }

    // Fallback to constants if not found in supported languages
    return _LanguageInfo(
      code: widget.selectedLanguage,
      name: LanguageConstants.getLanguageName(widget.selectedLanguage),
      nativeName:
          LanguageConstants.getLanguageNativeName(widget.selectedLanguage),
      flag: LanguageConstants.getLanguageFlag(widget.selectedLanguage),
    );
  }
}

class _LanguageSelectorModal extends StatefulWidget {
  final String selectedLanguage;
  final List<Language> supportedLanguages;
  final bool showAutoDetect;
  final bool showPopularOnly;

  const _LanguageSelectorModal({
    required this.selectedLanguage,
    required this.supportedLanguages,
    required this.showAutoDetect,
    required this.showPopularOnly,
  });

  @override
  State<_LanguageSelectorModal> createState() => _LanguageSelectorModalState();
}

class _LanguageSelectorModalState extends State<_LanguageSelectorModal> {
  late TextEditingController _searchController;
  List<Language> _filteredLanguages = [];
  bool _showPopular = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLanguages = widget.supportedLanguages;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredLanguages = _filterLanguages(_searchController.text);
    });
  }

  List<Language> _filterLanguages(String query) {
    if (query.isEmpty) {
      return _showPopular ? _getPopularLanguages() : widget.supportedLanguages;
    }

    final lowercaseQuery = query.toLowerCase();
    return widget.supportedLanguages.where((language) {
      return language.name.toLowerCase().contains(lowercaseQuery) ||
          language.nativeName.toLowerCase().contains(lowercaseQuery) ||
          language.code.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Language> _getPopularLanguages() {
    final popularCodes = LanguageConstants.popularLanguageCodes;
    final popularLanguages = <Language>[];

    for (final code in popularCodes) {
      final language = widget.supportedLanguages
          .where((lang) => lang.code == code)
          .firstOrNull;
      if (language != null) {
        popularLanguages.add(language);
      }
    }

    return popularLanguages;
  }

  void _toggleShowAllLanguages() {
    setState(() {
      _showPopular = !_showPopular;
      _filteredLanguages = _filterLanguages(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Container(
      height: context.screenHeight * 0.8,
      decoration: BoxDecoration(
        color: AppColors.background(brightness),
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
            margin: const EdgeInsets.symmetric(
                vertical: AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.mutedForeground(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'select_language'.tr(),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Iconsax.close_circle),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: CustomTextField(
              controller: _searchController,
              hint: 'search_languages'.tr(),
              prefixIcon: Iconsax.search_normal,
              variant: TextFieldVariant.outlined,
            ),
          ),

          // Show All/Popular Toggle
          if (widget.supportedLanguages.length > 20) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              child: Row(
                children: [
                  CustomButton(
                    text: _showPopular
                        ? 'show_all_languages'.tr()
                        : 'show_popular'.tr(),
                    onPressed: _toggleShowAllLanguages,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    icon: _showPopular ? Iconsax.global : Iconsax.star,
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredLanguages.length} ${'languages'.tr()}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground(brightness),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Language List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              itemCount: _getItemCount(),
              itemBuilder: (context, index) {
                if (widget.showAutoDetect && index == 0) {
                  return _buildLanguageItem(
                    context,
                    _LanguageInfo(
                      code: LanguageConstants.autoDetectCode,
                      name: LanguageConstants.autoDetectName,
                      nativeName: LanguageConstants.autoDetectNativeName,
                      flag: '🌍',
                    ),
                    brightness,
                  );
                }

                final languageIndex = widget.showAutoDetect ? index - 1 : index;
                final language = _filteredLanguages[languageIndex];

                return _buildLanguageItem(
                  context,
                  _LanguageInfo(
                    code: language.code,
                    name: language.name,
                    nativeName: language.nativeName,
                    flag: language.flag,
                  ),
                  brightness,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getItemCount() {
    return _filteredLanguages.length + (widget.showAutoDetect ? 1 : 0);
  }

  Widget _buildLanguageItem(
    BuildContext context,
    _LanguageInfo language,
    Brightness brightness,
  ) {
    final isSelected = language.code == widget.selectedLanguage;

    return InkWell(
      onTap: () => Navigator.of(context).pop(language.code),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary(brightness).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            // Flag
            Text(
              language.flag,
              style: const TextStyle(fontSize: AppConstants.fontSizeLarge),
            ),
            const SizedBox(width: AppConstants.defaultPadding),

            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary(brightness),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (language.nativeName != language.name) ...[
                    const SizedBox(height: 2),
                    Text(
                      language.nativeName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground(brightness),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selected indicator
            if (isSelected) ...[
              Icon(
                Iconsax.tick_circle5,
                color: AppColors.primary(brightness),
                size: AppConstants.iconSizeRegular,
              ),
            ],
          ],
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
