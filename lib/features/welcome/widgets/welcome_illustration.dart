import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.85;
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Positioned(
                  width: size * 1.2,
                  height: size * 1.2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withValues(alpha: 0.05),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                // Image container
                Container(
                  width: size * 0.9,
                  height: size * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A00695c),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(44),
                    child: Stack(
                      children: [
                        // Placeholder gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryFixed.withValues(alpha: 0.3),
                                AppColors.secondaryContainer.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.health_and_safety,
                                  size: size * 0.2,
                                  color: AppColors.primaryContainer
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 8),
                                Icon(
                                  Icons.timeline_outlined,
                                  size: size * 0.15,
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
