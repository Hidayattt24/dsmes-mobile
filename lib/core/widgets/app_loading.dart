import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Centered loading indicator for async states.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 48.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
