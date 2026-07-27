import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Global Floating AI Chat Assistant Widget
/// Placed on main screens with a calm breathing animation, glassmorphic soft shadow,
/// healthcare AI sparkle icon, and Hero animation to [AiChatbotScreen].
class FloatingAiChatButton extends StatefulWidget {
  const FloatingAiChatButton({super.key});

  @override
  State<FloatingAiChatButton> createState() => _FloatingAiChatButtonState();
}

class _FloatingAiChatButtonState extends State<FloatingAiChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  static const String _fullText = 'Hai, ingin konsultasi dengan AI?';
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    _typingTimer?.cancel();
    _displayedText = '';
    _currentIndex = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentIndex < _fullText.length) {
        _currentIndex++;
        setState(() {
          _displayedText = _fullText.substring(0, _currentIndex);
        });
      } else {
        timer.cancel();
        _typingTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            _startTypingAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    context.push(RouteNames.aiChat);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speech Bubble Tooltip Above Button
        GestureDetector(
          onTap: _onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _displayedText,
                      style: AppTextStyles.labelMd.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Pointer Triangle pointing down
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: CustomPaint(
                  size: const Size(12, 6),
                  painter: _BubbleTrianglePainter(
                    color: AppColors.surfaceContainerLowest,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Floating Doctor AI Button
        ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: InkWell(
              onTap: _onTap,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      Color(0xFF0D9488), // Teal healthcare accent
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: 'ai-assistant-avatar',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    // Small online badge indicator
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E), // Emerald green online
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTrianglePainter extends CustomPainter {
  final Color color;
  _BubbleTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
