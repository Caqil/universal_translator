import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Onboarding data model
class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String? description;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.description,
  });
}

/// Onboarding page with multiple introduction screens
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<OnboardingData> _getOnboardingData(Brightness brightness) {
    return [
      OnboardingData(
        title: 'welcome_title'.tr(),
        subtitle: 'welcome_subtitle'.tr(),
        icon: Icons.waving_hand_rounded,
        gradientColors: [
          AppColors.primary(brightness),
          AppColors.primary(brightness).withOpacity(0.7),
        ],
      ),
      OnboardingData(
        title: 'feature_1_title'.tr(),
        subtitle: 'feature_1_subtitle'.tr(),
        icon: Icons.translate_rounded,
        gradientColors: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
        ],
        description:
            'Type or paste text in any language and get instant, accurate translations.',
      ),
      OnboardingData(
        title: 'feature_2_title'.tr(),
        subtitle: 'feature_2_subtitle'.tr(),
        icon: Icons.camera_alt_rounded,
        gradientColors: [
          const Color(0xFF10B981),
          const Color(0xFF059669),
        ],
        description:
            'Point your camera at signs, menus, documents, or any text to translate instantly.',
      ),
      OnboardingData(
        title: 'feature_3_title'.tr(),
        subtitle: 'feature_3_subtitle'.tr(),
        icon: Icons.keyboard_voice_rounded,
        gradientColors: [
          const Color(0xFFF59E0B),
          const Color(0xFFEAB308),
        ],
        description:
            'Speak naturally in any language and hear the translation spoken back to you.',
      ),
      OnboardingData(
        title: 'feature_4_title'.tr(),
        subtitle: 'feature_4_subtitle'.tr(),
        icon: Icons.chat_bubble_rounded,
        gradientColors: [
          const Color(0xFFEF4444),
          const Color(0xFFDC2626),
        ],
        description:
            'Have fluid conversations with people who speak different languages.',
      ),
    ];
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _getOnboardingData(context.brightness).length - 1;
    });
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      // Mark onboarding as completed
      await UserPreferencesService.setOnboardingCompleted();

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to main app
      if (mounted) {
        context.go(RouteNames.home);
      }
    } catch (error) {
      // Fallback navigation even if preferences fail
      if (mounted) {
        context.go(RouteNames.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final onboardingData = _getOnboardingData(brightness);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.background(brightness),
          systemNavigationBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(brightness),
              Expanded(
                child: _buildPageView(onboardingData, brightness),
              ),
              _buildBottomSection(brightness),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress indicator
          Expanded(
            child: Row(
              children: List.generate(
                _getOnboardingData(brightness).length,
                (index) => _buildProgressDot(index, brightness),
              ),
            ),
          ),

          // Skip button
          if (!_isLastPage)
            TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'skip'.tr(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.mutedForeground(brightness),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(int index, Brightness brightness) {
    final isActive = index <= _currentPage;

    return Expanded(
      child: Container(
        height: 4,
        margin: EdgeInsets.only(
          right: index < _getOnboardingData(brightness).length - 1
              ? AppConstants.smallPadding / 2
              : 0,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary(brightness)
              : AppColors.mutedForeground(brightness).withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPageView(List<OnboardingData> data, Brightness brightness) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildOnboardingPage(data[index], brightness);
      },
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, Brightness brightness) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            _buildFeatureIcon(data, brightness),

            const SizedBox(height: AppConstants.extraLargePadding),

            // Title
            Text(
              data.title,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary(brightness),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Subtitle
            Text(
              data.subtitle,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
              textAlign: TextAlign.center,
            ),

            // Description (if available)
            if (data.description != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface(brightness),
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(
                    color: AppColors.border(brightness),
                    width: 1,
                  ),
                ),
                child: Text(
                  data.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary(brightness),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(OnboardingData data, Brightness brightness) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius * 2),
        boxShadow: [
          BoxShadow(
            color: data.gradientColors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        data.icon,
        size: AppConstants.iconSizeExtraLarge * 1.5,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBottomSection(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main action button
          CustomButton(
            text: _isLastPage ? 'get_started'.tr() : 'next'.tr(),
            onPressed: _nextPage,
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            fullWidth: true,
            icon: _isLastPage
                ? Icons.rocket_launch_rounded
                : Icons.arrow_forward_rounded,
          ),

          // Previous button (if not first page)
          if (_currentPage > 0) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            CustomButton(
              text: 'previous'.tr(),
              onPressed: _previousPage,
              variant: ButtonVariant.outline,
              size: ButtonSize.medium,
              fullWidth: true,
              icon: Icons.arrow_back_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
