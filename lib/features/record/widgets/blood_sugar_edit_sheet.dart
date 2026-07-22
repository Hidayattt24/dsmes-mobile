import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class BloodSugarEditSheet extends StatefulWidget {
  const BloodSugarEditSheet({
    super.key,
    this.initialValue = '120',
    this.initialMoment = 'Sebelum Sarapan',
    this.initialTime = '07:30',
    this.initialStatus = 'Normal',
    this.onSaved,
  });

  final String initialValue;
  final String initialMoment;
  final String initialTime;
  final String initialStatus;
  final void Function(String value, String moment, String time, String status)? onSaved;

  @override
  State<BloodSugarEditSheet> createState() => _BloodSugarEditSheetState();
}

class _BloodSugarEditSheetState extends State<BloodSugarEditSheet> {
  late final TextEditingController _valueController;
  late String _selectedMoment;
  late String _selectedTime;
  late String _selectedStatus;

  final List<String> _moments = [
    'Sebelum Sarapan',
    'Sesudah Makan',
    'Gula Darah Puasa',
    'Sebelum Tidur',
  ];

  final List<String> _statuses = [
    'Normal',
    'Tinggi',
    'Rendah',
  ];

  final List<String> _times = [
    '07:00',
    '07:30',
    '11:30',
    '18:00',
    '21:00',
  ];

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.initialValue);
    _selectedMoment = widget.initialMoment;
    _selectedTime = widget.initialTime;
    _selectedStatus = widget.initialStatus;
  }

  @override
  void dispose() {
    _valueController.dispose();
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
                    'Ubah Catatan Gula Darah',
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
                'Perbarui hasil pengukuran kadar gula darah Anda.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kadar Gula Darah (mg/dL)
              Text(
                'Kadar Gula Darah (mg/dL)',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Misal: 120',
                  suffixText: 'mg/dL',
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
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Momen Pengukuran
              Text(
                'Momen Pengukuran',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _moments.map((moment) {
                  final isSelected = _selectedMoment == moment;
                  return ChoiceChip(
                    label: Text(moment),
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
                      if (selected) setState(() => _selectedMoment = moment);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Status Kategori
              Text(
                'Status Kadar',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: _statuses.map((status) {
                  final isSelected = _selectedStatus == status;
                  final isError = status == 'Tinggi' || status == 'Rendah';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(child: Text(status)),
                        selected: isSelected,
                        selectedColor: isError
                            ? AppColors.errorContainer
                            : AppColors.secondaryContainer,
                        labelStyle: AppTextStyles.labelMd.copyWith(
                          color: isSelected
                              ? (isError
                                  ? AppColors.onErrorContainer
                                  : AppColors.onSecondaryContainer)
                              : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.surfaceContainerLow,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedStatus = status);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Waktu Pengukuran
              Text(
                'Waktu Pengukuran',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _times.map((t) {
                  final isSelected = _selectedTime == t;
                  return ChoiceChip(
                    label: Text(t),
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
                      if (selected) setState(() => _selectedTime = t);
                    },
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
                    final val = _valueController.text.trim().isEmpty
                        ? '120'
                        : _valueController.text.trim();
                    widget.onSaved?.call(val, _selectedMoment, _selectedTime, _selectedStatus);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Catatan gula darah "$val mg/dL" berhasil diperbarui'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'Simpan Perubahan',
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

Future<void> showBloodSugarEditSheet(
  BuildContext context, {
  String initialValue = '120',
  String initialMoment = 'Sebelum Sarapan',
  String initialTime = '07:30',
  String initialStatus = 'Normal',
  void Function(String value, String moment, String time, String status)? onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BloodSugarEditSheet(
      initialValue: initialValue,
      initialMoment: initialMoment,
      initialTime: initialTime,
      initialStatus: initialStatus,
      onSaved: onSaved,
    ),
  );
}
