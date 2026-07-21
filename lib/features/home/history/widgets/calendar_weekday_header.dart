import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CalendarWeekdayHeader extends StatelessWidget {
  const CalendarWeekdayHeader({super.key});

  static const List<String> _weekdays = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        return Expanded(
          child: Center(
            child: Text(
              _weekdays[index],
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
          ),
        );
      }),
    );
  }
}
