import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ActivityEntrySheet extends StatefulWidget {
  const ActivityEntrySheet({
    super.key,
    this.initialActivityName = 'Jalan Santai',
    this.initialDuration = 30,
    this.initialIntensity = 'Ringan',
    this.initialIsCompleted = true,
    this.onSaved,
  });

  final String initialActivityName;
  final int initialDuration;
  final String initialIntensity;
  final bool initialIsCompleted;
  final void Function(String activityName, int duration, String intensity, bool isCompleted)? onSaved;

  @override
  State<ActivityEntrySheet> createState() => _ActivityEntrySheetState();
}

class _ActivityEntrySheetState extends State<ActivityEntrySheet> {
  late final TextEditingController _activityNameController;
  late final TextEditingController _notesController;
  late int _durationMinutes;
  late String _selectedIntensity;
  late bool _isCompleted;

  final List<String> _quickSuggestions = [
    'Jalan Santai',
    'Lari / Jogging',
    'Bersepeda',
    'Berenang',
    'Yoga',
    'Gym / Fitness',
    'Badminton',
    'Tennis',
  ];

  final List<String> _intensities = [
    'Ringan',
    'Sedang',
    'Berat',
  ];

  @override
  void initState() {
    super.initState();
    _activityNameController = TextEditingController(text: widget.initialActivityName);
    _notesController = TextEditingController();
    _durationMinutes = widget.initialDuration;
    _selectedIntensity = widget.initialIntensity;
    _isCompleted = widget.initialIsCompleted;
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catat Aktivitas Fisik',
                    style: AppTextStyles.headlineLg.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                'Masukkan nama & detail aktivitas fisik Anda.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Status Toolbar: Sudah Melakukan vs Belum Melakukan
              Text(
                'Status Aktivitas',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCompleted = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? AppColors.secondaryContainer
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isCompleted
                                ? AppColors.secondary
                                : AppColors.outlineVariant.withValues(alpha: 0.4),
                            width: _isCompleted ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: _isCompleted
                                  ? AppColors.onSecondaryContainer
                                  : AppColors.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Sudah Melakukan',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: _isCompleted ? FontWeight.bold : FontWeight.w500,
                                color: _isCompleted
                                    ? AppColors.onSecondaryContainer
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCompleted = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isCompleted
                              ? AppColors.surfaceVariant
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !_isCompleted
                                ? AppColors.outline
                                : AppColors.outlineVariant.withValues(alpha: 0.4),
                            width: !_isCompleted ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: !_isCompleted
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Belum Melakukan',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: !_isCompleted ? FontWeight.bold : FontWeight.w500,
                                color: !_isCompleted
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Custom Activity Name Text Field
              Text(
                'Nama Aktivitas',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _activityNameController,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Misal: Jalan Santai, Yoga, Gym...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.outline,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Quick Suggestion Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _quickSuggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    labelStyle: AppTextStyles.labelMd.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    backgroundColor: AppColors.surfaceContainerLow,
                    side: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    onPressed: () {
                      setState(() {
                        _activityNameController.text = suggestion;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Durasi (Menit)
              Text(
                'Durasi (Menit)',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_durationMinutes > 5) {
                        setState(() => _durationMinutes -= 5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '$_durationMinutes Menit',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_durationMinutes < 300) {
                        setState(() => _durationMinutes += 5);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Intensitas
              Text(
                'Intensitas',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: _intensities.map((intensity) {
                  final isSelected = _selectedIntensity == intensity;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(child: Text(intensity)),
                        selected: isSelected,
                        selectedColor: AppColors.secondaryContainer,
                        labelStyle: AppTextStyles.labelMd.copyWith(
                          color: isSelected
                              ? AppColors.onSecondaryContainer
                              : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.surfaceContainerLow,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedIntensity = intensity);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final name = _activityNameController.text.trim().isEmpty
                        ? 'Aktivitas Fisik'
                        : _activityNameController.text.trim();
                    widget.onSaved?.call(name, _durationMinutes, _selectedIntensity, _isCompleted);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Aktivitas "$name" berhasil dicatat'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'Simpan Catatan Aktivitas',
                    style: AppTextStyles.poppinsButton.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showActivityEntrySheet(
  BuildContext context, {
  String initialActivityName = 'Jalan Santai',
  int initialDuration = 30,
  String initialIntensity = 'Ringan',
  bool initialIsCompleted = true,
  void Function(String activityName, int duration, String intensity, bool isCompleted)? onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ActivityEntrySheet(
      initialActivityName: initialActivityName,
      initialDuration: initialDuration,
      initialIntensity: initialIntensity,
      initialIsCompleted: initialIsCompleted,
      onSaved: onSaved,
    ),
  );
}
