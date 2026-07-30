import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/history/widgets/calendar_history_bottom_sheet.dart';
import '../models/record_entry.dart';
import '../models/record_provider.dart';
import '../widgets/activity_entry_sheet.dart';
import '../widgets/add_record_sheet.dart';
import '../widgets/blood_sugar_edit_sheet.dart';
import '../widgets/food_edit_sheet.dart';
import '../widgets/medication_entry_sheet.dart';
import '../widgets/record_action_card.dart';
import '../widgets/record_progress_card.dart';
import '../widgets/record_timeline_section.dart';

class RecordView extends ConsumerStatefulWidget {
  const RecordView({super.key});

  @override
  ConsumerState<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends ConsumerState<RecordView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recordProvider.notifier).loadData();
    });
  }

  void _openCalendarHistoryBottomSheet() {
    final state = ref.read(recordProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarHistoryBottomSheet(
        initialDate: state.selectedDate ?? DateTime.now(),
        onDateSelected: (date) {
          ref.read(recordProvider.notifier).setSelectedDate(date);
        },
      ),
    );
  }

  void _onActivitySaved(String activityName, int duration, String intensity, [bool isCompleted = true]) {
    ref.read(recordProvider.notifier).submitActivity(
      activityName: activityName,
      duration: duration,
      intensity: intensity,
    );
  }

  void _onMedicationSaved(String medicationName, String dosage, String schedule, bool isTaken) {
    ref.read(recordProvider.notifier).submitMedication(
      medicationName: medicationName,
      dosage: dosage,
      schedule: schedule,
      isTaken: isTaken,
    );
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
            ref.read(recordProvider.notifier).updateBloodSugar(
              id: item.id,
              glucoseValue: int.tryParse(val) ?? 0,
              measurementType: _mapMomentToType(moment),
              measuredAt: _parseDateTime(time),
            );
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
            ref.read(recordProvider.notifier).loadData();
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
            _onActivitySaved(name, duration, intensity, isCompleted);
          },
        );
        break;

      case RecordType.medication:
        final medName = item.title.isNotEmpty ? item.title : 'Metformin';
        final rawDosage = item.subtitle;
        final dosage = (rawDosage == 'selesai' || rawDosage == 'pending' || rawDosage == 'terlewat' || rawDosage.isEmpty)
            ? '500 mg'
            : rawDosage;
        final isTaken = item.badgeText == 'Sudah Minum' || item.badgeText == 'Tepat Waktu' || item.badgeText == 'selesai';
        showMedicationEntrySheet(
          context,
          initialMedicationName: medName,
          initialDosage: dosage,
          initialSchedule: item.time,
          initialIsTaken: isTaken,
          onSaved: (name, dosage, sched, isTaken) {
            _onMedicationSaved(name, dosage, sched, isTaken);
          },
        );
        break;

      case RecordType.all:
        break;
    }
  }

  String _mapMomentToType(String moment) {
    switch (moment) {
      case 'Sebelum Sarapan':
        return 'fasting';
      case 'Sesudah Makan':
        return 'after_meal';
      case 'Gula Darah Puasa':
        return 'fasting';
      case 'Sebelum Tidur':
        return 'before_bed';
      default:
        return 'random';
    }
  }

  String _parseDateTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(now.year, now.month, now.day, hour, minute).toUtc().toIso8601String();
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
      await ref.read(recordProvider.notifier).deleteHistoryItem(item.type, item.id);
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
    final pageState = ref.watch(recordProvider);
    final currentTimelineItems = pageState.todayTimelineItems;

    // Show error as SnackBar
    ref.listen<RecordPageState>(recordProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.errorContainer,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Tutup',
              textColor: AppColors.onErrorContainer,
              onPressed: () => ref.read(recordProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () => ref.read(recordProvider.notifier).loadData(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
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



                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.65,
                  children: [
                    RecordActionCard(
                      title: 'Gula Darah',
                      valueText: pageState.bloodSugarValue,
                      unitText: pageState.bloodSugarValue == '-' ? null : 'mg/dL',
                      subtitle: pageState.bloodSugarSubtitle,
                      buttonText: 'Catat',
                      icon: Icons.water_drop,
                      iconBgColor: AppColors.errorContainer,
                      iconColor: AppColors.onErrorContainer,
                      onTap: () => context.push(RouteNames.bloodSugarEntry),
                    ),
                    RecordActionCard(
                      title: 'Makanan',
                      valueText: pageState.foodValue,
                      unitText: 'kcal',
                      subtitle: pageState.foodSubtitle,
                      buttonText: 'Tambah',
                      icon: Icons.restaurant,
                      iconBgColor: AppColors.tertiaryFixed,
                      iconColor: AppColors.onTertiaryFixedVariant,
                      isPrimaryButton: true,
                      onTap: () => context.push(RouteNames.mealEntry),
                    ),
                    RecordActionCard(
                      title: 'Aktivitas',
                      valueText: '${pageState.activityDuration}',
                      unitText: 'menit',
                      subtitle: pageState.activityName,
                      buttonText: 'Catat',
                      icon: Icons.directions_walk,
                      iconBgColor: AppColors.secondaryFixed,
                      iconColor: AppColors.onSecondaryFixedVariant,
                      onTap: () => showActivityEntrySheet(
                        context,
                        initialActivityName: pageState.activityName,
                        initialDuration: pageState.activityDuration == 0 ? 30 : pageState.activityDuration,
                        initialIntensity: pageState.activityIntensity,
                        onSaved: _onActivitySaved,
                      ),
                    ),
                    RecordActionCard(
                      title: 'Minum Obat',
                      valueText: pageState.medicationName,
                      unitText: pageState.medicationDosage,
                      subtitle: 'Jadwal ${pageState.medicationSchedule}',
                      buttonText: 'Perbarui',
                      icon: Icons.medication,
                      iconBgColor: AppColors.surfaceContainerHighest,
                      iconColor: AppColors.onSurface,
                      badgeText: pageState.isMedicationTaken ? 'Sudah minum' : 'Belum minum',
                      badgeBgColor: pageState.isMedicationTaken
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceVariant,
                      badgeTextColor: pageState.isMedicationTaken
                          ? AppColors.onSecondaryContainer
                          : AppColors.onSurfaceVariant,
                      onTap: () => showMedicationEntrySheet(
                        context,
                        initialMedicationName: pageState.medicationName,
                        initialDosage: pageState.medicationDosage,
                        initialSchedule: pageState.medicationSchedule,
                        initialIsTaken: pageState.isMedicationTaken,
                        onSaved: _onMedicationSaved,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                RecordTimelineSection(
                  selectedDate: pageState.selectedDate ?? DateTime.now(),
                  selectedFilter: pageState.selectedFilter,
                  items: currentTimelineItems,
                  onDateSelected: (newDate) {
                    ref.read(recordProvider.notifier).setSelectedDate(newDate);
                  },
                  onFilterSelected: (newFilter) {
                    ref.read(recordProvider.notifier).setSelectedFilter(newFilter);
                  },
                  onOpenCalendarSheet: _openCalendarHistoryBottomSheet,
                  onEditItem: _handleEditItem,
                  onDeleteItem: _handleDeleteItem,
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => showAddRecordSheet(
            context,
            onActivitySaved: _onActivitySaved,
            onMedicationSaved: _onMedicationSaved,
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
