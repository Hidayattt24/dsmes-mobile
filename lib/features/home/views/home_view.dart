import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../blood_sugar/widgets/blood_sugar_card.dart';
import '../dashboard/widgets/daily_calories_card.dart';
import '../dashboard/widgets/weekly_calendar_card.dart';
import '../dashboard/widgets/weekly_summary_section.dart';
import '../history/widgets/calendar_history_bottom_sheet.dart';
import '../reminders/widgets/reminder_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.nowOverride});

  final DateTime? nowOverride;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Default to July 23, 2026 (Thursday) as our mock "Today" timeline base
    _selectedDate = widget.nowOverride ?? DateTime(2026, 7, 23);
  }

  WeeklyDayState _resolveDayState(DateTime date, DateTime now) {
    final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
    if (isToday) {
      return WeeklyDayState.today;
    }
    // Return mock timeline states matching the developer requirement
    return switch (date.weekday) {
      1 => WeeklyDayState.completed,  // Monday
      2 => WeeklyDayState.completed,  // Tuesday
      3 => WeeklyDayState.inProgress, // Wednesday
      4 => WeeklyDayState.today,      // Thursday (Today fallback)
      5 => WeeklyDayState.noRecord,   // Friday
      6 => WeeklyDayState.noRecord,   // Saturday
      7 => WeeklyDayState.completed,  // Sunday
      _ => WeeklyDayState.noRecord,
    };
  }

  void _openHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarHistoryBottomSheet(
        initialDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.nowOverride ?? DateTime(2026, 7, 23);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Calendar Timeline Selector
          // Weekly Calendar Timeline Selector
          WeeklyCalendarCard(
            selectedDate: _selectedDate,
            getDayState: (date) => _resolveDayState(date, now),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onHistoryPressed: _openHistoryBottomSheet,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Dynamic cross-fade content switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _buildDayContent(context, now),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildDayContent(BuildContext context, DateTime now) {
    final isSelectedToday = _selectedDate.day == now.day && 
                            _selectedDate.month == now.month && 
                            _selectedDate.year == now.year;
                            
    final state = _resolveDayState(_selectedDate, now);
    final bool hasRecord = state == WeeklyDayState.completed || 
                           state == WeeklyDayState.inProgress || 
                           state == WeeklyDayState.today;

    // Resolve day-specific mock metrics
    final String bloodSugarValue = switch (_selectedDate.weekday) {
      1 => '112',
      2 => '128',
      3 => '118',
      4 => '120',
      7 => '105',
      _ => '',
    };

    final String bloodSugarTime = switch (_selectedDate.weekday) {
      1 => '08:00 pagi · Sebelum Sarapan',
      2 => '08:15 pagi · Sebelum Sarapan',
      3 => '07:45 pagi · Sebelum Makan',
      4 => '08:30 pagi · Sebelum Makan',
      7 => '07:00 pagi · Sebelum Sarapan',
      _ => '',
    };

    final double bloodSugarPercent = switch (_selectedDate.weekday) {
      1 => 0.5,
      2 => 0.65,
      3 => 0.58,
      4 => 0.6,
      7 => 0.45,
      _ => 0.0,
    };

    final int consumed = switch (_selectedDate.weekday) {
      1 => 1850,
      2 => 1700,
      3 => 950,
      4 => 1200,
      7 => 2000,
      _ => 0,
    };

    const int target = 2100;
    final int remaining = target - consumed;

    // Resolve Helper Text/Banner Message
    final String? historyMessage = switch (_selectedDate.weekday) {
      1 || 2 || 7 => 'Viewing completed history.',
      3 => 'Viewing historical progress.',
      5 || 6 => 'No health records were created on this day.',
      _ => null,
    };

    // Resolve Reminders Lists based on states
    List<ReminderItemData> reminders = [];
    if (state == WeeklyDayState.completed) {
      reminders = [
        const ReminderItemData(
          id: 'med_1',
          title: 'Minum Metformin',
          subtitle: 'Selesai',
          time: '08:00',
          icon: Icons.medication_outlined,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'sugar_1',
          title: 'Gula Darah Puasa',
          subtitle: 'Selesai',
          time: '07:00',
          icon: Icons.bloodtype_outlined,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'meal_b',
          title: 'Sarapan Pagi',
          subtitle: 'Selesai',
          time: '07:30',
          icon: Icons.restaurant_rounded,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'meal_l',
          title: 'Makan Siang',
          subtitle: 'Selesai',
          time: '12:30',
          icon: Icons.restaurant_rounded,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'meal_d',
          title: 'Makan Malam',
          subtitle: 'Selesai',
          time: '19:00',
          icon: Icons.restaurant_rounded,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
      ];
    } else if (state == WeeklyDayState.inProgress) {
      reminders = [
        const ReminderItemData(
          id: 'med_1',
          title: 'Minum Metformin',
          subtitle: '1 Tablet - Setelah Makan',
          time: '08:00',
          icon: Icons.medication_outlined,
          isCompleted: false,
          iconBgColor: Color(0x1F00695c),
          iconColor: Color(0xFF00695c),
        ),
        const ReminderItemData(
          id: 'sugar_1',
          title: 'Gula Darah Puasa',
          subtitle: 'Selesai',
          time: '07:00',
          icon: Icons.bloodtype_outlined,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'meal_b',
          title: 'Sarapan Pagi',
          subtitle: 'Selesai',
          time: '07:30',
          icon: Icons.restaurant_rounded,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'meal_l',
          title: 'Makan Siang',
          subtitle: 'Selesai',
          time: '12:30',
          icon: Icons.restaurant_rounded,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
        const ReminderItemData(
          id: 'meal_d',
          title: 'Makan Malam',
          subtitle: 'Belum Selesai',
          time: '19:00',
          icon: Icons.restaurant_rounded,
          isCompleted: false,
          iconBgColor: Color(0x1F00695c),
          iconColor: Color(0xFF00695c),
        ),
      ];
    } else if (state == WeeklyDayState.today) {
      reminders = [
        const ReminderItemData(
          id: 'med_1',
          title: 'Minum Metformin',
          subtitle: '1 Tablet - Setelah Makan',
          time: '08:00',
          icon: Icons.medication_outlined,
          isCompleted: false,
          iconBgColor: Color(0x1F00695c),
          iconColor: Color(0xFF00695c),
        ),
        const ReminderItemData(
          id: 'sugar_1',
          title: 'Gula Darah Puasa',
          subtitle: 'Selesai',
          time: '07:00',
          icon: Icons.bloodtype_outlined,
          isCompleted: true,
          iconBgColor: Color(0x1F286b33),
          iconColor: Color(0xFF286b33),
        ),
      ];
    }

    // Weekly summary counters
    final summaries = [
      SummaryItemData(
        title: 'Gula Darah',
        value: state == WeeklyDayState.noRecord ? '-' : 'Stabil',
        icon: Icons.bloodtype_outlined,
      ),
      SummaryItemData(
        title: 'Edukasi Dibaca',
        value: switch (_selectedDate.weekday) {
          1 || 7 => '7/7',
          2 => '6/7',
          3 || 4 => '5/7',
          _ => '0/7',
        },
        icon: Icons.menu_book_outlined,
      ),
    ];

    return Column(
      key: ValueKey<int>(_selectedDate.millisecondsSinceEpoch),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blood Sugar Card
        hasRecord
            ? BloodSugarCard(
                value: bloodSugarValue,
                unit: 'mg/dL',
                statusLabel: 'Normal',
                timeAndMealText: bloodSugarTime,
                percentagePosition: bloodSugarPercent,
                isToday: isSelectedToday,
                historyMessage: historyMessage,
                onRecordPressed: () => context.push(RouteNames.bloodSugarEntry),
              )
            : BloodSugarCard.empty(
                isToday: isSelectedToday,
                historyMessage: historyMessage,
                onRecordPressed: () => context.push(RouteNames.bloodSugarEntry),
              ),
        const SizedBox(height: AppSpacing.lg),
        // Daily Calories Card
        hasRecord
            ? DailyCaloriesCard(
                consumed: consumed,
                remaining: remaining,
                target: target,
                isToday: isSelectedToday,
                historyMessage: historyMessage,
                onRecordFoodPressed: () {},
              )
            : DailyCaloriesCard.empty(
                isToday: isSelectedToday,
                historyMessage: historyMessage,
                onRecordFoodPressed: () {},
              ),
        const SizedBox(height: AppSpacing.lg),
        // Reminder List
        ReminderSection(
          reminders: reminders,
          emptyMessage: state == WeeklyDayState.noRecord ? 'No medication record.' : null,
          onViewAllPressed: () => context.push(RouteNames.reminders),
          onReminderTapped: (id) {},
        ),
        const SizedBox(height: AppSpacing.lg),
        // Weekly Summary Section
        WeeklySummarySection(
          summaries: summaries,
        ),
      ],
    );
  }
}
