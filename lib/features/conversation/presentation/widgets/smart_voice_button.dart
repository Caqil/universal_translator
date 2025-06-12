// lib/features/conversation/presentation/widgets/smart_voice_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

class SmartVoiceButton extends StatefulWidget {
  final String language;
  final String languageName;
  final Color primaryColor;
  final bool isListening;
  final bool isActive;
  final bool isProcessing;
  final double? confidence;
  final VoidCallback onPressed;
  final bool enabled;

  const SmartVoiceButton({
    super.key,
    required this.language,
    required this.languageName,
    required this.primaryColor,
    required this.isListening,
    required this.isActive,
    required this.onPressed,
    this.isProcessing = false,
    this.confidence,
    this.enabled = true,
  });

  @override
  State<SmartVoiceButton> createState() => _SmartVoiceButtonState();
}

class _SmartVoiceButtonState extends State<SmartVoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(SmartVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rippleController.stop();
    _pulseController.reset();
    _rippleController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed();
            }
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageLabel(),
          const SizedBox(height: 16),
          _buildVoiceButton(),
          const SizedBox(height: 12),
          _buildStatusText(),
        ],
      ),
    );
  }

  Widget _buildLanguageLabel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isActive
            ? widget.primaryColor.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isActive
              ? widget.primaryColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Text(
        widget.languageName,
        style: TextStyle(
          color: widget.isActive ? widget.primaryColor : Colors.grey[600],
          fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rippleAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effects
            if (widget.isListening) ...[
              for (int i = 0; i < 2; i++)
                Transform.scale(
                  scale: 1.0 + (_rippleAnimation.value * (i + 1) * 0.5),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.primaryColor.withOpacity(
                          0.3 - (_rippleAnimation.value * 0.3),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],

            // Confidence ring
            if (widget.confidence != null && widget.confidence! > 0)
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: widget.confidence,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.primaryColor.withOpacity(0.7),
                  ),
                ),
              ),

            // Main button
            Transform.scale(
              scale: widget.isListening ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getButtonColors(),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(
                        widget.isListening ? 0.4 : 0.2,
                      ),
                      blurRadius: widget.isListening ? 20 : 10,
                      spreadRadius: widget.isListening ? 5 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getButtonIcon(),
                  color: Colors.white,
                  size: widget.isListening ? 28 : 24,
                ),
              ),
            ),

            // Processing overlay
            if (widget.isProcessing)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusText() {
    String text = '';
    Color color = Colors.grey[600]!;

    if (widget.isProcessing) {
      text = 'Processing...';
      color = widget.primaryColor;
    } else if (widget.isListening) {
      text = 'Listening...';
      color = widget.primaryColor;
    } else if (!widget.enabled) {
      text = 'Not Available';
      color = Colors.grey[400]!;
    }

    return AnimatedOpacity(
      opacity: text.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Color> _getButtonColors() {
    if (!widget.enabled) {
      return [Colors.grey[400]!, Colors.grey[500]!];
    }

    if (widget.isListening || widget.isProcessing) {
      return [
        widget.primaryColor,
        widget.primaryColor.withOpacity(0.8),
      ];
    }

    return [
      widget.primaryColor.withOpacity(0.8),
      widget.primaryColor.withOpacity(0.6),
    ];
  }

  IconData _getButtonIcon() {
    if (widget.isProcessing) return Iconsax.audio_square;
    if (widget.isListening) return Iconsax.microphone;
    return Iconsax.microphone_slash;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
}
