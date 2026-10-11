import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Data for one onboarding slide.
class WelcomeSlide {
  const WelcomeSlide({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.chips,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  /// Floating chips shown around the illustration: (icon, label).
  final List<(IconData, String)> chips;
}

/// Animated, code-drawn illustration for a [WelcomeSlide].
class WelcomeIllustration extends StatefulWidget {
  const WelcomeIllustration({super.key, required this.slide});

  final WelcomeSlide slide;

  @override
  State<WelcomeIllustration> createState() => _WelcomeIllustrationState();
}

class _WelcomeIllustrationState extends State<WelcomeIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slide;
    return LayoutBuilder(
      builder: (context, box) {
        final size = math.min(box.maxWidth, box.maxHeight) * 0.9;
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                final t = _float.value * 2 * math.pi;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft outer ring
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color.withValues(alpha: 0.06),
                      ),
                    ),
                    Container(
                      width: size * 0.72,
                      height: size * 0.72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color.withValues(alpha: 0.10),
                      ),
                    ),
                    // Main orb
                    Transform.translate(
                      offset: Offset(0, math.sin(t) * 6),
                      child: Container(
                        width: size * 0.44,
                        height: size * 0.44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(s.color, Colors.white, 0.25)!,
                              s.color,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: s.color.withValues(alpha: 0.35),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Icon(s.icon,
                            color: Colors.white, size: size * 0.2),
                      ),
                    ),
                    // Floating chips
                    for (var i = 0; i < s.chips.length; i++)
                      _positionedChip(i, s, size, t),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _positionedChip(int i, WelcomeSlide s, double size, double t) {
    const anchors = [
      Alignment(-0.95, -0.62),
      Alignment(0.95, -0.2),
      Alignment(-0.75, 0.78),
    ];
    final a = anchors[i % anchors.length];
    final dy = math.sin(t + i * 2.1) * 5;
    final (icon, label) = s.chips[i];
    return Align(
      alignment: a,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: s.color),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
