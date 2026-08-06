import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/shell/app_shell.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../blood_sugar/widgets/blood_sugar_card.dart';
import '../dashboard/widgets/daily_calories_card.dart';
import '../dashboard/widgets/weekly_calendar_card.dart';
import '../dashboard/widgets/weekly_summary_section.dart';
import '../history/models/history_item_model.dart';
import '../history/viewmodels/history_provider.dart';
import '../history/widgets/calendar_history_bottom_sheet.dart';
import '../history/widgets/history_empty_state.dart';
import '../reminders/models/reminder_model.dart';
import '../reminders/viewmodels/reminder_provider.dart';
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

  WeeklyDayState _resolveDayState(DateTime date, DateTime now, HistoryState? historyState) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final dateStart = DateTime(date.year, date.month, date.day);

    if (dateStart.isAfter(todayStart)) {
      return WeeklyDayState.noRecord;
    }

    final aggregate = historyState?.getAggregateForDate(date);
    if (aggregate == null || !aggregate.hasAnyActivity) {
      return WeeklyDayState.noRecord;
    }

    if (aggregate.isFullyCompleted) {
      return WeeklyDayState.completed;
    }

    return WeeklyDayState.inProgress;
  }

  double _resolveDayProgress(DateTime date, HistoryState? historyState) {
    final aggregate = historyState?.getAggregateForDate(date);
    return aggregate?.progressRatio ?? 0.0;
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
    final historyAsync = ref.watch(historyProvider);
    final remindersAsync = ref.watch(reminderListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(homeDashboardProvider.notifier).refresh(),
          ref.read(historyProvider.notifier).refresh(),
          ref.read(reminderListProvider.notifier).refresh(),
        ]);
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: dashboardAsync.when(
          loading: () => const HomeSkeleton(),
          error: (err, stack) => _buildErrorState(err.toString()),
          data: (state) => _buildHomeContent(context, now, state, historyAsync, remindersAsync),
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

  Widget _buildHomeContent(BuildContext context, DateTime now, HomeDashboardState state,
      AsyncValue<HistoryState> historyAsync,
      AsyncValue<List<ReminderModel>> remindersAsync) {
    final dash = state.dashboardData;
    final latestBs = state.latestBloodSugar;
    final isSelectedToday = _selectedDate.day == now.day &&
        _selectedDate.month == now.month &&
        _selectedDate.year == now.year;

    final historyState = historyAsync.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        WeeklyCalendarCard(
          selectedDate: _selectedDate,
          getDayState: (date) => _resolveDayState(date, now, historyState),
          getDayProgress: (date) => _resolveDayProgress(date, historyState),
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          onHistoryPressed: _openHistoryBottomSheet,
        ),
        const SizedBox(height: AppSpacing.lg),

        if (latestBs != null)
          BloodSugarCard(
            value: latestBs.glucoseValue.toString(),
            unit: 'mg/dL',
            statusLabel: latestBs.classificationLabel,
            statusColor: _parseHexColor(latestBs.colorIndicator),
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

        DailyCaloriesCard(
          consumed: state.consumedCalories,
          remaining: state.remainingCalories,
          target: state.dailyCalorieTarget,
          isToday: isSelectedToday,
          onRecordFoodPressed: () => context.push(RouteNames.mealEntry),
          onViewHistoryPressed: () =>
              ref.read(appShellTabIndexProvider.notifier).state = 1,
        ),
        const SizedBox(height: AppSpacing.lg),

        remindersAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (reminders) {
            final todayReminders = reminders
                .where((r) =>
                    r.isActive && r.activeDays.contains(now.weekday))
                .map(ReminderItemData.fromReminderModel)
                .toList();
            return ReminderSection(
              reminders: todayReminders,
              emptyMessage: 'Belum ada pengingat hari ini.',
              onViewAllPressed: () => context.push(RouteNames.reminders),
              onReminderTapped: (id) {},
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(
          'Aktivitas Terakhir',
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        historyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Gagal memuat aktivitas',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          data: (historyState) {
            if (historyState.allItems.isEmpty) {
              return const HistoryEmptyState();
            }

            final activities = historyState.recentItemsLimited;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final act = activities[index];
                final iconColor = _parseColor(act.color);
                final iconBgColor = iconColor.withValues(alpha: 0.1);
                final statusColor = act.status == 'normal'
                    ? AppColors.secondary
                    : (act.status == 'hyperglycemia' || act.status == 'severe_hyperglycemia'
                        ? AppColors.error
                        : AppColors.tertiary);

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _mapIcon(act.icon),
                          color: iconColor,
                          size: 20,
                        ),
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
                              '${act.activityTypeLabel} • ${act.value} ${act.unit}',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatActivityDate(act.parsedMeasuredAt),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(act),
                          style: AppTextStyles.labelMd.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

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

  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop_outlined;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'medication':
        return Icons.medication_outlined;
      case 'monitor_heart':
        return Icons.monitor_heart_outlined;
      default:
        return Icons.history_rounded;
    }
  }

  String _statusLabel(HistoryItemModel item) {
    switch (item.activityType) {
      case 'blood_sugar':
        return '${item.value} mg/dL';
      case 'meal':
        return '${item.value} kcal';
      case 'activity':
        return item.status == 'Completed' ? 'Selesai' : 'Pending';
      case 'medication':
        return item.status == 'selesai' ? 'Minum' : 'Pending';
      default:
        return item.status;
    }
  }

  String _formatActivityDate(DateTime? date) {
    if (date == null) return '';
    final d = date.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// Parses a hex color string (e.g. "#10B981") from the backend into a
  /// Flutter Color so the badge colour matches the server's classification.
  Color? _parseHexColor(String hex) {
    if (hex.isEmpty) return null;
    try {
      final h = hex.replaceFirst('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
