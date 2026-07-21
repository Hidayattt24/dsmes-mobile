import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CalendarMonthHeader extends StatelessWidget {
  const CalendarMonthHeader({
    super.key,
    required this.year,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final int year;
  final int month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: onPreviousMonth,
          color: AppColors.outline,
          tooltip: 'Bulan Sebelumnya',
        ),
        Text(
          '${_months[month - 1]} $year',
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 28),
          onPressed: onNextMonth,
          color: AppColors.outline,
          tooltip: 'Bulan Berikutnya',
        ),
      ],
    );
  }
}
