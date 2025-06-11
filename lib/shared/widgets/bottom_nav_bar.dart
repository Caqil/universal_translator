// lib/shared/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_text_styles.dart';

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
    final theme = ShadTheme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.background;
    final effectiveSelectedColor =
        selectedItemColor ?? theme.colorScheme.primary;
    final effectiveUnselectedColor =
        unselectedItemColor ?? theme.colorScheme.mutedForeground;

    final items = _buildNavigationItems(context);

    return _buildLegacyBottomNavigationBar(
      context,
      items,
      effectiveBackgroundColor,
      effectiveSelectedColor,
      effectiveUnselectedColor,
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
      currentIndex: currentIndex == -1 ? 0 : currentIndex,
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
              ))
          .toList(),
    );
  }

  List<_NavigationItem> _buildNavigationItems(BuildContext context) {
    return [
      _NavigationItem(
        icon: Iconsax.home,
        activeIcon: Iconsax.home_15,
        label: 'navigation.home'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.search_normal,
        activeIcon: Iconsax.search_normal_1,
        label: 'navigation.search'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.translate,
        activeIcon: Iconsax.translate5,
        label: 'navigation.translate'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.clock,
        activeIcon: Iconsax.clock5,
        label: 'navigation.history'.tr(),
      ),
      _NavigationItem(
        icon: Iconsax.setting,
        activeIcon: Iconsax.setting1,
        label: 'navigation.settings'.tr(),
      ),
    ];
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const _NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _NavigationBarItem extends StatelessWidget {
  final _NavigationItem item;
  final bool isSelected;
  final bool isCenterItem;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;

  const _NavigationBarItem({
    required this.item,
    required this.isSelected,
    required this.isCenterItem,
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppConstants.fastAnimationDuration,
              padding: EdgeInsets.all(
                isCenterItem
                    ? AppConstants.defaultPadding
                    : AppConstants.smallPadding,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withOpacity(isCenterItem ? 0.15 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  isCenterItem
                      ? AppConstants.largeBorderRadius
                      : AppConstants.largeBorderRadius,
                ),
              ),
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: isCenterItem
                    ? AppConstants.iconSizeLarge
                    : AppConstants.iconSizeRegular,
              ),
            ),
            if (showLabel) ...[
              SizedBox(height: AppConstants.smallPadding / 2),
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: isCenterItem ? 11 : 10,
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
