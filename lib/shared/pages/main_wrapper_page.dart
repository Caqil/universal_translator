// lib/shared/pages/main_wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../config/routes/route_names.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/quick_actions_bottom_sheet.dart';

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
        onTap: (i) {
          if (i == 2) {
            _showQuickActions(context);
          } else {
            _onTabTapped(i);
          }
        },
        backgroundColor: AppColors.surface(brightness),
        selectedItemColor: AppColors.primary(brightness),
        unselectedItemColor: AppColors.mutedForeground(brightness),
      ),
    );
  }

  /// Show quick actions bottom sheet
  void _showQuickActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsBottomSheet(),
    );
  }
}
