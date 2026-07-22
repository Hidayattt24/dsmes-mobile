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
  });

  final FoodItem food;
  final VoidCallback onAddToLog;

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  late String _selectedServingSize;
  double _quantity = 1.0;
  static const double _step = 0.5;
  static const double _min = 0.5;
  static const double _max = 10.0;

  @override
  void initState() {
    super.initState();
    _selectedServingSize = widget.food.servingSize;
  }

  void _decrement() {
    if (_quantity > _min) {
      setState(() => _quantity = (_quantity - _step).clamp(_min, _max));
    }
  }

  void _increment() {
    if (_quantity < _max) {
      setState(() => _quantity = (_quantity + _step).clamp(_min, _max));
    }
  }

  int get _adjustedCalories => (widget.food.calories * _quantity).round();
  double get _adjustedCarbs => widget.food.carbs * _quantity;
  double get _adjustedProtein => widget.food.protein * _quantity;
  double get _adjustedFat => widget.food.fat * _quantity;

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
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menambahkan ${widget.food.name}',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            const SizedBox(height: AppSpacing.xl),
            _ServingSizeSelector(
              selectedServingSize: _selectedServingSize,
              options: widget.food.servingOptionsList,
              onChanged: (newServingSize) {
                setState(() {
                  _selectedServingSize = newServingSize;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _QuantityStepper(
              quantity: _quantity,
              onDecrement: _decrement,
              onIncrement: _increment,
            ),
            const SizedBox(height: AppSpacing.lg),
            _NutritionGrid(
              calories: _adjustedCalories,
              carbs: _adjustedCarbs,
              protein: _adjustedProtein,
              fat: _adjustedFat,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 4,
                  shadowColor: AppColors.shadowPrimary.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  widget.onAddToLog();
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.playlist_add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tambahkan ke Log Harian',
                      style: AppTextStyles.poppinsButton.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServingSizeSelector extends StatelessWidget {
  const _ServingSizeSelector({
    required this.selectedServingSize,
    required this.options,
    required this.onChanged,
  });

  final String selectedServingSize;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ukuran Sajian',
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(selectedServingSize)
                  ? selectedServingSize
                  : options.first,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more,
                color: AppColors.outline,
              ),
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.onSurface,
              ),
              dropdownColor: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final double quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Jumlah',
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onDecrement,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(
              width: 80,
              child: Text(
                quantity == quantity.roundToDouble()
                    ? quantity.toInt().toString()
                    : quantity.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: AppTextStyles.poppinsHeadline.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3300695C),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.onPrimaryContainer,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  const _NutritionGrid({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final int calories;
  final double carbs;
  final double protein;
  final double fat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'INFORMASI NUTRISI',
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
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
          child: Row(
            children: [
              _NutritionCell(
                value: '$calories',
                label: 'Kalori',
                unit: 'kcal',
                isPrimary: true,
              ),
              _NutritionCell(
                value: carbs.toStringAsFixed(1),
                label: 'Karbo',
                unit: 'g',
              ),
              _NutritionCell(
                value: protein.toStringAsFixed(1),
                label: 'Protein',
                unit: 'g',
              ),
              _NutritionCell(
                value: fat.toStringAsFixed(1),
                label: 'Lemak',
                unit: 'g',
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
    this.isPrimary = false,
  });

  final String value;
  final String label;
  final String unit;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppColors.primary : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              fontSize: 12,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '($unit)',
            style: AppTextStyles.labelMd.copyWith(
              fontSize: 10,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showFoodDetailSheet({
  required BuildContext context,
  required FoodItem food,
  required VoidCallback onAddToLog,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FoodDetailSheet(
      food: food,
      onAddToLog: onAddToLog,
    ),
  );
}
