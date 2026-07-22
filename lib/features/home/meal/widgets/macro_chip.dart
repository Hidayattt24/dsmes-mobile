import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MacroChip extends StatelessWidget {
  const MacroChip({
    super.key,
    required this.label,
    required this.value,
    this.chipColor = AppColors.primaryFixed,
    this.textColor = AppColors.onPrimaryFixedVariant,
  });

  final String label;
  final String value;
  final Color chipColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: AppTextStyles.labelMd.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
