import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/history/widgets/calendar_history_bottom_sheet.dart';
import '../models/record_entry.dart';
import '../widgets/activity_entry_sheet.dart';
import '../widgets/add_record_sheet.dart';
import '../widgets/blood_sugar_edit_sheet.dart';
import '../widgets/food_edit_sheet.dart';
import '../widgets/medication_entry_sheet.dart';
import '../widgets/record_action_card.dart';
import '../widgets/record_progress_card.dart';
import '../widgets/record_timeline_section.dart';

class RecordView extends StatefulWidget {
  const RecordView({super.key});

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  late DateTime _selectedDate;
  late RecordState _state;

  // Local state storage for history items (to allow mock edit & delete across dates)
  final Map<String, List<TimelineRecordItem>> _mockHistoryByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = MockRecordHistoryData.today;
    _state = RecordState(
      selectedDate: _selectedDate,
      selectedFilter: RecordType.all,
      completedCount: 0,
      totalCount: 4,
      bloodSugarValue: '-',
      bloodSugarSubtitle: 'Belum dicatat',
      foodValue: '0',
      foodSubtitle: 'Belum dicatat',
      activityName: 'Jalan Santai',
      activityDuration: 0,
      activityIntensity: 'Ringan',
      medicationName: 'Metformin',
      medicationDosage: '500 mg',
      medicationSchedule: '08:00',
      isMedicationTaken: false,
      todayTimelineItems: const [],
    );

