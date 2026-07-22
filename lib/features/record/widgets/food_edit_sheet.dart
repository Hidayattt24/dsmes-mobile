import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class FoodEditSheet extends StatefulWidget {
  const FoodEditSheet({
    super.key,
    this.initialTitle = 'Sarapan',
    this.initialSubtitle = '520 kcal • Nasi uduk, telur',
    this.initialTime = '09:00',
    this.onSaved,
  });

  final String initialTitle;
  final String initialSubtitle;
  final String initialTime;
  final void Function(String title, String subtitle, String time)? onSaved;

  @override
  State<FoodEditSheet> createState() => _FoodEditSheetState();
}

class _FoodEditSheetState extends State<FoodEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late String _selectedTime;

  final List<String> _times = [
    '07:30',
    '09:00',
    '12:30',
    '15:30',
    '19:00',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _subtitleController = TextEditingController(text: widget.initialSubtitle);
    _selectedTime = widget.initialTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
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
                    'Ubah Catatan Makanan',
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
                'Perbarui menu makanan & estimasi asupan kalori Anda.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kategori / Nama Sesi Makan
              Text(
                'Sesi Makan',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _titleController,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Misal: Sarapan, Makan Siang...',
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

              // Menu & Kalori
              Text(
                'Menu & Detail Kalori',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _subtitleController,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Misal: 520 kcal • Nasi uduk, telur',
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

              // Waktu Makan
              Text(
                'Waktu Makan',
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
                    final title = _titleController.text.trim().isEmpty
                        ? 'Makanan'
                        : _titleController.text.trim();
                    final subtitle = _subtitleController.text.trim().isEmpty
                        ? 'Catatan Makanan'
                        : _subtitleController.text.trim();
                    widget.onSaved?.call(title, subtitle, _selectedTime);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Catatan makanan "$title" berhasil diperbarui'),
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

Future<void> showFoodEditSheet(
  BuildContext context, {
  String initialTitle = 'Sarapan',
  String initialSubtitle = '520 kcal • Nasi uduk, telur',
  String initialTime = '09:00',
  void Function(String title, String subtitle, String time)? onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FoodEditSheet(
      initialTitle: initialTitle,
      initialSubtitle: initialSubtitle,
      initialTime: initialTime,
      onSaved: onSaved,
    ),
  );
}
