import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class TimeSelector extends StatelessWidget {
  const TimeSelector({
    super.key,
    required this.time,
    required this.onTap,
  });

  final TimeOfDay time;
  final VoidCallback onTap;

  String get _timeText {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surfaceContainerLow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _timeText,
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            const Icon(Icons.schedule, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
