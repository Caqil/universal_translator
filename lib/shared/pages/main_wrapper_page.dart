// lib/shared/pages/main_wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../config/routes/route_names.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../widgets/bottom_nav_bar.dart';

/// Main wrapper page that contains the bottom navigation
class MainWrapperPage extends StatefulWidget {
  /// The child widget (current page)
  final Widget child;

  const MainWrapperPage({
    super.key,
    required this.child,
  });

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  /// Get current tab index based on current route
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    switch (location) {
      case RouteNames.home:
        return 0;
      case RouteNames.camera:
        return 1;
      case RouteNames.conversation:
        return 2;
      case RouteNames.history:
        return 3;
      case RouteNames.favorites:
        return 4;
      default:
        return 0;
    }
  }

  /// Handle tab tap
  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.camera);
        break;
      case 2:
        context.go(RouteNames.conversation);
        break;
      case 3:
        context.go(RouteNames.history);
        break;
      case 4:
        context.go(RouteNames.favorites);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppColors.surface(brightness),
        selectedItemColor: AppColors.primary(brightness),
        unselectedItemColor: AppColors.mutedForeground(brightness),
      ),
      floatingActionButton: _buildFloatingActionButton(context, brightness),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Build floating action button for quick actions
  Widget? _buildFloatingActionButton(
      BuildContext context, Brightness brightness) {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(context),
      backgroundColor: AppColors.primary(brightness),
      foregroundColor: brightness == Brightness.light
          ? AppColors.lightPrimaryForeground
          : AppColors.darkPrimaryForeground,
      child: const Icon(Icons.translate_rounded),
      tooltip: 'quick_translate'.tr(),
    );
  }

  /// Show quick actions bottom sheet
  void _showQuickActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickActionsBottomSheet(),
    );
  }
}

/// Quick actions bottom sheet
class _QuickActionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.mutedForeground(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'quick_translate'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary(brightness),
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Actions
          _buildQuickAction(
            context,
            icon: Icons.keyboard_voice_rounded,
            title: 'voice_translate'.tr(),
            subtitle: 'speak_to_translate'.tr(),
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.voiceInput);
            },
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildQuickAction(
            context,
            icon: Icons.camera_alt_rounded,
            title: 'camera_translate'.tr(),
            subtitle: 'take_photo_to_translate'.tr(),
            onTap: () {
              Navigator.of(context).pop();
              context.go(RouteNames.camera);
            },
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildQuickAction(
            context,
            icon: Icons.settings_rounded,
            title: 'settings'.tr(),
            subtitle: 'app_settings'.tr(),
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.settings);
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final brightness = context.brightness;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.primary(brightness).withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
              child: Icon(
                icon,
                size: AppConstants.iconSizeRegular,
                color: AppColors.primary(brightness),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary(brightness),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground(brightness),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppConstants.iconSizeSmall,
              color: AppColors.mutedForeground(brightness),
            ),
          ],
        ),
      ),
    );
  }
}
