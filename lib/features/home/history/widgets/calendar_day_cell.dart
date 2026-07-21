import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/history_mock_data.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.status,
    this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final HealthActivityStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Determine the indicator inside (compact 24x24 px base)
    Widget indicator = switch (status) {
      HealthActivityStatus.completed => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.secondary, // Green
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.onSecondary,
            size: 13,
          ),
        ),
      HealthActivityStatus.inProgress => SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 2.2,
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
              const CircularProgressIndicator(
                value: 0.5,
                strokeWidth: 2.2,
                color: AppColors.tertiary, // Orange / Amber
                strokeCap: StrokeCap.round,
              ),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      HealthActivityStatus.noActivity => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
    };

    // If today, wrap it in a primary teal highlight border (outer size becomes 30x30)
    if (isToday) {
      indicator = Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: indicator,
      );
    }

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Constrain indicator height to prevent layout shifts
              SizedBox(
                height: 30,
                child: Center(child: indicator),
              ),
              const SizedBox(height: 3),
              Text(
                date.day.toString(),
                style: AppTextStyles.labelMd.copyWith(
                  color: isToday
                      ? AppColors.primary
                      : isSelected
                          ? AppColors.primary
                          : (status == HealthActivityStatus.noActivity
                              ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                              : AppColors.onSurface),
                  fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
