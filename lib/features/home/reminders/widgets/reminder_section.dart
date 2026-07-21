import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReminderItemData {
  const ReminderItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.isCompleted,
    required this.iconBgColor,
    required this.iconColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool isCompleted;
  final Color iconBgColor;
  final Color iconColor;
}

class ReminderSection extends StatelessWidget {
  const ReminderSection({
    super.key,
    required this.reminders,
    required this.onViewAllPressed,
    this.onReminderTapped,
    this.emptyMessage,
  });

  final List<ReminderItemData> reminders;
  final VoidCallback onViewAllPressed;
  final ValueChanged<String>? onReminderTapped;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengingat Hari Ini',
                style: AppTextStyles.headlineMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  fontSize: 18,
                ),
              ),
              GestureDetector(
                onTap: onViewAllPressed,
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // List items
        reminders.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.outlineVariant,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      emptyMessage ?? 'Tidak ada pengingat untuk hari ini.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminders.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return _ReminderItemWidget(
                    data: reminder,
                    onTap: () => onReminderTapped?.call(reminder.id),
                  );
                },
              ),
      ],
    );
  }
}

class _ReminderItemWidget extends StatelessWidget {
  const _ReminderItemWidget({
    required this.data,
    this.onTap,
  });

  final ReminderItemData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: data.isCompleted ? 0.75 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0500695c),
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.card,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.card,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Leading Icon Box
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: data.iconBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      data.icon,
                      color: data.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data.title,
                              style: AppTextStyles.poppinsHeadline.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              data.time,
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (data.isCompleted)
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Selesai',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            data.subtitle,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
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
