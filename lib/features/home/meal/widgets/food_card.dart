import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/food_item.dart';
import 'macro_chip.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    required this.isSelected,
    required this.onAddPressed,
  });

  final FoodItem food;
  final bool isSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainer),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A00695C),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  food.name,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${food.servingSize} · ${food.calories} kcal',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    MacroChip(
                      label: 'Karbo',
                      value: '${food.carbs.toStringAsFixed(0)}g',
                      chipColor: AppColors.primaryFixed,
                      textColor: AppColors.onPrimaryFixedVariant,
                    ),
                    const SizedBox(width: 8),
                    MacroChip(
                      label: 'Prot',
                      value: '${food.protein.toStringAsFixed(0)}g',
                      chipColor: AppColors.secondaryFixed,
                      textColor: AppColors.onSecondaryFixedVariant,
                    ),
                    const SizedBox(width: 8),
                    MacroChip(
                      label: 'Lemak',
                      value: '${food.fat.toStringAsFixed(0)}g',
                      chipColor: AppColors.tertiaryFixed,
                      textColor: AppColors.onTertiaryFixedVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _AddButton(isSelected: isSelected, onTap: onAddPressed),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.primary,
            width: 2,
          ),
        ),
        child: Icon(
          isSelected ? Icons.check : Icons.add,
          color: isSelected ? AppColors.onPrimary : AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
