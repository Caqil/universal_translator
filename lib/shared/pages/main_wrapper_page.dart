import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translate_app/features/settings/presentation/pages/settings_page.dart';
import 'package:translate_app/features/translation/presentation/pages/translation_page.dart';
import '../../config/routes/app_router.dart';
import '../../core/services/injection_container.dart';
import '../../core/themes/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/conversation/presentation/bloc/conversation_bloc.dart';
import '../../features/conversation/presentation/pages/conversation_page.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/history/presentation/pages/history_page.dart';
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
    BlocProvider(
      create: (context) {
        if (sl.isRegistered<ConversationBloc>()) {
          return sl<ConversationBloc>();
        } else {
          throw Exception('ConversationBloc dependencies not ready yet');
        }
      },
      child: const ConversationPage(
        user1Language: 'en',
        user2Language: 'es',
        user1LanguageName: 'English',
        user2LanguageName: 'Spanish',
      ),
    ),
    const CameraPage(),
    // In your navigation/routing, only create HistoryBloc when the page is actually accessed
    BlocProvider(
      create: (context) {
        // Only create if dependencies are ready
        if (sl.isRegistered<HistoryBloc>()) {
          return sl<HistoryBloc>();
        } else {
          throw Exception('History dependencies not ready yet');
        }
      },
      child: const HistoryPage(),
    ),
    const SettingsPage(),
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
        onTap: _onTabTapped,
        backgroundColor: AppColors.surface(brightness),
        selectedItemColor: AppColors.primary(brightness),
        unselectedItemColor: AppColors.mutedForeground(brightness),
      ),
    );
  }
}
