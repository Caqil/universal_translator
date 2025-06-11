// lib/shared/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/utils/extensions.dart';

/// Custom bottom navigation bar for the translation app
class CustomBottomNavBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTap;

  /// Whether to show labels
  final bool showLabels;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  /// Elevation of the bottom navigation bar
  final double elevation;

  /// Whether to use Material 3 navigation bar style
  final bool useMaterial3Style;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = AppConstants.defaultElevation,
    this.useMaterial3Style = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.surface(brightness);
    final effectiveSelectedColor =
        selectedItemColor ?? AppColors.primary(brightness);
    final effectiveUnselectedColor =
        unselectedItemColor ?? AppColors.mutedForeground(brightness);

    final items = _buildNavigationItems(context);

    if (useMaterial3Style) {
      return _buildMaterial3NavigationBar(
        context,
        items,
        effectiveBackgroundColor,
        effectiveSelectedColor,
        effectiveUnselectedColor,
      );
    } else {
      return _buildLegacyBottomNavigationBar(
        context,
        items,
        effectiveBackgroundColor,
        effectiveSelectedColor,
        effectiveUnselectedColor,
      );
    }
  }

  Widget _buildMaterial3NavigationBar(
    BuildContext context,
    List<_NavigationItem> items,
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.border(context.brightness),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black10,
            blurRadius: AppConstants.defaultElevation,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.smallPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return Expanded(
                child: _NavigationBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  showLabel: showLabels,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyBottomNavigationBar(
    BuildContext context,
    List<_NavigationItem> items,
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      elevation: elevation,
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      selectedLabelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon, size: AppConstants.iconSizeRegular),
                activeIcon: Icon(item.activeIcon ?? item.icon,
                    size: AppConstants.iconSizeRegular),
                label: item.label,
                tooltip: item.tooltip,
              ))
          .toList(),
    );
  }

  List<_NavigationItem> _buildNavigationItems(BuildContext context) {
    return [
      _NavigationItem(
        icon: Iconsax.translate,
        activeIcon: Iconsax.translate5,
        label: 'navigation.nav_translate'.tr(),
        tooltip: 'navigation.nav_translate_tooltip'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.camera,
        activeIcon: Iconsax.camera5,
        label: 'navigation.nav_camera'.tr(),
        tooltip: 'navigation.nav_camera_tooltip'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.message,
        activeIcon: Iconsax.message5,
        label: 'navigation.nav_conversation'.tr(),
        tooltip: 'navigation.nav_conversation_tooltip'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.clock,
        activeIcon: Iconsax.clock5,
        label: 'navigation.nav_history'.tr(),
        tooltip: 'navigation.nav_history_tooltip'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.heart,
        activeIcon: Iconsax.heart5,
        label: 'navigation.nav_favorites'.tr(),
        tooltip: 'navigation.nav_favorites_tooltip'.tr(),
      ),
    ];
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? tooltip;

  const _NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
  });
}

class _NavigationBarItem extends StatelessWidget {
  final _NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;

  const _NavigationBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppConstants.fastAnimationDuration,
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: AppConstants.iconSizeRegular,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: AppConstants.smallPadding / 2),
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
