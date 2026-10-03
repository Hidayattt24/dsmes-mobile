import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SummaryItemData {
  const SummaryItemData({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class WeeklySummarySection extends StatelessWidget {
  const WeeklySummarySection({
    super.key,
    required this.summaries,
  });

  final List<SummaryItemData> summaries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Text(
            'Ringkasan Mingguan',
            style: AppTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0500695c),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < summaries.length; i++) ...[
                  if (i > 0)
                    VerticalDivider(
                      width: AppSpacing.lg,
                      thickness: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  Expanded(child: _SummaryTile(data: summaries[i])),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.data});

  final SummaryItemData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(data.icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.poppinsHeadline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
