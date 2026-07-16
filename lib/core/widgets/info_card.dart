import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.text,
    this.icon = Icons.lightbulb_outline,
    this.backgroundColor = const Color(0xFFe0f2f1),
    this.accentColor = AppColors.primaryContainer,
    this.iconColor = AppColors.primaryContainer,
  });

  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color accentColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.card,
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
