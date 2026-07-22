import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'activity_entry_sheet.dart';
import 'medication_entry_sheet.dart';

class AddRecordSheet extends StatelessWidget {
  const AddRecordSheet({
    super.key,
    this.onActivitySaved,
    this.onMedicationSaved,
  });

  final void Function(String activityName, int duration, String intensity, [bool isCompleted])? onActivitySaved;
  final void Function(String medicationName, String dosage, String schedule, bool isTaken)? onMedicationSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
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
          Text(
            'Tambah Catatan',
            style: AppTextStyles.headlineLg.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _RecordOptionTile(
            title: 'Gula Darah',
            subtitle: 'Catat hasil pengukuran',
            icon: Icons.water_drop,
            iconBgColor: AppColors.errorContainer,
            iconColor: AppColors.onErrorContainer,
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.bloodSugarEntry);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          _RecordOptionTile(
            title: 'Makanan',
            subtitle: 'Catat asupan kalori',
            icon: Icons.restaurant,
            iconBgColor: AppColors.tertiaryFixed,
            iconColor: AppColors.onTertiaryFixedVariant,
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.mealEntry);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          _RecordOptionTile(
            title: 'Aktivitas',
            subtitle: 'Catat olahraga fisik',
            icon: Icons.directions_walk,
            iconBgColor: AppColors.secondaryFixed,
            iconColor: AppColors.onSecondaryFixedVariant,
            onTap: () {
              Navigator.of(context).pop();
              showActivityEntrySheet(context, onSaved: onActivitySaved);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          _RecordOptionTile(
            title: 'Obat',
            subtitle: 'Catat konsumsi obat',
            icon: Icons.medication,
            iconBgColor: AppColors.surfaceContainerHighest,
            iconColor: AppColors.onSurface,
            onTap: () {
              Navigator.of(context).pop();
              showMedicationEntrySheet(context, onSaved: onMedicationSaved);
            },
          ),
        ],
      ),
    );
  }
}

class _RecordOptionTile extends StatelessWidget {
  const _RecordOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAddRecordSheet(
  BuildContext context, {
  void Function(String activityName, int duration, String intensity, [bool isCompleted])? onActivitySaved,
  void Function(String medicationName, String dosage, String schedule, bool isTaken)? onMedicationSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddRecordSheet(
      onActivitySaved: onActivitySaved,
      onMedicationSaved: onMedicationSaved,
    ),
  );
}
