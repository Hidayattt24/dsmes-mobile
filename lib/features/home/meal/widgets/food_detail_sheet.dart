import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/food_item.dart';

class FoodDetailSheet extends StatefulWidget {
  const FoodDetailSheet({
    super.key,
    required this.food,
    required this.onAddToLog,
    this.initialPortionMultiplier = 1.0,
    this.submitLabel = 'Tambahkan ke Log Harian',
    this.initialMealType = 'Makan Siang',
    this.showMealTypeSelector = false,
    this.onSubmitAsync,
  });

  final FoodItem food;
  final void Function(double portionMultiplier) onAddToLog;
  final double initialPortionMultiplier;
  final String submitLabel;
  final String initialMealType;
  final bool showMealTypeSelector;
  final Future<bool> Function({
    required double multiplier,
    required String mealType,
  })?
  onSubmitAsync;

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  // Grams for PER_100G mode
  late int _grams;

  // Servings / Packages for PER_SERVING or PER_PACKAGE mode
  late double _servings;
  late String _selectedMealType;
  bool _isSubmitting = false;
  String? _submitError;

  static const _mealTypes = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Camilan',
  ];

  @override
  void initState() {
    super.initState();
    final initial =
        widget.initialPortionMultiplier.isFinite &&
                widget.initialPortionMultiplier > 0
            ? widget.initialPortionMultiplier
            : 1.0;
    _grams = (initial * 100).round().clamp(25, 1500);
    _servings = initial.clamp(0.25, 20.0);
    _selectedMealType =
        _mealTypes.contains(widget.initialMealType)
            ? widget.initialMealType
            : _displayMealType(widget.initialMealType);
  }

  double get _multiplier {
    if (widget.food.isPer100g) {
      return _grams / 100.0;
    }
    return _servings;
  }

  double get _adjustedCalories => widget.food.energyKcal * _multiplier;
  double get _adjustedCarbs => widget.food.carbs * _multiplier;
  double get _adjustedProtein => widget.food.protein * _multiplier;
  double get _adjustedFat => widget.food.fat * _multiplier;
  double get _adjustedSugar => widget.food.sugarG * _multiplier;
  double get _adjustedSodium => widget.food.sodiumMg * _multiplier;
  double get _adjustedFiber => widget.food.fiberG * _multiplier;

  void _onGramsChanged(int newGrams) {
    setState(() {
      _grams = newGrams.clamp(25, 1500);
    });
  }

  void _onServingsChanged(double newServings) {
    setState(() {
      _servings = newServings.clamp(0.25, 20.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          // Keep sheet inside viewport on short phones and when keyboard opens.
          maxHeight:
              MediaQuery.sizeOf(context).height -
              MediaQuery.viewInsetsOf(context).bottom -
              16,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Food Title & Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: AppTextStyles.headlineMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (food.manufacturer.trim().isNotEmpty &&
                            food.manufacturer.trim().toLowerCase() !=
                                'tidak diketahui' &&
                            food.manufacturer.trim().toLowerCase() !=
                                'tidak ada' &&
                            food.manufacturer.trim() != '-') ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.storefront_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Produsen / Merk: ${food.manufacturer.trim()}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Nutrition Basis & Warning Banner
              _BasisBadge(food: food),

              if (food.isUnverified) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ukuran sajian atau basis nutrisi makanan ini belum terverifikasi. Nilai di bawah merupakan estimasi referensi awal.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.error,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              if (widget.showMealTypeSelector) ...[
                Text(
                  'Sesi Makan',
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _mealTypes.map((type) {
                        final selected = _selectedMealType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: selected,
                          selectedColor: AppColors.primaryContainer,
                          backgroundColor: AppColors.surfaceContainerLow,
                          labelStyle: AppTextStyles.labelMd.copyWith(
                            color:
                                selected
                                    ? AppColors.onPrimaryContainer
                                    : AppColors.onSurface,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected:
                              (_) => setState(() => _selectedMealType = type),
                        );
                      }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Portion Input Selector
              if (food.isPer100g) ...[
                _GramQuantitySelector(
                  grams: _grams,
                  onChanged: _onGramsChanged,
                ),
              ] else if (food.isPerPackage) ...[
                _PackageQuantitySelector(
                  packages: _servings,
                  servingSize: food.servingSize,
                  onChanged: _onServingsChanged,
                ),
              ] else ...[
                _ServingQuantitySelector(
                  servings: _servings,
                  servingSize: food.servingSize,
                  onChanged: _onServingsChanged,
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Nutrition Information Grid (7 values)
              _NutritionGrid(
                calories: _adjustedCalories,
                carbs: _adjustedCarbs,
                protein: _adjustedProtein,
                fat: _adjustedFat,
                sugar: _adjustedSugar,
                sodium: _adjustedSodium,
                fiber: _adjustedFiber,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed:
                      _isSubmitting
                          ? null
                          : () async {
                            setState(() => _submitError = null);
                            if (widget.onSubmitAsync != null) {
                              setState(() => _isSubmitting = true);
                              try {
                                final saved = await widget.onSubmitAsync!(
                                  multiplier: _multiplier,
                                  mealType: _selectedMealType,
                                );
                                if (!mounted) return;
                                if (saved) {
                                  Navigator.of(context).pop();
                                } else {
                                  setState(() {
                                    _isSubmitting = false;
                                    _submitError = 'Gagal menyimpan perubahan.';
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _isSubmitting = false;
                                    _submitError =
                                        'Gagal menyimpan perubahan: $e';
                                  });
                                }
                              }
                              return;
                            }
                            widget.onAddToLog(_multiplier);
                            if (mounted) Navigator.of(context).pop();
                          },
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.playlist_add, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                widget.submitLabel,
                                style: AppTextStyles.poppinsButton.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              if (_submitError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _submitError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _displayMealType(String value) {
  switch (value.toLowerCase()) {
    case 'sarapan':
      return 'Sarapan';
    case 'makan_malam':
      return 'Makan Malam';
    case 'camilan':
    case 'cemilan':
      return 'Camilan';
    default:
      return 'Makan Siang';
  }
}

class _BasisBadge extends StatelessWidget {
  const _BasisBadge({required this.food});

  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    Color color;
    Color bgColor;

    if (food.isUnverified) {
      label = 'Basis: Belum Terverifikasi';
      icon = Icons.help_outline_rounded;
      color = const Color(0xFFB45309);
      bgColor = const Color(0xFFFEF3C7);
    } else if (food.isPer100g) {
      label = 'Basis Nutrisi: Per 100 gram';
      icon = Icons.scale_rounded;
      color = AppColors.primary;
      bgColor = AppColors.primaryContainer.withValues(alpha: 0.25);
    } else if (food.isPerPackage) {
      label = 'Basis Nutrisi: Per Kemasan (${food.servingSize})';
      icon = Icons.inventory_2_outlined;
      color = Colors.purple.shade700;
      bgColor = Colors.purple.shade50;
    } else {
      label = 'Basis Nutrisi: Per Sajian (${food.servingSize})';
      icon = Icons.restaurant_rounded;
      color = Colors.blue.shade700;
      bgColor = Colors.blue.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GramQuantitySelector extends StatelessWidget {
  const _GramQuantitySelector({required this.grams, required this.onChanged});

  final int grams;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final presets = [50, 100, 150, 200, 250];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Berat Konsumsi (Gram)',
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              'Faktor: ${(grams / 100.0).toStringAsFixed(2)}x',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.remove,
              onTap: () => onChanged(grams - 25),
            ),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(
              width: 130,
              child: Column(
                children: [
                  Text(
                    '$grams',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppinsHeadline.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'gram',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            _CircleButton(
              icon: Icons.add,
              isPrimary: true,
              onTap: () => onChanged(grams + 25),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Presets
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                presets.map((g) {
                  final isSelected = grams == g;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$g g'),
                      selected: isSelected,
                      onSelected: (_) => onChanged(g),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerLow,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ServingQuantitySelector extends StatelessWidget {
  const _ServingQuantitySelector({
    required this.servings,
    required this.servingSize,
    required this.onChanged,
  });

  final double servings;
  final String servingSize;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final presets = [0.5, 1.0, 1.5, 2.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jumlah Sajian',
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '1 sajian = $servingSize',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.remove,
              onTap: () => onChanged(servings - 0.5),
            ),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(
              width: 120,
              child: Column(
                children: [
                  Text(
                    servings == servings.roundToDouble()
                        ? servings.toInt().toString()
                        : servings.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppinsHeadline.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'sajian',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            _CircleButton(
              icon: Icons.add,
              isPrimary: true,
              onTap: () => onChanged(servings + 0.5),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                presets.map((s) {
                  final isSelected = (servings - s).abs() < 0.01;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$s porsi'),
                      selected: isSelected,
                      onSelected: (_) => onChanged(s),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerLow,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PackageQuantitySelector extends StatelessWidget {
  const _PackageQuantitySelector({
    required this.packages,
    required this.servingSize,
    required this.onChanged,
  });

  final double packages;
  final String servingSize;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jumlah Kemasan',
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              servingSize,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.remove,
              onTap: () => onChanged(packages - 0.5),
            ),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(
              width: 120,
              child: Column(
                children: [
                  Text(
                    packages == packages.roundToDouble()
                        ? packages.toInt().toString()
                        : packages.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppinsHeadline.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'kemasan',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            _CircleButton(
              icon: Icons.add,
              isPrimary: true,
              onTap: () => onChanged(packages + 0.5),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.isPrimary = false,
    required this.onTap,
  });

  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color:
              isPrimary
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isPrimary ? AppColors.onPrimaryContainer : AppColors.primary,
          size: 26,
        ),
      ),
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  const _NutritionGrid({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sugar,
    required this.sodium,
    required this.fiber,
  });

  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double sugar;
  final double sodium;
  final double fiber;

  String _formatVal(double val) {
    if (val == val.truncateToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'INFORMASI NILAI GIZI KONSUMSI',
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            children: [
              // Row 1: Kalori, Karbo, Protein, Lemak
              Row(
                children: [
                  _NutritionCell(
                    value: _formatVal(calories),
                    label: 'Energi',
                    unit: 'kcal',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.primary,
                    isPrimary: true,
                  ),
                  _NutritionCell(
                    value: _formatVal(carbs),
                    label: 'Karbo',
                    unit: 'g',
                    icon: Icons.grain_rounded,
                    color: const Color(0xFFD97706),
                  ),
                  _NutritionCell(
                    value: _formatVal(protein),
                    label: 'Protein',
                    unit: 'g',
                    icon: Icons.fitness_center_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                  _NutritionCell(
                    value: _formatVal(fat),
                    label: 'Lemak',
                    unit: 'g',
                    icon: Icons.opacity_rounded,
                    color: const Color(0xFFE11D48),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.surfaceVariant),
              const SizedBox(height: AppSpacing.sm),
              // Row 2: Gula, Natrium, Serat
              Row(
                children: [
                  _NutritionCell(
                    value: _formatVal(sugar),
                    label: 'Gula',
                    unit: 'g',
                    icon: Icons.cookie_outlined,
                    color: const Color(0xFF7C3AED),
                  ),
                  _NutritionCell(
                    value: _formatVal(sodium),
                    label: 'Natrium',
                    unit: 'mg',
                    icon: Icons.shutter_speed_rounded,
                    color: const Color(0xFF0D9488),
                  ),
                  _NutritionCell(
                    value: _formatVal(fiber),
                    label: 'Serat',
                    unit: 'g',
                    icon: Icons.eco_outlined,
                    color: const Color(0xFF059669),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionCell extends StatelessWidget {
  const _NutritionCell({
    required this.value,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    this.isPrimary = false,
  });

  final String value;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: isPrimary ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '($unit)',
              style: AppTextStyles.labelMd.copyWith(
                fontSize: 9,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showFoodDetailSheet({
  required BuildContext context,
  required FoodItem food,
  required void Function(double portionMultiplier) onAddToLog,
  double initialPortionMultiplier = 1.0,
  String submitLabel = 'Tambahkan ke Log Harian',
  String initialMealType = 'Makan Siang',
  bool showMealTypeSelector = false,
  Future<bool> Function({required double multiplier, required String mealType})?
  onSubmitAsync,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => FoodDetailSheet(
          food: food,
          initialPortionMultiplier: initialPortionMultiplier,
          submitLabel: submitLabel,
          initialMealType: initialMealType,
          showMealTypeSelector: showMealTypeSelector,
          onSubmitAsync: onSubmitAsync,
          onAddToLog: onAddToLog,
        ),
  );
}
