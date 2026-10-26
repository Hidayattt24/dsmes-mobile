import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/food_repository.dart';

class FoodRequestSheet extends ConsumerStatefulWidget {
  const FoodRequestSheet({
    super.key,
    this.initialFoodName = '',
    this.initialMealType = 'Makan Siang',
  });

  final String initialFoodName;
  final String initialMealType;

  @override
  ConsumerState<FoodRequestSheet> createState() => _FoodRequestSheetState();
}

class _FoodRequestSheetState extends ConsumerState<FoodRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _servingController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _notesController;

  late String _selectedMealType;
  bool _isSubmitting = false;

  final List<String> _quickPortions = [
    '1 Piring sedang',
    '1 Mangkok',
    '1 Potong sedang',
    '1 Gelas (250 ml)',
    '1 Bungkus',
    '100 gram',
  ];

  final List<String> _mealTypes = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFoodName.trim());
    _servingController = TextEditingController(text: '1 Piring sedang');
    _caloriesController = TextEditingController();
    _notesController = TextEditingController();
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(foodRepositoryProvider);
      final double? cals = double.tryParse(_caloriesController.text.trim());

      await repo.submitFoodRequest(
        name: _nameController.text.trim(),
        servingSize: _servingController.text.trim(),
        estimatedCalories: cals,
        mealType: _selectedMealType,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pengajuan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header with badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.post_add_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ajukan Makanan Baru',
                              style: AppTextStyles.titleLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bantu lengkapi data nutrisi makanan DIBA',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.outline),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Food Name Field
                  Text(
                    'Nama Makanan / Minuman *',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Nasi Liwet Solo, Es Timun Serut',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nama makanan wajib diisi';
                      }
                      if (v.trim().length < 2) {
                        return 'Minimal 2 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Serving Size Field
                  Text(
                    'Ukuran / Takaran Porsi *',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _servingController,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Pilih opsi di bawah atau ketik manual...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Takaran porsi wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),

                  // Quick portion chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in _quickPortions)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _servingController.text = p;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _servingController.text == p
                                  ? AppColors.primaryContainer.withValues(alpha: 0.35)
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _servingController.text == p
                                    ? AppColors.primary
                                    : AppColors.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              p,
                              style: AppTextStyles.bodySm.copyWith(
                                color: _servingController.text == p
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: _servingController.text == p
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Meal Type Selection
                  Text(
                    'Sesi Makan',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in _mealTypes)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedMealType = type);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedMealType == type
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _selectedMealType == type
                                    ? AppColors.primary
                                    : AppColors.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              type,
                              style: AppTextStyles.bodySm.copyWith(
                                color: _selectedMealType == type
                                    ? Colors.white
                                    : AppColors.onSurfaceVariant,
                                fontWeight: _selectedMealType == type
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Estimated Calories (Optional)
                  Row(
                    children: [
                      Text(
                        'Estimasi Kalori (kcal)',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(Opsional)',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 350',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      suffixText: 'kcal',
                      suffixStyle: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Notes
                  Row(
                    children: [
                      Text(
                        'Catatan Tambahan',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(Opsional)',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Bahan utama, merk, atau cara memasak...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 3,
                        shadowColor: AppColors.shadowPrimary.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Kirim Pengajuan Makanan',
                              style: AppTextStyles.poppinsButton.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
