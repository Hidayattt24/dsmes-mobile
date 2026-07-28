import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../notifications/models/notification_item.dart';
import '../../../notifications/viewmodels/notifications_notifier.dart';
import '../../../onboarding/constants/routine_icons.dart';
import '../../../onboarding/widgets/icon_picker_bottom_sheet.dart';
import '../models/reminder_model.dart';
import '../viewmodels/reminder_provider.dart';

class RemindersManagementScreen extends ConsumerWidget {
  const RemindersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderListProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: remindersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Gagal memuat: $err',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.error)),
                ),
                data: (reminders) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: _buildBody(context, ref, reminders),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(context, ref, bottomPadding),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Pengaturan Pengingat',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, List<ReminderModel> reminders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          AppStrings.dailyRoutineTitle,
          style: AppTextStyles.headlineLg.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.dailyRoutineSubtitle,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoCard(text: AppStrings.dailyRoutineInfo),
        const SizedBox(height: AppSpacing.lg),
        _buildPresetSection(context, ref),
        const SizedBox(height: AppSpacing.xl),

        if (reminders.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Belum ada pengingat khusus. Klik tombol rekomendasi di atas atau tambah pengingat baru di bawah.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          )
        else
          ...List.generate(reminders.length, (i) {
            final reminder = reminders[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i < reminders.length - 1 ? AppSpacing.md : 0,
              ),
              child: _buildReminderCard(context, ref, reminder),
            );
          }),

        const SizedBox(height: AppSpacing.xl),
        _buildAddReminderButton(context, ref),
      ],
    );
  }

  Widget _buildPresetSection(BuildContext context, WidgetRef ref) {
    final presets = [
      (
        name: 'Minum Obat / Insulin',
        cat: 'medis_obat',
        timeStr: '07:00',
        icon: 'pill',
        notes: 'Minum obat atau suntik insulin sesudah makan'
      ),
      (
        name: 'Cek Gula Darah Puasa (GDP)',
        cat: 'medis_obat',
        timeStr: '06:00',
        icon: 'blood',
        notes: 'Pemeriksaan gula darah sesudah bangun tidur'
      ),
      (
        name: 'Cek Gula Darah 2 Jam Sesudah Makan',
        cat: 'medis_obat',
        timeStr: '14:00',
        icon: 'blood',
        notes: 'Pemeriksaan gula darah 2 jam sesudah makan siang'
      ),
      (
        name: 'Olahraga / Jalan Santai (30 mnt)',
        cat: 'aktivitas_fisik',
        timeStr: '06:30',
        icon: 'walk',
        notes: 'Aktivitas fisik harian'
      ),
      (
        name: 'Minum Air Putih (8 Gelas)',
        cat: 'nutrisi_air',
        timeStr: '08:00',
        icon: 'water',
        notes: 'Kebutuhan cairan harian'
      ),
      (
        name: 'Pemeriksaan Kesehatan Kaki',
        cat: 'lainnya',
        timeStr: '20:00',
        icon: 'foot',
        notes: 'Pemeriksaan kebersihan & integritas kulit kaki'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      'Rekomendasi Pengingat DSMES',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            InkWell(
              onTap: () async {
                await LocalNotificationService.instance.showNotification(
                  id: 99999,
                  title: '🔔 Tes Notifikasi DSMES',
                  body: 'Notifikasi pop-up pengingat Android berfungsi dengan baik!',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifikasi tes berhasil dikirim ke bar status HP.'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Tes Pop-Up',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Klik contoh pengingat untuk menambahkan ke daftar Anda (default: Nonaktif/Off):',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ActionChip(
                  avatar: Icon(resolveRoutineIcon(p.icon), size: 16, color: AppColors.primary),
                  label: Text('${p.name} • ${p.timeStr}'),
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  onPressed: () {
                    ref.read(reminderListProvider.notifier).create(
                          activityName: p.name,
                          category: p.cat,
                          scheduledTime: '${p.timeStr}:00',
                          notes: p.notes,
                          iconName: p.icon,
                          repeatIntervalDays: 1,
                          activeDays: [1, 2, 3, 4, 5, 6, 7],
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengingat "${p.name}" ditambahkan (Status: Off). Aktifkan toggle switch untuk mengaktifkan notifikasi.'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(
      BuildContext context, WidgetRef ref, ReminderModel reminder) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reminder.activityName,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
                onPressed: () =>
                    _onEditReminder(context, ref, reminder),
                visualDensity: VisualDensity.compact,
              ),
              GestureDetector(
                onTap: () =>
                    _onChangeIcon(context, ref, reminder),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: AppRadius.cardMd,
                  ),
                  child: Icon(
                    resolveRoutineIcon(reminder.iconName),
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: reminder.isActive,
                onChanged: (_) {
                  final willBeActive = !reminder.isActive;
                  ref.read(reminderListProvider.notifier).toggle(reminder.id);

                  if (willBeActive) {
                    // 1. Add notification item to in-app Notification Center
                    ref.read(notificationsProvider.notifier).addNotification(
                          title: 'Pengingat Aktif: ${reminder.activityName}',
                          description:
                              'Pengingat untuk ${reminder.activityName} akan berdering setiap pukul ${reminder.formattedTime} (${reminder.activeDaysLabel}).',
                          type: NotificationType.medication,
                        );

                    // 2. Trigger System Pop-Up Notification on Android status bar / lockscreen
                    final notifId = reminder.id.hashCode.abs();
                    LocalNotificationService.instance.showNotification(
                      id: notifId,
                      title: '⏰ Pengingat DSMES: ${reminder.activityName}',
                      body: 'Jadwal pukul ${reminder.formattedTime} - ${reminder.notes.isNotEmpty ? reminder.notes : 'Waktunya melakukan ${reminder.activityName}.'}',
                    );

                    // 3. Schedule recurring daily alarm for exact target time
                    final timeParts = reminder.scheduledTime.split(':');
                    if (timeParts.length >= 2) {
                      final h = int.tryParse(timeParts[0]) ?? 8;
                      final m = int.tryParse(timeParts[1]) ?? 0;
                      LocalNotificationService.instance.scheduleDailyNotification(
                        id: notifId,
                        title: '⏰ Waktunya ${reminder.activityName}',
                        body: 'Pengingat harian DSMES (${reminder.formattedTime}). ${reminder.notes}',
                        hour: h,
                        minute: m,
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Notifikasi pengingat "${reminder.activityName}" diaktifkan pada pukul ${reminder.formattedTime}'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    LocalNotificationService.instance.cancelNotification(reminder.id.hashCode.abs());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Pengingat "${reminder.activityName}" dinonaktifkan'),
                        backgroundColor: AppColors.onSurfaceVariant,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                reminder.formattedTime,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  reminder.activeDaysLabel,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (reminder.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              reminder.notes,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Divider(height: AppSpacing.lg),
          InkWell(
            onTap: () => _onDeleteReminder(context, ref, reminder),
            borderRadius: AppRadius.cardMd,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Hapus Pengingat',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReminderButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showAddReminderSheet(context, ref),
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.add, color: AppColors.onPrimary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.dailyRoutineAddCustom,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);
    final iconKey = ValueNotifier<String>('walk');
    String category = 'lainnya';
    List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tambah Pengingat Baru',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Aktivitas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        'Pilih Ikon:',
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.onSurface),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ValueListenableBuilder<String>(
                        valueListenable: iconKey,
                        builder: (context, currentIcon, _) {
                          return GestureDetector(
                            onTap: () async {
                              final selected = await showIconPicker(
                                context,
                                currentKey: currentIcon,
                              );
                              if (selected != null) {
                                iconKey.value = selected;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: AppRadius.cardMd,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    resolveRoutineIcon(currentIcon),
                                    color: AppColors.secondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(Icons.arrow_drop_down,
                                      color: AppColors.onSurfaceVariant),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waktu:',
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.onSurface),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                            builder: (context, child) => MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() => time = picked);
                          }
                        },
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Hari Aktif:',
                    style:
                        AppTextStyles.labelLg.copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDayChips(context, selectedDays, setSheetState),
                  const SizedBox(height: AppSpacing.md),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        final timeStr =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                        ref
                            .read(reminderListProvider.notifier)
                            .create(
                              activityName: nameController.text.trim(),
                              category: category,
                              scheduledTime: timeStr,
                              notes: notesController.text.trim(),
                              iconName: iconKey.value,
                              activeDays: selectedDays,
                            );
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.dailyRoutineAddButton,
                        style: AppTextStyles.poppinsButton,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayChips(
      BuildContext context, List<int> selectedDays, void Function(void Function()) setState) {
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final todayWeekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    final todayName = dayNames[todayWeekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Selection Shortcuts Row (including "Hari Ini")
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // "Hari Ini" Option
              ChoiceChip(
                avatar: Icon(
                  Icons.today,
                  size: 14,
                  color: (selectedDays.length == 1 && selectedDays.contains(todayWeekday))
                      ? Colors.white
                      : AppColors.primary,
                ),
                label: Text(
                  'Hari Ini ($todayName)',
                  style: TextStyle(
                    color: (selectedDays.length == 1 && selectedDays.contains(todayWeekday))
                        ? Colors.white
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                selected: selectedDays.length == 1 && selectedDays.contains(todayWeekday),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                onSelected: (_) {
                  setState(() {
                    selectedDays.clear();
                    selectedDays.add(todayWeekday);
                  });
                },
              ),
              const SizedBox(width: AppSpacing.xs),
              // "Setiap Hari" Option
              ChoiceChip(
                label: Text(
                  'Setiap Hari',
                  style: TextStyle(
                    color: selectedDays.length == 7 ? Colors.white : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                selected: selectedDays.length == 7,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerHigh,
                onSelected: (_) {
                  setState(() {
                    selectedDays.clear();
                    selectedDays.addAll([1, 2, 3, 4, 5, 6, 7]);
                  });
                },
              ),
              const SizedBox(width: AppSpacing.xs),
              // "Hari Kerja" Option
              ChoiceChip(
                label: Text(
                  'Sen - Jum',
                  style: TextStyle(
                    color: (selectedDays.length == 5 &&
                            !selectedDays.contains(6) &&
                            !selectedDays.contains(7))
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                selected: selectedDays.length == 5 &&
                    !selectedDays.contains(6) &&
                    !selectedDays.contains(7),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerHigh,
                onSelected: (_) {
                  setState(() {
                    selectedDays.clear();
                    selectedDays.addAll([1, 2, 3, 4, 5]);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Individual Day Filter Chips (Text strictly WHITE when selected)
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: List.generate(7, (i) {
            final day = i + 1;
            final isSelected = selectedDays.contains(day);
            final isTodayDay = (day == todayWeekday);

            return FilterChip(
              label: Text(
                isTodayDay ? '${dayNames[i]} •' : dayNames[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              backgroundColor: AppColors.surfaceContainerHigh,
              side: BorderSide(
                color: isTodayDay ? AppColors.primary : Colors.transparent,
                width: isTodayDay ? 1.5 : 0,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    if (!selectedDays.contains(day)) selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Future<bool> _onDeleteReminder(
      BuildContext context, WidgetRef ref, ReminderModel reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Hapus Pengingat',
          style: AppTextStyles.headlineMd
              .copyWith(color: AppColors.onSurface),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengingat "${reminder.activityName}"?',
          style: AppTextStyles.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: AppTextStyles.labelLg
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style:
                  AppTextStyles.labelLg.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(reminderListProvider.notifier).delete(reminder.id);
      return true;
    }
    return false;
  }

  void _onChangeIcon(
      BuildContext context, WidgetRef ref, ReminderModel reminder) async {
    final iconKey = await showIconPicker(context, currentKey: reminder.iconName);
    if (iconKey != null) {
      ref.read(reminderListProvider.notifier).updateReminder(
        reminder.id,
        activityName: reminder.activityName,
        category: reminder.category,
        scheduledTime: reminder.scheduledTime,
        notes: reminder.notes,
        iconName: iconKey,
        repeatIntervalDays: reminder.repeatIntervalDays,
        activeDays: reminder.activeDays,
      );
    }
  }

  void _onEditReminder(
      BuildContext context, WidgetRef ref, ReminderModel reminder) async {
    final nameController = TextEditingController(text: reminder.activityName);
    final notesController = TextEditingController(text: reminder.notes);
    TimeOfDay time;
    final parts = reminder.scheduledTime.split(':');
    if (parts.length >= 2) {
      time = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      time = const TimeOfDay(hour: 8, minute: 0);
    }
    final iconKey = ValueNotifier<String>(reminder.iconName);
    String category = reminder.category;
    List<int> selectedDays = [...reminder.activeDays];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Edit Pengingat',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Aktivitas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        'Ikon:',
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.onSurface),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ValueListenableBuilder<String>(
                        valueListenable: iconKey,
                        builder: (context, currentIcon, _) {
                          return GestureDetector(
                            onTap: () async {
                              final selected = await showIconPicker(
                                context,
                                currentKey: currentIcon,
                              );
                              if (selected != null) {
                                iconKey.value = selected;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: AppRadius.cardMd,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    resolveRoutineIcon(currentIcon),
                                    color: AppColors.secondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(Icons.arrow_drop_down,
                                      color: AppColors.onSurfaceVariant),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waktu:',
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.onSurface),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                            builder: (context, child) => MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() => time = picked);
                          }
                        },
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Hari Aktif:',
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDayChips(context, selectedDays, setSheetState),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        final timeStr =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                        ref
                            .read(reminderListProvider.notifier)
                            .updateReminder(
                              reminder.id,
                              activityName: nameController.text.trim(),
                              category: category,
                              scheduledTime: timeStr,
                              notes: notesController.text.trim(),
                              iconName: iconKey.value,
                              activeDays: selectedDays,
                            );
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan Perubahan',
                        style: AppTextStyles.poppinsButton,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter(
      BuildContext context, WidgetRef ref, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.md + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: AppButton(
        label: 'Simpan Pengaturan Pengingat',
        onPressed: () => context.pop(),
      ),
    );
  }
}
