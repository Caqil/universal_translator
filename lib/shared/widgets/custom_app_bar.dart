import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/utils/extensions.dart';

/// Custom app bar with consistent styling and functionality
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title of the app bar
  final String? title;

  /// Custom title widget
  final Widget? titleWidget;

  /// Leading widget (usually back button or menu)
  final Widget? leading;

  /// List of action widgets
  final List<Widget>? actions;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color for text and icons
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom height for the app bar
  final double? height;

  /// Whether to show border at the bottom
  final bool showBottomBorder;

  /// System overlay style
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Scroll controller for hiding/showing app bar
  final ScrollController? scrollController;

  /// Whether app bar should hide on scroll
  final bool hideOnScroll;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.height,
    this.showBottomBorder = true,
    this.systemOverlayStyle,
    this.scrollController,
    this.hideOnScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.background(brightness);
    final effectiveForegroundColor =
        foregroundColor ?? AppColors.primary(brightness);
    final effectiveSystemOverlayStyle = systemOverlayStyle ??
        (brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light);

    Widget appBar = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: AppColors.border(brightness),
                  width: 1,
                ),
              )
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.black10,
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: height ?? kToolbarHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Row(
            children: [
              // Leading
              if (_shouldShowLeading(context))
                _buildLeading(context, effectiveForegroundColor),

              // Title
              Expanded(
                child: _buildTitle(context, effectiveForegroundColor),
              ),

              // Actions
              if (actions != null) ...[
                const SizedBox(width: AppConstants.smallPadding),
                ..._buildActions(context, effectiveForegroundColor),
              ],
            ],
          ),
        ),
      ),
    );

    // Wrap with scroll-aware behavior if needed
    if (hideOnScroll && scrollController != null) {
      appBar = _ScrollAwareAppBar(
        scrollController: scrollController!,
        child: appBar,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: effectiveSystemOverlayStyle,
      child: appBar,
    );
  }

  bool _shouldShowLeading(BuildContext context) {
    if (leading != null) return true;
    if (!automaticallyImplyLeading) return false;
    return context.canPop;
  }

  Widget _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading!;

    return IconButton(
      onPressed: () => context.pop(),
      icon: Icon(
        Iconsax.arrow_left_2,
        color: foregroundColor,
        size: AppConstants.iconSizeRegular,
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      splashRadius: AppConstants.iconSizeRegular,
    );
  }

  Widget _buildTitle(BuildContext context, Color foregroundColor) {
    if (titleWidget != null) {
      return centerTitle
          ? Center(child: titleWidget!)
          : Align(alignment: Alignment.centerLeft, child: titleWidget!);
    }

    if (title == null) return const SizedBox.shrink();

    final titleStyle = AppTextStyles.titleLarge.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w600,
    );

    return centerTitle
        ? Center(
            child: Text(
              title!,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title!,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
  }

  List<Widget> _buildActions(BuildContext context, Color foregroundColor) {
    return actions!.map((action) {
      // Apply consistent styling to action buttons
      if (action is IconButton) {
        return IconButton(
          onPressed: action.onPressed,
          icon: action.icon,
          color: action.color ?? foregroundColor,
          iconSize: action.iconSize ?? AppConstants.iconSizeRegular,
          splashRadius: action.splashRadius ?? AppConstants.iconSizeRegular,
          tooltip: action.tooltip,
        );
      }
      return action;
    }).toList();
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);
}

class _ScrollAwareAppBar extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const _ScrollAwareAppBar({
    required this.scrollController,
    required this.child,
  });

  @override
  State<_ScrollAwareAppBar> createState() => _ScrollAwareAppBarState();
}

class _ScrollAwareAppBarState extends State<_ScrollAwareAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollDelta = widget.scrollController.position.userScrollDirection;

    if (scrollDelta == ScrollDirection.reverse && _isVisible) {
      _isVisible = false;
      _animationController.forward();
    } else if (scrollDelta == ScrollDirection.forward && !_isVisible) {
      _isVisible = true;
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
