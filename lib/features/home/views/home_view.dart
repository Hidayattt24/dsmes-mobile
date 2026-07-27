import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../blood_sugar/widgets/blood_sugar_card.dart';
import '../dashboard/widgets/daily_calories_card.dart';
import '../dashboard/widgets/weekly_calendar_card.dart';
import '../dashboard/widgets/weekly_summary_section.dart';
import '../history/widgets/calendar_history_bottom_sheet.dart';
import '../history/widgets/history_empty_state.dart';
import '../reminders/widgets/reminder_section.dart';

import '../viewmodels/home_dashboard_notifier.dart';
import '../widgets/home_skeleton.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key, this.nowOverride});

  final DateTime? nowOverride;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.nowOverride ?? DateTime.now();
  }

  WeeklyDayState _resolveDayState(DateTime date, DateTime now, HomeDashboardState state) {
    final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
    final todayStart = DateTime(now.year, now.month, now.day);
    final dateStart = DateTime(date.year, date.month, date.day);

    // Future days must have NO RECORD
    if (dateStart.isAfter(todayStart)) {
      return WeeklyDayState.noRecord;
    }

    // Check if real records exist in database
    final hasRecordOnDate = state.bloodSugarLogs.any((log) {
      final dt = DateTime.tryParse(log.measuredAt);
      return dt != null && dt.year == date.year && dt.month == date.month && dt.day == date.day;
    });

    if (hasRecordOnDate) {
      return WeeklyDayState.completed;
    }

    if (isToday) {
      return WeeklyDayState.today;
    }

    return WeeklyDayState.noRecord;
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
    final now = widget.nowOverride ?? DateTime.now();
    final dashboardAsync = ref.watch(homeDashboardProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(homeDashboardProvider.notifier).refresh();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: dashboardAsync.when(
          loading: () => const HomeSkeleton(),
          error: (err, stack) => _buildErrorState(err.toString()),
          data: (state) => _buildHomeContent(context, now, state),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data dashboard',
              style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              errorMsg,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(homeDashboardProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, DateTime now, HomeDashboardState state) {
    final dash = state.dashboardData;
    final latestBs = state.latestBloodSugar;
    final isSelectedToday = _selectedDate.day == now.day &&
        _selectedDate.month == now.month &&
        _selectedDate.year == now.year;

    final targetCalorie = dash?.dailyCalorieTarget ?? 2000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Greeting Header Section ─────────────────────────────────────────────
        if (dash != null) ...[
          Text(
            '${dash.greetingText} ${dash.displayName}!',
            style: AppTextStyles.poppinsHeadline.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dash.motivationalMessage,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Weekly Calendar Timeline Selector ─────────────────────────────────
        WeeklyCalendarCard(
          selectedDate: _selectedDate,
          getDayState: (date) => _resolveDayState(date, now, state),
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          onHistoryPressed: _openHistoryBottomSheet,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Blood Sugar Card ──────────────────────────────────────────────────
        if (latestBs != null)
          BloodSugarCard(
            value: latestBs.glucoseValue.toString(),
            unit: 'mg/dL',
            statusLabel: latestBs.classificationLabel,
            timeAndMealText: latestBs.formattedTimeAndType,
            percentagePosition: (latestBs.glucoseValue / 200.0).clamp(0.1, 0.9),
            isToday: isSelectedToday,
            onRecordPressed: () => context.push(RouteNames.bloodSugarEntry),
          )
        else
          BloodSugarCard.empty(
            isToday: isSelectedToday,
            onRecordPressed: () => context.push(RouteNames.bloodSugarEntry),
          ),
        const SizedBox(height: AppSpacing.lg),

        // ── Daily Calories Card (Preserved) ───────────────────────────────────
        DailyCaloriesCard(
          consumed: 0,
          remaining: targetCalorie,
          target: targetCalorie,
          isToday: isSelectedToday,
          onRecordFoodPressed: () => context.push(RouteNames.mealEntry),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Reminder Section (Preserved) ──────────────────────────────────────
        ReminderSection(
          reminders: const [],
          emptyMessage: 'Belum ada pengingat hari ini.',
          onViewAllPressed: () => context.push(RouteNames.reminders),
          onReminderTapped: (id) {},
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Recent Activity / History Timeline ───────────────────────────────
        Text(
          'Aktivitas Terakhir',
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (state.recentActivities.isEmpty)
          const HistoryEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recentActivities.length > 5 ? 5 : state.recentActivities.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final act = state.recentActivities[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: act.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(act.icon, color: act.iconColor, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.title,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            act.description,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (act.statusLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (act.statusColor ?? AppColors.primary).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          act.statusLabel!,
                          style: AppTextStyles.labelMd.copyWith(
                            color: act.statusColor ?? AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: AppSpacing.lg),

        // ── Summary Counters Section ──────────────────────────────────────────
        WeeklySummarySection(
          summaries: [
            SummaryItemData(
              title: 'Gula Darah',
              value: latestBs != null ? latestBs.classificationLabel : '-',
              icon: Icons.water_drop_outlined,
            ),
            SummaryItemData(
              title: 'Berat Badan',
              value: dash != null ? '${dash.weightKg} kg' : '-',
              icon: Icons.scale_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
