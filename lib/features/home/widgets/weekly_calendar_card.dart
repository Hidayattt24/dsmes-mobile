import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum WeeklyDayState {
  today,
  completed,
  inProgress,
  noRecord,
}

class WeeklyCalendarCard extends StatelessWidget {
  const WeeklyCalendarCard({
    super.key,
    required this.selectedDate,
    required this.getDayState,
    this.onDateSelected,
  });

  final DateTime selectedDate;
  final WeeklyDayState Function(DateTime date) getDayState;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    // Generate dates for the current week (Monday to Sunday)
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));

    final dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Text(
            'Hari ini',
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = weekDates[index];
            final label = dayLabels[index];
            
            final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
            final isSelected = date.day == selectedDate.day && date.month == selectedDate.month && date.year == selectedDate.year;
            final state = getDayState(date);

            return WeeklyCalendarDay(
              label: label,
              date: date,
              isToday: isToday,
              isSelected: isSelected,
              state: state,
              onTap: () => onDateSelected?.call(date),
            );
          }),
        ),
      ],
    );
  }
}

class WeeklyCalendarDay extends StatelessWidget {
  const WeeklyCalendarDay({
    super.key,
    required this.label,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.state,
    this.onTap,
  });

  final String label;
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final WeeklyDayState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Select the correct indicator widget based on the day state
    final Widget indicator = switch (state) {
      WeeklyDayState.completed => const CompletedDayIndicator(),
      WeeklyDayState.inProgress => const InProgressDayIndicator(value: 0.5),
      WeeklyDayState.noRecord || WeeklyDayState.today => const EmptyDayIndicator(),
    };

    // If it is today, wrap it in a distinct highlight ring (M3 Today Highlight)
    Widget dayCell = indicator;
    if (isToday) {
      dayCell = Container(
        padding: const EdgeInsets.all(2),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                )
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            dayCell,
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isToday
                    ? AppColors.primary
                    : isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedDayIndicator extends StatelessWidget {
  const CompletedDayIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.secondary, // Green
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: AppColors.onSecondary,
        size: 16,
      ),
    );
  }
}

class InProgressDayIndicator extends StatelessWidget {
  const InProgressDayIndicator({
    super.key,
    this.value = 0.5,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 3,
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          // Active progress
          CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            color: AppColors.tertiary, // Orange / Amber
            strokeCap: StrokeCap.round,
          ),
          // Inner dot indicating partially completed state
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyDayIndicator extends StatelessWidget {
  const EmptyDayIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: AppColors.outlineVariant.withValues(alpha: 0.8),
        ),
        child: Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // Draw dashed circle
    const int dashCount = 10;
    final path = Path();
    const double sweepAngle = 3.14159 / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (i * 2 * 3.14159) / dashCount;
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
