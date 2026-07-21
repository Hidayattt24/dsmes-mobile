import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/history_mock_data.dart';
import '../views/monthly_calendar_view.dart';
import 'daily_history_summary.dart';
import 'history_empty_state.dart';

class CalendarHistoryBottomSheet extends StatefulWidget {
  const CalendarHistoryBottomSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<CalendarHistoryBottomSheet> createState() => _CalendarHistoryBottomSheetState();
}

class _CalendarHistoryBottomSheetState extends State<CalendarHistoryBottomSheet> {
  late int _currentYear;
  late int _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentYear = widget.initialDate.year;
    _currentMonth = widget.initialDate.month;
  }

  void _handlePreviousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _handleNextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // Synchronize to main home screen selected date
    widget.onDateSelected(date);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    final record = MockHistoryData.getRecord(_selectedDate);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),

            // Modal Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Spacer to balance close button
                  Expanded(
                    child: Center(
                      child: Text(
                        'Riwayat Kesehatan',
                        style: AppTextStyles.labelLg.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.onSurface,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Smooth monthly transition view
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: MonthlyCalendarView(
                        key: ValueKey('month_${_currentYear}_$_currentMonth'),
                        year: _currentYear,
                        month: _currentMonth,
                        selectedDate: _selectedDate,
                        onDateSelected: _handleDateSelected,
                        onPreviousMonth: _handlePreviousMonth,
                        onNextMonth: _handleNextMonth,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1, color: AppColors.outlineVariant),
                    ),

                    // Selected Date Detail Section
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: record != null && record.status != HealthActivityStatus.noActivity
                          ? DailyHistorySummary(
                              key: ValueKey('summary_${record.date.millisecondsSinceEpoch}'),
                              record: record,
                            )
                          : HistoryEmptyState(
                              key: ValueKey('empty_${_selectedDate.millisecondsSinceEpoch}'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
