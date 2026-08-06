import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/history/widgets/calendar_history_bottom_sheet.dart';
import '../../home/reminders/viewmodels/reminder_provider.dart';
import '../../notifications/models/notification_item.dart';
import '../../notifications/viewmodels/notifications_notifier.dart';
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
    ref.read(notificationsProvider.notifier).addNotification(
      title: 'Aktivitas Fisik: $activityName',
      description: '$activityName selama $duration menit ($intensity) telah dicatat.',
      type: NotificationType.targetAchieved,
    );
  }

  void _onMedicationSaved(String medicationName, String dosage, String schedule, bool isTaken) async {
    // 1. Submit medication log to record provider
    await ref.read(recordProvider.notifier).submitMedication(
      medicationName: medicationName,
      dosage: dosage,
      schedule: schedule,
      isTaken: isTaken,
    );

    // Add to real notifications inbox list
    if (isTaken) {
      ref.read(notificationsProvider.notifier).addNotification(
        title: 'Catatan Obat: $medicationName',
        description: 'Konsumsi $medicationName ($dosage) jam $schedule WIB telah dicatat.',
        type: NotificationType.medication,
      );
    } else {
      final formattedSched = schedule.contains(':')
          ? (schedule.split(':').length == 2 ? '$schedule:00' : schedule)
          : '$schedule:00';
      ref.read(notificationsProvider.notifier).scheduleReminderNotification(
        title: 'Waktunya Minum Obat: $medicationName',
        description: 'Jadwal minum obat $medicationName ($dosage) Anda jam $schedule WIB.',
        scheduledTimeStr: formattedSched,
        type: NotificationType.medication,
      );
    }

    // 2. Sync the reminder list — submitMedication() already created/updated
    //    the backend reminder, so we only refresh the in-memory list here
    //    (avoids creating a duplicate reminder).
    try {
      await ref.read(reminderListProvider.notifier).refresh();
    } catch (_) {
      // Ignore sync failures.
    }

    // 3. When the medication has NOT been taken yet, activate the system
    //    reminder: immediate confirmation pop-up + daily scheduled alarm.
    //    No pop-up/dialog is shown when the status is updated to consumed.
    if (!isTaken) {
      final parts = schedule.split(':');
      final hour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 8) : 8;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final notifId = medicationName.hashCode.abs();

      try {
        await LocalNotificationService.instance.showNotification(
          id: notifId,
          title: 'Pengingat Minum Obat Diaktifkan ⏰',
          body: 'Pengingat untuk $medicationName ($dosage) jam $schedule WIB telah aktif!',
        );

        await LocalNotificationService.instance.scheduleDailyNotification(
          id: notifId + 1,
          title: 'Waktunya Minum Obat! 💊',
          body: 'Jangan lupa diminum: $medicationName ($dosage)',
          hour: hour,
          minute: minute,
        );
      } catch (_) {
        // Ignore if scheduling failed; the inbox entry is already added above.
      }

      // 4. Show the medication reminder dialog only when activating a reminder.
      if (mounted) {
        _showMedicationReminderPopup(context, medicationName, dosage, schedule, isTaken);
      }
    }
  }

  void _showMedicationReminderPopup(
    BuildContext context,
    String medicationName,
    String dosage,
    String schedule,
    bool isTaken,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => _MedicationReminderDialog(
        medicationName: medicationName,
        dosage: dosage,
        schedule: schedule,
        isTaken: isTaken,
      ),
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
                      buttonText: (pageState.medicationName != '-' && pageState.medicationName.trim().isNotEmpty)
                          ? 'Perbarui'
                          : 'Catat Obat',
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
                        initialMedicationName: pageState.medicationName == '-' ? 'Metformin' : pageState.medicationName,
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

class _MedicationReminderDialog extends ConsumerStatefulWidget {
  const _MedicationReminderDialog({
    required this.medicationName,
    required this.dosage,
    required this.schedule,
    required this.isTaken,
  });

  final String medicationName;
  final String dosage;
  final String schedule;
  final bool isTaken;

  @override
  ConsumerState<_MedicationReminderDialog> createState() => _MedicationReminderDialogState();
}

class _MedicationReminderDialogState extends ConsumerState<_MedicationReminderDialog> {
  late bool _enableReminder;

  @override
  void initState() {
    super.initState();
    _enableReminder = !widget.isTaken;
  }

  void _onToggleReminder(bool val) async {
    setState(() => _enableReminder = val);
    final formattedSched = widget.schedule.contains(':')
        ? (widget.schedule.split(':').length == 2 ? '${widget.schedule}:00' : widget.schedule)
        : '${widget.schedule}:00';

    final parts = widget.schedule.split(':');
    final hour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 8) : 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final notifId = widget.medicationName.hashCode.abs();

    if (val) {
      try {
        await ref.read(reminderListProvider.notifier).create(
          activityName: 'Minum Obat ${widget.medicationName} (${widget.dosage})',
          category: 'medis_obat',
          scheduledTime: formattedSched,
          notes: 'Belum diminum',
          activeDays: const [1, 2, 3, 4, 5, 6, 7],
        );

        // System Notification Pop-up & Alarm Schedule
        await LocalNotificationService.instance.showNotification(
          id: notifId,
          title: 'Pengingat Minum Obat Diaktifkan ⏰',
          body: 'Pengingat untuk ${widget.medicationName} (${widget.dosage}) jam ${widget.schedule} WIB telah aktif!',
        );

        await LocalNotificationService.instance.scheduleDailyNotification(
          id: notifId + 1,
          title: 'Waktunya Minum Obat! 💊',
          body: 'Jangan lupa diminum: ${widget.medicationName} (${widget.dosage})',
          hour: hour,
          minute: minute,
        );
      } catch (_) {}
    } else {
      await LocalNotificationService.instance.cancelNotification(notifId);
      await LocalNotificationService.instance.cancelNotification(notifId + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badge / Icon Banner
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.alarm_on_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Dialog Title
            Text(
              widget.isTaken ? 'Obat Berhasil Dicatat!' : 'Catatan & Pengingat Obat',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLg.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isTaken
                  ? 'Terima kasih telah mencatat konsumsi "${widget.medicationName} (${widget.dosage})".'
                  : 'Atur pengingat alarm agar Anda tidak melewatkan jadwal minum "${widget.medicationName}".',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Medication Detail Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.isTaken
                              ? AppColors.secondaryContainer
                              : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medication_rounded,
                          color: widget.isTaken ? AppColors.secondary : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.medicationName} (${widget.dosage})',
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Jadwal: ${widget.schedule} WIB',
                              style: AppTextStyles.bodyMd.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isTaken
                          ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                          : AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isTaken ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          size: 16,
                          color: widget.isTaken ? AppColors.secondary : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isTaken ? 'Status: Sudah Diminum' : 'Status: Belum Diminum',
                          style: AppTextStyles.labelMd.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.isTaken
                                ? AppColors.onSecondaryContainer
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Toggle Switch Section for "Belum Konsumsi" (!isTaken)
            if (!widget.isTaken) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _enableReminder
                      ? AppColors.primaryContainer.withValues(alpha: 0.3)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _enableReminder
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _enableReminder ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                      color: _enableReminder ? AppColors.primary : AppColors.outline,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingatkan Saya Minum Obat',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            _enableReminder
                                ? 'Notifikasi alarm diatur jam ${widget.schedule} WIB'
                                : 'Pengingat otomatis dinonaktifkan',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enableReminder,
                      activeColor: AppColors.primary,
                      onChanged: _onToggleReminder,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          'Tutup',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelLg.copyWith(
                            fontSize: 13,
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
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 2,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.reminders);
                      },
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              'Lihat Pengingat',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelLg.copyWith(
                                fontSize: 12.5,
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    );
  }
}
