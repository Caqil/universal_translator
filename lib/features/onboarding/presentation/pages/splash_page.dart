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

/// Splash screen that handles app initialization and routing
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    // Logo scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Fade and slide animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize user preferences
      await UserPreferencesService.init();

      // Increment launch count
      await UserPreferencesService.incrementLaunchCount();

      // Minimum splash duration for UX
      await Future.delayed(AppConstants.splashScreenDuration);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Determine next route
        await _navigateToNextScreen();
      }
    } catch (error) {
      // Handle initialization error
      if (mounted) {
        _navigateToError(error.toString());
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Check if first launch
      final isFirstLaunch = await UserPreferencesService.isFirstLaunch;

      if (isFirstLaunch) {
        // First time user - go to onboarding
        if (mounted) {
          context.go(RouteNames.onboarding);
        }
      } else {
        // Returning user - go to main app
        if (mounted) {
          context.go(RouteNames.home);
        }
      }
    } catch (error) {
      // Fallback to home if preferences check fails
      if (mounted) {
        context.go(RouteNames.home);
      }
    }
  }

  void _navigateToError(String errorMessage) {
    context
        .go('${RouteNames.error}?message=${Uri.encodeComponent(errorMessage)}');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          statusBarBrightness: brightness,
          systemNavigationBarColor: AppColors.background(brightness),
          systemNavigationBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildSplashContent(brightness),
              ),
              _buildFooter(brightness),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplashContent(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with scale animation
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: _buildLogo(brightness),
              );
            },
          ),

          const SizedBox(height: AppConstants.largePadding),

          // App name and tagline with fade and slide animation
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.primary(brightness),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'app_description'.tr(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.mutedForeground(brightness),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppConstants.extraLargePadding),

          // Loading indicator
          _buildLoadingIndicator(brightness),
        ],
      ),
    );
  }

  Widget _buildLogo(Brightness brightness) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(brightness),
            AppColors.primary(brightness).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius * 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(brightness).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.translate_rounded,
        size: AppConstants.iconSizeExtraLarge * 1.5,
        color: brightness == Brightness.light
            ? AppColors.lightPrimaryForeground
            : AppColors.darkPrimaryForeground,
      ),
    );
  }

  Widget _buildLoadingIndicator(Brightness brightness) {
    if (!_isInitialized) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary(brightness),
          ),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.primary(brightness),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: 16,
        color: brightness == Brightness.light
            ? AppColors.lightPrimaryForeground
            : AppColors.darkPrimaryForeground,
      ),
    );
  }

  Widget _buildFooter(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value * 0.7,
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground(brightness),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.smallPadding),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value * 0.5,
                child: Text(
                  '© 2024 Universal Translator',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground(brightness),
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
