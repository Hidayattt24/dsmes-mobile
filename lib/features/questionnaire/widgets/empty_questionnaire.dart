import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class EmptyQuestionnaireWidget extends StatelessWidget {
  const EmptyQuestionnaireWidget({
    super.key,
    required this.onResetTap,
  });

  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.quiz_outlined,
            size: 48,
            color: AppColors.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Kuesioner Tidak Ditemukan',
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba cari dengan kata kunci lain atau pilih kategori yang berbeda.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onResetTap,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Tampilkan Semua Kuesioner'),
          ),
        ],
      ),
    );
  }
}
