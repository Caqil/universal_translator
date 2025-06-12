// lib/features/onboarding/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/services/permission_service.dart';
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
  final bool isPermissionPage;
  final Permission? permission;
  final VoidCallback? onPermissionRequest;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.description,
    this.isPermissionPage = false,
    this.permission,
    this.onPermissionRequest,
  });
}

/// Onboarding page with multiple introduction screens and permissions
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

  // Permission states
  bool _microphoneGranted = false;
  bool _cameraGranted = false;
  bool _storageGranted = false;

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
    _checkExistingPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Check existing permission status
  Future<void> _checkExistingPermissions() async {
    final microphone = await PermissionService.hasMicrophonePermission;
    final camera = await PermissionService.hasCameraPermission;
    final storage = await PermissionService.hasStoragePermission;

    setState(() {
      _microphoneGranted = microphone;
      _cameraGranted = camera;
      _storageGranted = storage;
    });
  }

  /// Request microphone permission
  Future<void> _requestMicrophonePermission() async {
    print('🎤 Requesting microphone permission...');
    final status = await PermissionService.requestMicrophonePermission();

    setState(() {
      _microphoneGranted = status.isGranted;
    });

    if (status.isGranted) {
      _showPermissionGrantedMessage('microphone_permission'.tr());
      await Future.delayed(const Duration(milliseconds: 1000));
      _nextPage();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('microphone');
    } else {
      _showPermissionDeniedMessage('microphone_permission'.tr());
    }
  }

  /// Request camera permission
  Future<void> _requestCameraPermission() async {
    print('📷 Requesting camera permission...');
    final status = await PermissionService.requestCameraPermission();

    setState(() {
      _cameraGranted = status.isGranted;
    });

    if (status.isGranted) {
      _showPermissionGrantedMessage('camera_permission'.tr());
      await Future.delayed(const Duration(milliseconds: 1000));
      _nextPage();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('camera');
    } else {
      _showPermissionDeniedMessage('camera_permission'.tr());
    }
  }

  /// Request storage permission
  Future<void> _requestStoragePermission() async {
    print('💾 Requesting storage permission...');
    final status = await PermissionService.requestStoragePermission();

    setState(() {
      _storageGranted = status.isGranted;
    });

    if (status.isGranted) {
      _showPermissionGrantedMessage('storage_permission'.tr());
      await Future.delayed(const Duration(milliseconds: 1000));
      _nextPage();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('storage');
    } else {
      _showPermissionDeniedMessage('storage_permission'.tr());
    }
  }

  /// Show permission granted message
  void _showPermissionGrantedMessage(String permission) {
    HapticFeedback.lightImpact();
    ShadToaster.of(context).show(
      ShadToast(
        description: Text('$permission granted!'),
      ),
    );
  }

  /// Show permission denied message
  void _showPermissionDeniedMessage(String permission) {
    HapticFeedback.heavyImpact();
    ShadToaster.of(context).show(
      ShadToast(
        description: Text('$permission access denied!'),
      ),
    );
  }

  /// Show permission permanently denied dialog
  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('permission_denied'.tr()),
        content: Text(
          'To use $permissionType features, please enable permission in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextPage(); // Continue anyway
            },
            child: Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: Text('permission_settings'.tr()),
          ),
        ],
      ),
    );
  }

  List<OnboardingData> _getOnboardingData(Brightness brightness) {
    return [
      // Welcome & App Introduction Pages
      OnboardingData(
        title: 'onboarding.welcome_title'.tr(),
        subtitle: 'onboarding.welcome_subtitle'.tr(),
        icon: Icons.waving_hand_rounded,
        gradientColors: [
          AppColors.primary(brightness),
          AppColors.primary(brightness).withOpacity(0.7),
        ],
      ),
      OnboardingData(
        title: 'onboarding.feature_1_title'.tr(),
        subtitle: 'onboarding.feature_1_subtitle'.tr(),
        icon: Icons.translate_rounded,
        gradientColors: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
        ],
        description:
            'Type or paste text in any language and get instant, accurate translations.',
      ),
      OnboardingData(
        title: 'onboarding.feature_2_title'.tr(),
        subtitle: 'onboarding.feature_2_subtitle'.tr(),
        icon: Icons.camera_alt_rounded,
        gradientColors: [
          const Color(0xFF10B981),
          const Color(0xFF059669),
        ],
        description:
            'Point your camera at signs, menus, documents, or any text to translate instantly.',
      ),
      OnboardingData(
        title: 'onboarding.feature_3_title'.tr(),
        subtitle: 'onboarding.feature_3_subtitle'.tr(),
        icon: Icons.keyboard_voice_rounded,
        gradientColors: [
          const Color(0xFFF59E0B),
          const Color(0xFFEAB308),
        ],
        description:
            'Speak naturally in any language and hear the translation spoken back to you.',
      ),
      OnboardingData(
        title: 'onboarding.feature_4_title'.tr(),
        subtitle: 'onboarding.feature_4_subtitle'.tr(),
        icon: Icons.chat_bubble_rounded,
        gradientColors: [
          const Color(0xFFEF4444),
          const Color(0xFFDC2626),
        ],
        description:
            'Have fluid conversations with people who speak different languages.',
      ),

      // Permission Request Pages
      if (!_microphoneGranted)
        OnboardingData(
          title: 'onboarding.microphone_permission'.tr(),
          subtitle: 'onboarding.microphone_needed'.tr(),
          icon: Iconsax.microphone,
          gradientColors: [
            const Color(0xFF8B5CF6),
            const Color(0xFF7C3AED),
          ],
          description:
              'Enable microphone access to use voice translation features. You can always change this in Settings.',
          isPermissionPage: true,
          permission: Permission.microphone,
          onPermissionRequest: _requestMicrophonePermission,
        ),

      if (!_cameraGranted)
        OnboardingData(
          title: 'onboarding.camera_permission'.tr(),
          subtitle: 'onboarding.camera_needed'.tr(),
          icon: Iconsax.camera,
          gradientColors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
          description:
              'Enable camera access to translate text from photos. You can always change this in Settings.',
          isPermissionPage: true,
          permission: Permission.camera,
          onPermissionRequest: _requestCameraPermission,
        ),

      if (!_storageGranted)
        OnboardingData(
          title: 'onboarding.storage_permission'.tr(),
          subtitle: 'onboarding.storage_needed'.tr(),
          icon: Iconsax.folder,
          gradientColors: [
            const Color(0xFF6366F1),
            const Color(0xFF4F46E5),
          ],
          description:
              'Enable storage access to save your translations and favorites. You can always change this in Settings.',
          isPermissionPage: true,
          permission: Permission.storage,
          onPermissionRequest: _requestStoragePermission,
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

      // Log permission status for debugging
      final permissionSummary =
          await PermissionService.getPermissionStatusSummary();
      print('🔐 Onboarding completed with permissions: $permissionSummary');

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to main app
      if (mounted) {
        context.go(RouteNames.home);
      }
    } catch (error) {
      print('❌ Error completing onboarding: $error');
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
              // Skip button
              if (!_isLastPage) _buildSkipButton(brightness),

              // Page indicator
              _buildPageIndicator(brightness, onboardingData.length),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = onboardingData[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildOnboardingPage(data, brightness),
                    );
                  },
                ),
              ),

              // Bottom navigation
              _buildBottomSection(brightness, onboardingData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(Brightness brightness) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: TextButton(
          onPressed: _skipOnboarding,
          child: Text(
            'skip'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(Brightness brightness, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => AnimatedContainer(
            duration: AppConstants.defaultAnimationDuration,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          _buildFeatureIcon(data, brightness),

          const SizedBox(height: AppConstants.extraLargePadding),

          // Title
          Text(
            data.title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary(brightness),
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

  Widget _buildBottomSection(
      Brightness brightness, List<OnboardingData> onboardingData) {
    final currentData = onboardingData[_currentPage];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main action button
          CustomButton(
            text: currentData.isPermissionPage
                ? 'grant_permission'.tr()
                : _isLastPage
                    ? 'get_started'.tr()
                    : 'next'.tr(),
            onPressed: currentData.isPermissionPage
                ? currentData.onPermissionRequest ?? _nextPage
                : _nextPage,
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            fullWidth: true,
            icon: currentData.isPermissionPage
                ? Iconsax.shield_tick
                : _isLastPage
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
          ),

          // Skip button for permission pages
          if (currentData.isPermissionPage) ...[
            const SizedBox(height: AppConstants.smallPadding),
            TextButton(
              onPressed: _nextPage,
              child: Text(
                'Skip for now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedForeground(brightness),
                ),
              ),
            ),
          ],

          // Previous button (if not first page)
          if (_currentPage > 0 && !currentData.isPermissionPage) ...[
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
