import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../constants/routine_icons.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    super.key,
    required this.name,
    required this.iconName,
    required this.scheduleText,
    required this.customTimes,
    required this.onRenameTap,
    required this.onIconTap,
    required this.onTimeTap,
    required this.onDeleteTime,
    required this.onAddTime,
    this.onDeleteRoutine,
    this.isPredefined = false,
  });

  final String name;
  final String iconName;
  final String scheduleText;
  final List<TimeOfDay> customTimes;
  final VoidCallback onRenameTap;
  final VoidCallback onIconTap;
  final ValueChanged<int> onTimeTap;
  final ValueChanged<int> onDeleteTime;
  final VoidCallback onAddTime;
  final VoidCallback? onDeleteRoutine;
  final bool isPredefined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context),
          const SizedBox(height: AppSpacing.sm),
          _buildScheduleRow(context),
          const SizedBox(height: AppSpacing.md),
          if (customTimes.isNotEmpty) ...[
            _buildTimeChips(context),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildAddButton(),
          if (!isPredefined && onDeleteRoutine != null) ...[
            const Divider(height: AppSpacing.lg),
            _buildDeleteButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: onRenameTap,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onIconTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: AppRadius.cardMd,
            ),
            child: Icon(
              resolveRoutineIcon(iconName),
              color: AppColors.secondary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          scheduleText,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChips(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(customTimes.length, (index) {
        final time = customTimes[index];
        final timeText =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        return GestureDetector(
          onTap: () => onTimeTap(index),
          child: Chip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            backgroundColor: AppColors.surfaceContainerLow,
            side: const BorderSide(color: AppColors.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            label: Text(
              timeText,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.outline),
            onDeleted: () => onDeleteTime(index),
          ),
        );
      }),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: onAddTime,
      borderRadius: AppRadius.cardMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppStrings.dailyRoutineAddCustomTime,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: onDeleteRoutine,
      borderRadius: AppRadius.cardMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppStrings.routineDeleteLabel,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
