import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';

/// Speech animation types
enum SpeechAnimationType {
  listening,
  processing,
  speaking,
  pulse,
  wave,
  ripple,
}

/// Speech animation widget with various visual effects
class SpeechAnimation extends StatefulWidget {
  /// Type of animation to display
  final SpeechAnimationType type;

  /// Size of the animation
  final double size;

  /// Primary color for the animation
  final Color? color;

  /// Whether the animation is active
  final bool isActive;

  /// Animation speed multiplier
  final double speed;

  /// Number of elements in the animation (for wave/ripple effects)
  final int elementCount;

  /// Whether to show confidence indicator
  final bool showConfidence;

  /// Confidence value (0.0 to 1.0)
  final double confidence;

  const SpeechAnimation({
    super.key,
    required this.type,
    this.size = 64.0,
    this.color,
    this.isActive = true,
    this.speed = 1.0,
    this.elementCount = 5,
    this.showConfidence = false,
    this.confidence = 0.0,
  });

  @override
  State<SpeechAnimation> createState() => _SpeechAnimationState();
}

class _SpeechAnimationState extends State<SpeechAnimation>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;

  @override
  void initState() {
    super.initState();

    _primaryController = AnimationController(
      duration: Duration(milliseconds: (1000 / widget.speed).round()),
      vsync: this,
    );

    _secondaryController = AnimationController(
      duration: Duration(milliseconds: (2000 / widget.speed).round()),
      vsync: this,
    );

    _primaryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: Curves.easeInOut,
    ));

    _secondaryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secondaryController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  @override
  void didUpdateWidget(SpeechAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }

    if (widget.speed != oldWidget.speed) {
      _primaryController.duration = Duration(milliseconds: (1000 / widget.speed).round());
      _secondaryController.duration = Duration(milliseconds: (2000 / widget.speed).round());
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!widget.isActive) return;

    switch (widget.type) {
      case SpeechAnimationType.listening:
      case SpeechAnimationType.processing:
      case SpeechAnimationType.pulse:
        _primaryController.repeat(reverse: true);
        break;
      case SpeechAnimationType.speaking:
      case SpeechAnimationType.wave:
        _primaryController.repeat();
        _secondaryController.repeat();
        break;
      case SpeechAnimationType.ripple:
        _primaryController.repeat();
        _secondaryController.repeat(reverse: true);
        break;
    }
  }

  void _stopAnimation() {
    _primaryController.stop();
    _secondaryController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final effectiveColor = widget.color ?? _getDefaultColor(brightness);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main animation
          _buildAnimation(effectiveColor),
          
          // Confidence indicator
          if (widget.showConfidence) ...[
            _buildConfidenceIndicator(effectiveColor, brightness),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimation(Color color) {
    switch (widget.type) {
      case SpeechAnimationType.listening:
        return _buildListeningAnimation(color);
      case SpeechAnimationType.processing:
        return _buildProcessingAnimation(color);
      case SpeechAnimationType.speaking:
        return _buildSpeakingAnimation(color);
      case SpeechAnimationType.pulse:
        return _buildPulseAnimation(color);
      case SpeechAnimationType.wave:
        return _buildWaveAnimation(color);
      case SpeechAnimationType.ripple:
        return _buildRippleAnimation(color);
    }
  }

  Widget _buildListeningAnimation(Color color) {
    return AnimatedBuilder(
      animation: _primaryAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3 + _primaryAnimation.value * 0.4),
                  width: 2,
                ),
              ),
            ),
            
            // Inner circle
            Transform.scale(
              scale: 0.6 + _primaryAnimation.value * 0.4,
              child: Container(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: widget.size * 0.25,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProcessingAnimation(Color color) {
    return AnimatedBuilder(
      animation: _primaryAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _primaryAnimation.value * 2 * pi,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating dots
              for (int i = 0; i < 8; i++)
                Transform.rotate(
                  angle: (i * pi / 4),
                  child: Transform.translate(
                    offset: Offset(0, -widget.size * 0.3),
                    child: Container(
                      width: widget.size * 0.1,
                      height: widget.size * 0.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.3 + (i / 8) * 0.7),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeakingAnimation(Color color) {
    return AnimatedBuilder(
      animation: Listenable.merge([_primaryAnimation, _secondaryAnimation]),
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.elementCount, (index) {
            final delay = index * 0.1;
            final animationValue = (_primaryAnimation.value - delay) % 1.0;
            final height = (sin(animationValue * 2 * pi) * 0.5 + 0.5) * widget.size * 0.8;
            
            return Container(
              width: widget.size / (widget.elementCount * 1.5),
              height: height + widget.size * 0.2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(widget.size * 0.02),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseAnimation(Color color) {
    return AnimatedBuilder(
      animation: _primaryAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + _primaryAnimation.value * 0.4,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3 + _primaryAnimation.value * 0.4),
            ),
            child: Icon(
              Icons.graphic_eq,
              color: color,
              size: widget.size * 0.4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveAnimation(Color color) {
    return AnimatedBuilder(
      animation: _primaryAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _WavePainter(
            animation: _primaryAnimation.value,
            color: color,
            waveCount: 3,
          ),
        );
      },
    );
  }

  Widget _buildRippleAnimation(Color color) {
    return AnimatedBuilder(
      animation: Listenable.merge([_primaryAnimation, _secondaryAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Multiple ripple circles
            for (int i = 0; i < 3; i++)
              Transform.scale(
                scale: (_primaryAnimation.value + i * 0.3) % 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(
                        (1.0 - ((_primaryAnimation.value + i * 0.3) % 1.0)) * 0.7,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
            
            // Center dot
            Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfidenceIndicator(Color color, Brightness brightness) {
    return Positioned(
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          border: Border.all(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
        child: Text(
          '${(widget.confidence * 100).round()}%',
          style: TextStyle(
            color: color,
            fontSize: AppConstants.fontSizeSmall,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getDefaultColor(Brightness brightness) {
    switch (widget.type) {
      case SpeechAnimationType.listening:
        return AppColors.voiceActive;
      case SpeechAnimationType.processing:
        return AppColors.voiceListening;
      case SpeechAnimationType.speaking:
        return AppColors.voiceActive;
      case SpeechAnimationType.pulse:
      case SpeechAnimationType.wave:
      case SpeechAnimationType.ripple:
        return AppColors.primary(brightness);
    }
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  final int waveCount;

  _WavePainter({
    required this.animation,
    required this.color,
    this.waveCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < waveCount; i++) {
      final progress = (animation + i / waveCount) % 1.0;
      final radius = progress * maxRadius;
      final opacity = 1.0 - progress;

      paint.color = color.withOpacity(opacity * 0.7);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}