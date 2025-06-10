import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/validators.dart';

/// Text field variants
enum TextFieldVariant {
  outlined,
  filled,
  underlined,
}

/// Custom text field with consistent styling and validation
class CustomTextField extends StatefulWidget {
  /// Text editing controller
  final TextEditingController? controller;

  /// Initial value
  final String? initialValue;

  /// Label text
  final String? label;

  /// Hint text
  final String? hint;

  /// Helper text
  final String? helperText;

  /// Error text
  final String? errorText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Custom prefix widget
  final Widget? prefix;

  /// Custom suffix widget
  final Widget? suffix;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is read-only
  final bool readOnly;

  /// Whether field is enabled
  final bool enabled;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether to show character counter
  final bool showCounter;

  /// Maximum length of text
  final int? maxLength;

  /// Maximum number of lines
  final int? maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Text input type
  final TextInputType keyboardType;

  /// Text input action
  final TextInputAction textInputAction;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Validator function
  final Validator<String?>? validator;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when editing is complete
  final VoidCallback? onEditingComplete;

  /// Callback when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Callback when suffix icon is pressed
  final VoidCallback? onSuffixPressed;

  /// Focus node
  final FocusNode? focusNode;

  /// Text field variant
  final TextFieldVariant variant;

  /// Custom border radius
  final double? borderRadius;

  /// Whether to auto-focus
  final bool autofocus;

  /// Auto-validation mode
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.isRequired = false,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.showCounter = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onSuffixPressed,
    this.focusNode,
    this.variant = TextFieldVariant.outlined,
    this.borderRadius,
    this.autofocus = false,
    this.autovalidateMode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final decoration = _buildInputDecoration(context, brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(brightness),
          const SizedBox(height: AppConstants.smallPadding),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          autovalidateMode: widget.autovalidateMode,
          decoration: decoration,
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.enabled
                ? AppColors.primary(brightness)
                : AppColors.mutedForeground(brightness),
          ),
          validator: widget.validator != null
              ? (value) {
                  final result = widget.validator!(value);
                  return result.isValid ? null : result.errorMessage;
                }
              : null,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
        ),
        if (widget.helperText != null && _errorText == null) ...[
          const SizedBox(height: AppConstants.smallPadding / 2),
          _buildHelperText(brightness),
        ],
        if (widget.showCounter && widget.maxLength != null) ...[
          const SizedBox(height: AppConstants.smallPadding / 2),
          _buildCounter(brightness),
        ],
      ],
    );
  }

  Widget _buildLabel(Brightness brightness) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary(brightness),
        ),
        children: [
          TextSpan(text: widget.label!),
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: brightness == Brightness.light
                    ? AppColors.lightDestructive
                    : AppColors.darkDestructive,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText(Brightness brightness) {
    return Text(
      widget.helperText!,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.mutedForeground(brightness),
      ),
    );
  }

  Widget _buildCounter(Brightness brightness) {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxLength!;
    final isNearLimit = currentLength > maxLength * 0.8;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$currentLength/$maxLength',
        style: AppTextStyles.caption.copyWith(
          color: isNearLimit
              ? (brightness == Brightness.light
                  ? AppColors.lightWarning
                  : AppColors.darkWarning)
              : AppColors.mutedForeground(brightness),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      BuildContext context, Brightness brightness) {
    final hasError = _errorText != null;
    final borderColor = hasError
        ? (brightness == Brightness.light
            ? AppColors.lightDestructive
            : AppColors.darkDestructive)
        : AppColors.border(brightness);
    final focusedBorderColor = hasError
        ? (brightness == Brightness.light
            ? AppColors.lightDestructive
            : AppColors.darkDestructive)
        : (brightness == Brightness.light
            ? AppColors.lightRing
            : AppColors.darkRing);

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.mutedForeground(brightness),
      ),
      errorText: _errorText,
      errorStyle: AppTextStyles.caption.copyWith(
        color: brightness == Brightness.light
            ? AppColors.lightDestructive
            : AppColors.darkDestructive,
      ),
      prefixIcon: _buildPrefixIcon(brightness),
      suffixIcon: _buildSuffixIcon(brightness),
      prefix: widget.prefix,
      suffix: widget.suffix,
      filled: widget.variant == TextFieldVariant.filled,
      fillColor: widget.variant == TextFieldVariant.filled
          ? AppColors.surface(brightness)
          : null,
      border: _buildBorder(widget.variant, borderColor),
      enabledBorder: _buildBorder(widget.variant, borderColor),
      focusedBorder: _buildBorder(widget.variant, focusedBorderColor),
      errorBorder: _buildBorder(
          widget.variant,
          brightness == Brightness.light
              ? AppColors.lightDestructive
              : AppColors.darkDestructive),
      focusedErrorBorder: _buildBorder(
          widget.variant,
          brightness == Brightness.light
              ? AppColors.lightDestructive
              : AppColors.darkDestructive),
      disabledBorder:
          _buildBorder(widget.variant, AppColors.mutedForeground(brightness)),
      contentPadding: _getContentPadding(),
      counterText: widget.showCounter ? null : '',
    );
  }

  Widget? _buildPrefixIcon(Brightness brightness) {
    if (widget.prefixIcon == null) return null;

    return Icon(
      widget.prefixIcon,
      color: AppColors.mutedForeground(brightness),
      size: AppConstants.iconSizeRegular,
    );
  }

  Widget? _buildSuffixIcon(Brightness brightness) {
    final icons = <Widget>[];

    // Password visibility toggle
    if (widget.obscureText) {
      icons.add(
        IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText ? Iconsax.eye_slash : Iconsax.eye,
            color: AppColors.mutedForeground(brightness),
            size: AppConstants.iconSizeRegular,
          ),
          splashRadius: AppConstants.iconSizeRegular,
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(
        IconButton(
          onPressed: widget.onSuffixPressed,
          icon: Icon(
            widget.suffixIcon,
            color: AppColors.mutedForeground(brightness),
            size: AppConstants.iconSizeRegular,
          ),
          splashRadius: AppConstants.iconSizeRegular,
        ),
      );
    }

    if (icons.isEmpty) return null;
    if (icons.length == 1) return icons.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  InputBorder _buildBorder(TextFieldVariant variant, Color color) {
    final radius = widget.borderRadius ?? AppConstants.defaultBorderRadius;

    switch (variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: 1),
        );

      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        );

      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: 1),
        );
    }
  }

  EdgeInsets _getContentPadding() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
      case TextFieldVariant.filled:
        return const EdgeInsets.all(AppConstants.defaultPadding);

      case TextFieldVariant.underlined:
        return const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: AppConstants.defaultPadding,
        );
    }
  }

  void _onTextChanged() {
    if (widget.validator != null && widget.autovalidateMode != null) {
      final result = widget.validator!(_controller.text);
      if (result.errorMessage != _errorText) {
        setState(() {
          _errorText = result.isValid ? null : result.errorMessage;
        });
      }
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && widget.validator != null) {
      final result = widget.validator!(_controller.text);
      if (result.errorMessage != _errorText) {
        setState(() {
          _errorText = result.isValid ? null : result.errorMessage;
        });
      }
    }
  }
}
