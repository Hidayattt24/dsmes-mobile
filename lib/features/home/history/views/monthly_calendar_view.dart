import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../models/history_mock_data.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/calendar_month_header.dart';
import '../widgets/calendar_weekday_header.dart';

class MonthlyCalendarView extends StatelessWidget {
  const MonthlyCalendarView({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final int year;
  final int month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  int get _daysInMonth {
    final firstDayThisMonth = DateTime(year, month, 1);
    final firstDayNextMonth = DateTime(year, month + 1, 1);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  int get _startWeekdayOffset {
    // DateTime.weekday returns: 1 = Monday, 7 = Sunday
    // In Sunday-start: Sunday is 0, Monday is 1, Saturday is 6
    return DateTime(year, month, 1).weekday % 7;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = _daysInMonth;
    final offset = _startWeekdayOffset;
    final totalSlots = totalDays + offset;

    return Column(
      children: [
        // Month Navigation Header (← Month Year →)
        CalendarMonthHeader(
          year: year,
          month: month,
          onPreviousMonth: onPreviousMonth,
          onNextMonth: onNextMonth,
        ),
        const SizedBox(height: AppSpacing.md),

        // Sunday-Start Weekday Labels Row
        const CalendarWeekdayHeader(),
        const SizedBox(height: AppSpacing.sm),

        // Grid of Date Cells
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 7;
            const cellHeight = 58.0;
            final childAspectRatio = cellWidth / cellHeight;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: AppSpacing.xs,
                mainAxisSpacing: AppSpacing.xs,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: totalSlots,
              itemBuilder: (context, index) {
                if (index < offset) {
                  return const SizedBox.shrink(); // Empty slot for Sunday-start padding
                }

                final dayNumber = index - offset + 1;
                final date = DateTime(year, month, dayNumber);

                final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

                final isSelected = date.day == selectedDate.day &&
                    date.month == selectedDate.month &&
                    date.year == selectedDate.year;

                // Retrieve activity state from mock records database
                final record = MockHistoryData.getRecord(date);
                final status = record?.status ?? HealthActivityStatus.noActivity;

                return CalendarDayCell(
                  date: date,
                  isToday: isToday,
                  isSelected: isSelected,
                  status: status,
                  progressRatio: record?.progressRatio,
                  onTap: () => onDateSelected(date),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
