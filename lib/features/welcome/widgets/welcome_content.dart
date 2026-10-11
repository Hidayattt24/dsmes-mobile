import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Page indicator + primary "Mulai" and secondary "Masuk" actions.
class WelcomeContent extends StatelessWidget {
  const WelcomeContent({
    super.key,
    required this.count,
    required this.current,
    required this.isLast,
    required this.onNext,
  });

  final int count;
  final int current;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == current ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == current
                      ? AppColors.primaryContainer
                      : AppColors.primaryContainer.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            onPressed: isLast ? () => context.go(RouteNames.signup) : onNext,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Row(
                key: ValueKey(isLast),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? 'Mulai Sekarang' : 'Lanjut',
                    style: AppTextStyles.poppinsButton.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
              side: BorderSide(
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => context.go(RouteNames.login),
            child: Text(
              'Saya sudah punya akun',
              style: AppTextStyles.poppinsButton.copyWith(
                color: AppColors.primaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
