// lib/features/translation/presentation/widgets/alternatives_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';

class AlternativesModal extends StatefulWidget {
  final List<String> alternatives;
  final String targetLanguage;
  final String primaryTranslation;

  const AlternativesModal({
    super.key,
    required this.alternatives,
    required this.targetLanguage,
    required this.primaryTranslation,
  });

  @override
  State<AlternativesModal> createState() => _AlternativesModalState();
}

class _AlternativesModalState extends State<AlternativesModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredAlternatives = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredAlternatives = widget.alternatives;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredAlternatives = widget.alternatives;
      } else {
        _filteredAlternatives = widget.alternatives
            .where((alt) => alt.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  void _copyAlternative(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      final sonner = ShadSonner.of(context);
      sonner.show(
        ShadToast.raw(
          variant: ShadToastVariant.primary,
          description: Text('Alternative copied to clipboard'),
        ),
      );
    }
  }

  void _copyAllAlternatives() async {
    final allText = _filteredAlternatives.join('\n\n---\n\n');
    await Clipboard.setData(ClipboardData(text: allText));
    if (mounted) {
      final sonner = ShadSonner.of(context);
      sonner.show(
        ShadToast.raw(
          variant: ShadToastVariant.primary,
          description: Text('All alternatives copied to clipboard'),
        ),
      );
    }
  }

  ui.TextDirection? _getTextDirection() {
    // You can implement RTL detection based on target language
    return ui.TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: AppColors.background(brightness),
          body: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, brightness),

                  // Search bar
                  _buildSearchBar(context, brightness),

                  // Primary translation (for reference)
                  _buildPrimaryTranslation(context, brightness),

                  // Alternatives list
                  Expanded(
                    child: _buildAlternativesList(context, brightness),
                  ),

                  // Bottom actions
                  _buildBottomActions(context, brightness),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.card(brightness),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Iconsax.arrow_left),
            tooltip: 'Close',
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alternative Translations',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.foreground(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_filteredAlternatives.length} alternatives found',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedForeground(brightness),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _copyAllAlternatives,
            icon: const Icon(Iconsax.copy),
            tooltip: 'Copy all alternatives',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search alternatives...',
          prefixIcon: const Icon(Iconsax.search_normal),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Iconsax.close_circle),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide(color: AppColors.border(brightness)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide(color: AppColors.border(brightness)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide(color: AppColors.primary(brightness)),
          ),
          filled: true,
          fillColor: AppColors.card(brightness),
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.foreground(brightness),
        ),
      ),
    );
  }

  Widget _buildPrimaryTranslation(BuildContext context, Brightness brightness) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primary(brightness).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.primary(brightness).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.star1,
                size: AppConstants.iconSizeSmall,
                color: AppColors.primary(brightness),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Primary Translation',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyAlternative(widget.primaryTranslation),
                icon: Icon(
                  Iconsax.copy,
                  size: AppConstants.iconSizeSmall,
                  color: AppColors.primary(brightness),
                ),
                tooltip: 'Copy primary translation',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          SelectableText(
            widget.primaryTranslation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.foreground(brightness),
              height: 1.4,
            ),
            textDirection: _getTextDirection(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesList(BuildContext context, Brightness brightness) {
    if (_filteredAlternatives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 48,
              color: AppColors.mutedForeground(brightness),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              _searchQuery.isEmpty
                  ? 'No alternatives available'
                  : 'No alternatives match your search',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: AppConstants.smallPadding),
              CustomButton(
                text: 'Clear search',
                onPressed: () => _searchController.clear(),
                variant: ButtonVariant.outline,
                size: ButtonSize.small,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _filteredAlternatives.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: AppConstants.defaultPadding,
      ),
      itemBuilder: (context, index) {
        final alternative = _filteredAlternatives[index];
        final isLongText = alternative.length > 100;

        return _buildAlternativeCard(
          context,
          brightness,
          alternative,
          index,
          isLongText,
        );
      },
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    Brightness brightness,
    String alternative,
    int index,
    bool isLongText,
  ) {
    return Container(
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
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with index and actions
          Container(
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary(brightness),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    'Alternative ${index + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.foreground(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isLongText) ...[
                  Icon(
                    Iconsax.document_text,
                    size: AppConstants.iconSizeSmall,
                    color: AppColors.mutedForeground(brightness),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                ],
                Text(
                  '${alternative.length} chars',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedForeground(brightness),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                IconButton(
                  onPressed: () => _copyAlternative(alternative),
                  icon: const Icon(Iconsax.copy),
                  iconSize: AppConstants.iconSizeSmall,
                  tooltip: 'Copy alternative',
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SelectableText(
              alternative,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.foreground(brightness),
                height: 1.5,
              ),
              textDirection: _getTextDirection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.card(brightness),
        border: Border(
          top: BorderSide(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              variant: ButtonVariant.outline,
              icon: Iconsax.close_circle,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: CustomButton(
              text: 'Copy All (${_filteredAlternatives.length})',
              onPressed: _copyAllAlternatives,
              icon: Iconsax.copy,
            ),
          ),
        ],
      ),
    );
  }
}
