// lib/shared/widgets/quick_actions_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../config/routes/route_names.dart';

/// Quick actions bottom sheet
class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({super.key});

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
            'quick_translate',
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
            title: 'voice_translate',
            subtitle: 'speak_to_translate',
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.voiceInput);
            },
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildQuickAction(
            context,
            icon: Icons.camera_alt_rounded,
            title: 'camera_translate',
            subtitle: 'take_photo_to_translate',
            onTap: () {
              Navigator.of(context).pop();
              context.go(RouteNames.camera);
            },
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildQuickAction(
            context,
            icon: Icons.settings_rounded,
            title: 'settings',
            subtitle: 'app_settings',
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
