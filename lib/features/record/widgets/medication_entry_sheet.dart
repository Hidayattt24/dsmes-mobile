import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class MedicationEntrySheet extends StatefulWidget {
  const MedicationEntrySheet({
    super.key,
    this.initialMedicationName = 'Metformin',
    this.initialDosage = '500 mg',
    this.initialSchedule = '08:00',
    this.initialIsTaken = false,
    this.onSaved,
  });

  final String initialMedicationName;
  final String initialDosage;
  final String initialSchedule;
  final bool initialIsTaken;
  final void Function(
    String medicationName,
    String dosage,
    String schedule,
    bool isTaken,
  )? onSaved;

  @override
  State<MedicationEntrySheet> createState() => _MedicationEntrySheetState();
}

class _MedicationEntrySheetState extends State<MedicationEntrySheet> {
  late final TextEditingController _medNameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;
  late String _selectedTime;
  late bool _isTaken;

  final List<String> _medSuggestions = [
    'Metformin',
    'Glibenclamide',
    'Insulin',
    'Glimepiride',
    'Vildagliptin',
    'Empagliflozin',
  ];

  final List<String> _doseSuggestions = [
    '500 mg',
    '850 mg',
    '1000 mg',
    '1 Tablet',
    '2 Tablet',
  ];

  final List<String> _times = [
    '08:00',
    '13:00',
    '19:00',
  ];

  @override
  void initState() {
    super.initState();
    _medNameController = TextEditingController(text: widget.initialMedicationName);
    _dosageController = TextEditingController(text: widget.initialDosage);
    _notesController = TextEditingController();
    _selectedTime = widget.initialSchedule;
    _isTaken = widget.initialIsTaken;
  }

  @override
  void dispose() {
    _medNameController.dispose();
    _dosageController.dispose();
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
                    'Catat Minum Obat',
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
                'Masukkan nama & dosis obat yang Anda konsumsi.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Custom Medication Name Text Field
              Text(
                'Nama Obat',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _medNameController,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Misal: Metformin, Glibenclamide...',
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
              // Medication Suggestion Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _medSuggestions.map((med) {
                  return ActionChip(
                    label: Text(med),
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
                        _medNameController.text = med;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Custom Dosage Text Field
              Text(
                'Dosis',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _dosageController,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Misal: 500 mg, 1 Tablet...',
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
              // Dosage Suggestion Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _doseSuggestions.map((dose) {
                  return ActionChip(
                    label: Text(dose),
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
                        _dosageController.text = dose;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Waktu Jadwal
              Text(
                'Waktu Jadwal',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: _times.map((t) {
                  final isSelected = _selectedTime == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(child: Text(t)),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: AppTextStyles.labelMd.copyWith(
                          color: isSelected
                              ? AppColors.onPrimaryContainer
                              : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.surfaceContainerLow,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedTime = t);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Status Konsumsi Switch
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Konsumsi',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _isTaken ? 'Sudah Diminum' : 'Belum Diminum',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: _isTaken
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isTaken,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isTaken = val),
                    ),
                  ],
                ),
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
                    final medName = _medNameController.text.trim().isEmpty
                        ? 'Obat'
                        : _medNameController.text.trim();
                    final dose = _dosageController.text.trim().isEmpty
                        ? '500 mg'
                        : _dosageController.text.trim();

                    widget.onSaved?.call(medName, dose, _selectedTime, _isTaken);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Catatan obat "$medName ($dose)" berhasil diperbarui'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'Simpan Catatan Obat',
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

Future<void> showMedicationEntrySheet(
  BuildContext context, {
  String initialMedicationName = 'Metformin',
  String initialDosage = '500 mg',
  String initialSchedule = '08:00',
  bool initialIsTaken = false,
  void Function(
    String medicationName,
    String dosage,
    String schedule,
    bool isTaken,
  )? onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MedicationEntrySheet(
      initialMedicationName: initialMedicationName,
      initialDosage: initialDosage,
      initialSchedule: initialSchedule,
      initialIsTaken: initialIsTaken,
      onSaved: onSaved,
    ),
  );
}