    // Pre-populate mock history cache
    _mockHistoryByDate['yesterday'] = List.from(MockRecordHistoryData.yesterdayRecords);
    _mockHistoryByDate['lastTuesday'] = List.from(MockRecordHistoryData.lastTuesdayRecords);
    _mockHistoryByDate['threeDaysAgo'] = List.from(MockRecordHistoryData.threeDaysAgoRecords);
  }

  void _openCalendarHistoryBottomSheet() {
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

  void _updateActivity(String activityName, int duration, String intensity, [bool isCompleted = true]) {
    setState(() {
      final wasCompleted = _state.activityDuration > 0;
      final newCompleted = wasCompleted
          ? _state.completedCount
          : (_state.completedCount + 1).clamp(0, 4);

      final newTimelineItem = TimelineRecordItem(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        type: RecordType.activity,
        title: activityName,
        subtitle: '$duration Menit • $intensity',
        time: '16:00',
        dateText: 'Hari Ini',
        icon: Icons.directions_walk_outlined,
        dotOuterColor: AppColors.secondaryFixed,
        dotInnerColor: AppColors.secondary,
        badgeText: isCompleted ? intensity : 'Belum Melakukan',
        badgeBgColor: isCompleted ? AppColors.primaryContainer : AppColors.surfaceVariant,
        badgeTextColor: isCompleted ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
      );

      final updatedTimeline = [
        ..._state.todayTimelineItems.where((i) => !i.id.startsWith('act_')),
        newTimelineItem,
      ];

      _state = _state.copyWith(
        activityName: activityName,
        activityDuration: duration,
        activityIntensity: intensity,
        completedCount: newCompleted,
        todayTimelineItems: updatedTimeline,
      );
    });
  }

  void _updateMedication(
    String medicationName,
    String dosage,
    String schedule,
    bool isTaken,
  ) {
    setState(() {
      final wasTaken = _state.isMedicationTaken;
      int newCompleted = _state.completedCount;
      if (isTaken && !wasTaken) {
        newCompleted = (_state.completedCount + 1).clamp(0, 4);
      } else if (!isTaken && wasTaken) {
        newCompleted = (_state.completedCount - 1).clamp(0, 4);
      }

      final newTimelineItem = TimelineRecordItem(
        id: 'med_${DateTime.now().millisecondsSinceEpoch}',
        type: RecordType.medication,
        title: 'Minum Obat ($medicationName)',
        subtitle: '$dosage • Schedule $schedule',
        time: schedule,
        dateText: 'Hari Ini',
        icon: Icons.medication_outlined,
        dotOuterColor: AppColors.surfaceContainerHighest,
        dotInnerColor: AppColors.outline,
        badgeText: isTaken ? 'Sudah Minum' : 'Belum Minum',
        badgeBgColor: isTaken ? AppColors.secondaryContainer : AppColors.surfaceVariant,
        badgeTextColor: isTaken ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
      );

      final updatedTimeline = [
        ..._state.todayTimelineItems.where((i) => !i.id.startsWith('med_')),
        newTimelineItem,
      ];

      _state = _state.copyWith(
        medicationName: medicationName,
        medicationDosage: dosage,
        medicationSchedule: schedule,
        isMedicationTaken: isTaken,
        completedCount: newCompleted,
        todayTimelineItems: updatedTimeline,
      );
    });
  }

  List<TimelineRecordItem> _getTimelineForSelectedDate() {
    if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.today)) {
      return _state.todayTimelineItems;
    } else if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.yesterday)) {
      return _mockHistoryByDate['yesterday'] ?? [];
    } else if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.lastTuesday)) {
      return _mockHistoryByDate['lastTuesday'] ?? [];
    } else if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.threeDaysAgo)) {
      return _mockHistoryByDate['threeDaysAgo'] ?? [];
    }
    return const [];
  }

  void _updateTimelineForSelectedDate(List<TimelineRecordItem> newItems) {
    setState(() {
      if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.today)) {
        final newCompleted = newItems.length.clamp(0, 4);
        _state = _state.copyWith(
          todayTimelineItems: newItems,
          completedCount: newCompleted,
        );
      } else if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.yesterday)) {
        _mockHistoryByDate['yesterday'] = newItems;
      } else if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.lastTuesday)) {
        _mockHistoryByDate['lastTuesday'] = newItems;
      } else if (MockRecordHistoryData.isSameDate(_selectedDate, MockRecordHistoryData.threeDaysAgo)) {
        _mockHistoryByDate['threeDaysAgo'] = newItems;
      }
    });
  }

  void _handleEditItem(TimelineRecordItem item) {
    switch (item.type) {
      case RecordType.bloodSugar:
        final rawVal = item.subtitle.split(' ').first;
        showBloodSugarEditSheet(
          context,
          initialValue: rawVal == '-' ? '120' : rawVal,
          initialMoment: item.title,
          initialTime: item.time,
          initialStatus: item.badgeText ?? 'Normal',
          onSaved: (val, moment, time, status) {
            final currentItems = _getTimelineForSelectedDate();
            final updatedItems = currentItems.map((i) {
              if (i.id == item.id) {
                return TimelineRecordItem(
                  id: i.id,
                  type: RecordType.bloodSugar,
                  title: moment,
                  subtitle: '$val mg/dL',
                  time: time,
                  dateText: i.dateText,
                  icon: i.icon,
                  dotOuterColor: i.dotOuterColor,
                  dotInnerColor: i.dotInnerColor,
                  badgeText: status,
                  badgeBgColor: status == 'Tinggi'
                      ? AppColors.errorContainer
                      : AppColors.secondaryContainer,
                  badgeTextColor: status == 'Tinggi'
                      ? AppColors.onErrorContainer
                      : AppColors.onSecondaryContainer,
                );
              }
              return i;
            }).toList();
            _updateTimelineForSelectedDate(updatedItems);
          },
        );
        break;

      case RecordType.food:
        showFoodEditSheet(
          context,
          initialTitle: item.title,
          initialSubtitle: item.subtitle,
          initialTime: item.time,
          onSaved: (title, subtitle, time) {
            final currentItems = _getTimelineForSelectedDate();
            final updatedItems = currentItems.map((i) {
              if (i.id == item.id) {
                return TimelineRecordItem(
                  id: i.id,
                  type: RecordType.food,
                  title: title,
                  subtitle: subtitle,
                  time: time,
                  dateText: i.dateText,
                  icon: i.icon,
                  dotOuterColor: i.dotOuterColor,
                  dotInnerColor: i.dotInnerColor,
                );
              }
              return i;
            }).toList();
            _updateTimelineForSelectedDate(updatedItems);
          },
        );
        break;

      case RecordType.activity:
        final durationMatch = RegExp(r'(\d+)').firstMatch(item.subtitle);
        final dur = durationMatch != null ? int.parse(durationMatch.group(1)!) : 30;
        final isCompleted = item.badgeText != 'Belum Melakukan';
        showActivityEntrySheet(
          context,
          initialActivityName: item.title,
          initialDuration: dur,
          initialIntensity: isCompleted ? (item.badgeText ?? 'Ringan') : 'Ringan',
          initialIsCompleted: isCompleted,
          onSaved: (name, duration, intensity, isCompleted) {
            final currentItems = _getTimelineForSelectedDate();
            final updatedItems = currentItems.map((i) {
              if (i.id == item.id) {
                return TimelineRecordItem(
                  id: i.id,
                  type: RecordType.activity,
                  title: name,
                  subtitle: '$duration Menit • $intensity',
                  time: i.time,
                  dateText: i.dateText,
                  icon: i.icon,
                  dotOuterColor: i.dotOuterColor,
                  dotInnerColor: i.dotInnerColor,
                  badgeText: isCompleted ? intensity : 'Belum Melakukan',
                  badgeBgColor: isCompleted
                      ? AppColors.primaryContainer
                      : AppColors.surfaceVariant,
                  badgeTextColor: isCompleted
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurfaceVariant,
                );
              }
              return i;
            }).toList();
            _updateTimelineForSelectedDate(updatedItems);
          },
        );
        break;

      case RecordType.medication:
        final medName = item.title.contains('(')
            ? item.title.substring(item.title.indexOf('(') + 1, item.title.indexOf(')'))
            : 'Metformin';
        final isTaken = item.badgeText == 'Sudah Minum' || item.badgeText == 'Tepat Waktu';
        showMedicationEntrySheet(
          context,
          initialMedicationName: medName,
          initialDosage: item.subtitle,
          initialSchedule: item.time,
          initialIsTaken: isTaken,
          onSaved: (name, dosage, sched, isTaken) {
            final currentItems = _getTimelineForSelectedDate();
            final updatedItems = currentItems.map((i) {
              if (i.id == item.id) {
                return TimelineRecordItem(
                  id: i.id,
                  type: RecordType.medication,
                  title: 'Minum Obat ($name)',
                  subtitle: dosage,
                  time: sched,
                  dateText: i.dateText,
                  icon: i.icon,
                  dotOuterColor: i.dotOuterColor,
                  dotInnerColor: i.dotInnerColor,
                  badgeText: isTaken ? 'Sudah Minum' : 'Belum Minum',
                  badgeBgColor: isTaken
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceVariant,
                  badgeTextColor: isTaken
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
                );
              }
              return i;
            }).toList();
            _updateTimelineForSelectedDate(updatedItems);
          },
        );
        break;

      case RecordType.all:
        break;
    }
  }

  Future<void> _handleDeleteItem(TimelineRecordItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red trash icon header badge
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                'Hapus Catatan Kesehatan?',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLg.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Apakah Anda yakin ingin menghapus catatan "${item.title}"? Catatan yang dihapus tidak dapat dikembalikan.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons Row (Equal width, 100% centered text alignment)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.onError,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Center(
                          child: Text(
                            'Hapus',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final currentItems = _getTimelineForSelectedDate();
      final updatedItems = currentItems.where((i) => i.id != item.id).toList();
      _updateTimelineForSelectedDate(updatedItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catatan "${item.title}" berhasil dihapus'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTimelineItems = _getTimelineForSelectedDate();
    final currentTotalCount = currentTimelineItems.length;
    final currentCompletedCount = currentTimelineItems
        .where((item) => item.badgeText != 'Belum Minum' && item.badgeText != 'Belum Melakukan')
        .length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Header Section
            Text(
              'Catatan Harian',
              style: AppTextStyles.headlineLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau seluruh aktivitas harian Anda.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Today's Progress Card (Calculated dynamically from input data)
            RecordProgressCard(
              completedCount: currentCompletedCount,
              totalCount: currentTotalCount,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2x2 Grid of Action Log Cards (Aspect ratio 0.65 for overflow safety)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.65,
              children: [
                // Card A: Gula Darah
                RecordActionCard(
                  title: 'Gula Darah',
                  valueText: _state.bloodSugarValue,
                  unitText: _state.bloodSugarValue == '-' ? null : 'mg/dL',
                  subtitle: _state.bloodSugarSubtitle,
                  buttonText: 'Catat',
                  icon: Icons.water_drop,
                  iconBgColor: AppColors.errorContainer,
                  iconColor: AppColors.onErrorContainer,
                  onTap: () => context.push(RouteNames.bloodSugarEntry),
                ),
                // Card B: Makanan
                RecordActionCard(
                  title: 'Makanan',
                  valueText: _state.foodValue,
                  unitText: 'kcal',
                  subtitle: _state.foodSubtitle,
                  buttonText: 'Tambah',
                  icon: Icons.restaurant,
                  iconBgColor: AppColors.tertiaryFixed,
                  iconColor: AppColors.onTertiaryFixedVariant,
                  isPrimaryButton: true,
                  onTap: () => context.push(RouteNames.mealEntry),
                ),
                // Card C: Aktivitas
                RecordActionCard(
                  title: 'Aktivitas',
                  valueText: '${_state.activityDuration}',
                  unitText: 'menit',
                  subtitle: _state.activityName,
                  buttonText: 'Catat',
                  icon: Icons.directions_walk,
                  iconBgColor: AppColors.secondaryFixed,
                  iconColor: AppColors.onSecondaryFixedVariant,
                  onTap: () => showActivityEntrySheet(
                    context,
                    initialActivityName: _state.activityName,
                    initialDuration: _state.activityDuration == 0 ? 30 : _state.activityDuration,
                    initialIntensity: _state.activityIntensity,
                    onSaved: _updateActivity,
                  ),
                ),
                // Card D: Minum Obat (Overflow-Safe layout)
                RecordActionCard(
                  title: 'Minum Obat',
                  valueText: _state.medicationName,
                  unitText: _state.medicationDosage,
                  subtitle: 'Jadwal ${_state.medicationSchedule}',
                  buttonText: 'Perbarui',
                  icon: Icons.medication,
                  iconBgColor: AppColors.surfaceContainerHighest,
                  iconColor: AppColors.onSurface,
                  badgeText: _state.isMedicationTaken ? 'Sudah minum' : 'Belum minum',
                  badgeBgColor: _state.isMedicationTaken
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceVariant,
                  badgeTextColor: _state.isMedicationTaken
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
                  onTap: () => showMedicationEntrySheet(
                    context,
                    initialMedicationName: _state.medicationName,
                    initialDosage: _state.medicationDosage,
                    initialSchedule: _state.medicationSchedule,
                    initialIsTaken: _state.isMedicationTaken,
                    onSaved: _updateMedication,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Record Timeline Section with Edit & Delete support
            RecordTimelineSection(
              selectedDate: _selectedDate,
              selectedFilter: _state.selectedFilter,
              items: currentTimelineItems,
              onDateSelected: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
              onFilterSelected: (newFilter) {
                setState(() {
                  _state = _state.copyWith(selectedFilter: newFilter);
                });
              },
              onOpenCalendarSheet: _openCalendarHistoryBottomSheet,
              onEditItem: _handleEditItem,
              onDeleteItem: _handleDeleteItem,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // Reduced, well-proportioned Floating Action Button (56x56)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => showAddRecordSheet(
            context,
            onActivitySaved: _updateActivity,
            onMedicationSaved: _updateMedication,
          ),
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add,
            size: 24,
          ),
        ),
      ),
    );
  }
}
