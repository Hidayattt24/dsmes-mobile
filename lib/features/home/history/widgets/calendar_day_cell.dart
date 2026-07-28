import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/history_item_model.dart';

enum HealthActivityStatus { completed, inProgress, noActivity }

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    this.aggregate,
    this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final DailyHistoryAggregate? aggregate;
  final VoidCallback? onTap;

  HealthActivityStatus get _status {
    if (aggregate == null || !aggregate!.hasAnyActivity) {
      return HealthActivityStatus.noActivity;
    }
    if (aggregate!.isFullyCompleted) {
      return HealthActivityStatus.completed;
    }
    return HealthActivityStatus.inProgress;
  }

  double get _progressRatio => aggregate?.progressRatio ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final progressRatio = _progressRatio;

    Widget indicator = switch (status) {
      HealthActivityStatus.completed => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
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
              CircularProgressIndicator(
                value: progressRatio,
                strokeWidth: 2.2,
                color: AppColors.tertiary,
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
