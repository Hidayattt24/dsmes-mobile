import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/notification_item.dart';

class NotificationDetailBottomSheet extends StatelessWidget {
  const NotificationDetailBottomSheet({
    super.key,
    required this.item,
    required this.interactiveTitle,
    required this.interactiveDescription,
    this.onDelete,
  });

  final NotificationItem item;
  final String interactiveTitle;
  final String interactiveDescription;
  final VoidCallback? onDelete;

  static Future<void> show(
    BuildContext context, {
    required NotificationItem item,
    required String interactiveTitle,
    required String interactiveDescription,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationDetailBottomSheet(
        item: item,
        interactiveTitle: interactiveTitle,
        interactiveDescription: interactiveDescription,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (IconData iconData, Color primaryColor, Color bgColor, String tagLabel) = switch (item.type) {
      NotificationType.warning => (
          Icons.warning_rounded,
          AppColors.error,
          AppColors.errorContainer.withValues(alpha: 0.5),
          'PERINGATAN KESEHATAN 🚨',
        ),
      NotificationType.medication => (
          Icons.alarm_on_rounded,
          AppColors.primary,
          const Color(0xFFE6F2F1),
          'PENGINGAT RUTIN 💊',
        ),
      NotificationType.education => (
          Icons.menu_book_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFFFBEB),
          'EDUKASI KESEHATAN 💡',
        ),
      NotificationType.targetAchieved => (
          Icons.emoji_events_rounded,
          const Color(0xFF059669),
          const Color(0xFFECFDF5),
          'PENCAPAIAN DIRI 🏆',
        ),
    };

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 32,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                tagLabel,
                style: AppTextStyles.labelSm.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hero Circle Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 2),
              ),
              child: Icon(
                iconData,
                color: primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Title
            Text(
              interactiveTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),

            // Interactive Description
            Text(
              interactiveDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Tutup',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (item.type == NotificationType.education && item.articleId != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(
                          '${RouteNames.educationDetail}/${item.articleId}',
                        );
                      },
                      child: Text(
                        'Baca Artikel',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else if (item.type == NotificationType.warning || item.type == NotificationType.medication) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.bloodSugarEntry);
                      },
                      child: Text(
                        'Catat Sekarang',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete!();
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                label: Text(
                  'Hapus Notifikasi',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
