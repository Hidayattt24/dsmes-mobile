import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Reminder Settings Screen for managing notification schedules and preferences.
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  // Reminder states
  bool _bloodSugarEnabled = true;
  TimeOfDay _bloodSugarTime = const TimeOfDay(hour: 7, minute: 0);

  bool _medicationEnabled = true;
  TimeOfDay _medicationTime = const TimeOfDay(hour: 8, minute: 30);

  bool _mealEnabled = true;
  TimeOfDay _mealTime = const TimeOfDay(hour: 12, minute: 30);

  bool _activityEnabled = false;
  TimeOfDay _activityTime = const TimeOfDay(hour: 16, minute: 30);

  bool _dailySummaryEnabled = true;
  TimeOfDay _dailySummaryTime = const TimeOfDay(hour: 20, minute: 0);

  String _repeatOption = 'Setiap Hari';

  Future<void> _pickTime(
      TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  void _onSave() {
    AppSnackbar.showSuccess(
        context, 'Pengaturan pengingat berhasil disimpan.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pengaturan Pengingat',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro banner
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.onPrimary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Atur jadwal pengingat harian untuk membantu rutinitas pemantauan kesehatan Anda.',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Reminders List Container Card
                    Container(
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
                          Text(
                            'Jadwal Pengingat Harian',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // 1. Blood Sugar Reminder
                          _ReminderTile(
                            icon: Icons.water_drop_outlined,
                            iconColor: AppColors.primary,
                            title: 'Pengingat Cek Gula Darah',
                            subtitle: 'Jadwal rutin pengecekan mandiri',
                            isEnabled: _bloodSugarEnabled,
                            time: _bloodSugarTime,
                            onToggle: (val) =>
                                setState(() => _bloodSugarEnabled = val),
                            onPickTime: () => _pickTime(
                                _bloodSugarTime,
                                (t) => setState(() => _bloodSugarTime = t)),
                          ),
                          const Divider(height: 24),

                          // 2. Medication Reminder
                          _ReminderTile(
                            icon: Icons.medication_outlined,
                            iconColor: AppColors.secondary,
                            title: 'Pengingat Minum Obat',
                            subtitle: 'Pengingat dosis obat atau insulin',
                            isEnabled: _medicationEnabled,
                            time: _medicationTime,
                            onToggle: (val) =>
                                setState(() => _medicationEnabled = val),
                            onPickTime: () => _pickTime(
                                _medicationTime,
                                (t) => setState(() => _medicationTime = t)),
                          ),
                          const Divider(height: 24),

                          // 3. Meal Reminder
                          _ReminderTile(
                            icon: Icons.restaurant_outlined,
                            iconColor: AppColors.tertiary,
                            title: 'Pengingat Waktu Makan',
                            subtitle: 'Menjaga keteraturan jam makan',
                            isEnabled: _mealEnabled,
                            time: _mealTime,
                            onToggle: (val) => setState(() => _mealEnabled = val),
                            onPickTime: () => _pickTime(_mealTime,
                                (t) => setState(() => _mealTime = t)),
                          ),
                          const Divider(height: 24),

                          // 4. Activity Reminder
                          _ReminderTile(
                            icon: Icons.directions_run_rounded,
                            iconColor: AppColors.primaryContainer,
                            title: 'Pengingat Aktivitas Fisik',
                            subtitle: 'Jadwal olahraga / jalan kaki',
                            isEnabled: _activityEnabled,
                            time: _activityTime,
                            onToggle: (val) =>
                                setState(() => _activityEnabled = val),
                            onPickTime: () => _pickTime(_activityTime,
                                (t) => setState(() => _activityTime = t)),
                          ),
                          const Divider(height: 24),

                          // 5. Daily Summary Reminder
                          _ReminderTile(
                            icon: Icons.summarize_outlined,
                            iconColor: AppColors.outline,
                            title: 'Ringkasan Harian',
                            subtitle: 'Evaluasi catatan harian malam hari',
                            isEnabled: _dailySummaryEnabled,
                            time: _dailySummaryTime,
                            onToggle: (val) =>
                                setState(() => _dailySummaryEnabled = val),
                            onPickTime: () => _pickTime(_dailySummaryTime,
                                (t) => setState(() => _dailySummaryTime = t)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Repeat Option Card
                    Container(
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
                          Text(
                            'Frekuensi Pengulangan',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: 8,
                            children: [
                              'Setiap Hari',
                              'Hari Kerja (Senin-Jumat)',
                              'Akhir Pekan'
                            ].map((opt) {
                              final isSel = _repeatOption == opt;
                              return ChoiceChip(
                                label: Text(opt),
                                selected: isSel,
                                onSelected: (_) =>
                                    setState(() => _repeatOption = opt),
                                selectedColor: AppColors.primaryContainer,
                                backgroundColor: AppColors.surfaceContainerLow,
                                labelStyle: AppTextStyles.labelMd.copyWith(
                                  color: isSel
                                      ? AppColors.onPrimary
                                      : AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom Save Action
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: AppButton(
                label: 'Simpan Pengaturan',
                onPressed: _onSave,
                icon: Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.time,
    required this.onToggle,
    required this.onPickTime,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (isEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onPickTime,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time.format(context),
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
