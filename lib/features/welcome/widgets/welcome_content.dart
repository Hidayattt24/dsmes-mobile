import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Branding
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.health_and_safety,
                color: AppColors.primaryContainer,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.appName,
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Title
          Text.rich(
            TextSpan(
              text: 'Selamat Datang di\n',
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 24,
                height: 1.3,
                color: AppColors.onSurface,
              ),
              children: [
                TextSpan(
                  text: 'DSMES Aceh',
                  style: AppTextStyles.poppinsHeadline.copyWith(
                    fontSize: 24,
                    height: 1.3,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Dukungan manajemen mandiri diabetes yang dipersonalisasi untuk kesehatan Anda yang lebih baik.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Primary button - Mulai
          AppButton(
            label: 'Mulai',
            trailingIcon: Icons.arrow_forward,
            height: 56,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onPressed: () => context.go(RouteNames.signup),
          ),
          const SizedBox(height: AppSpacing.md),
          // Login link
          InkWell(
            onTap: () => context.go(RouteNames.login),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sudah memiliki akun? ',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Masuk',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Footer indicator
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
