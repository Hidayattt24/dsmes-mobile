import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable section title with optional subtitle.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing = AppSpacing.xs,
  });

  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle ?? AppTextStyles.poppinsHeadline,
        ),
        if (subtitle != null) ...[
          SizedBox(height: spacing),
          Text(
            subtitle!,
            style: subtitleStyle ??
                AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
