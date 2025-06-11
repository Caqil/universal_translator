import 'package:flutter/material.dart';
import 'package:translate_app/features/translation/presentation/pages/translation_page.dart';
import '../../config/routes/app_router.dart';
import '../../core/themes/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/quick_actions_bottom_sheet.dart';

/// Main wrapper page with bottom navigation using IndexedStack
class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  /// Current tab index
  int _currentIndex = 0;

  /// List of pages for IndexedStack
  final List<Widget> _pages = [
    const TranslationPage(),
    const CameraPage(),
    const ConversationPage(),
    const HistoryPage(),
    const FavoritesPage(),
  ];

  /// Handle tab tap
  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
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
