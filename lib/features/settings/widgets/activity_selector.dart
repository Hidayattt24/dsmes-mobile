import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/settings_mock_data.dart';

/// Reusable Activity Selector matching the onboarding activity card design.
class ActivitySelector extends StatelessWidget {
  const ActivitySelector({
    super.key,
    required this.selectedActivity,
    required this.onActivitySelected,
  });

  final String selectedActivity;
  final ValueChanged<String> onActivitySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tingkat Aktivitas Fisik',
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih tingkat aktivitas harian Anda yang paling sesuai saat ini',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...SettingsMockData.activityOptions.map((opt) {
          final title = opt.$1;
          final desc = opt.$2;
          final isSelected = selectedActivity.trim().toLowerCase() ==
                  title.trim().toLowerCase() ||
              selectedActivity.toLowerCase().contains(title.toLowerCase());

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ActivityOptionTile(
              title: title,
              description: desc,
              isSelected: isSelected,
              onTap: () => onActivitySelected(title),
            ),
          );
        }),
      ],
    );
  }
}

class _ActivityOptionTile extends StatelessWidget {
  const _ActivityOptionTile({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary.withValues(alpha: 0.85)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppColors.onPrimary : AppColors.outlineVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
