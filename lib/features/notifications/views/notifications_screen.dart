import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/notification_item.dart';
import '../viewmodels/notifications_notifier.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final todayNotifications = notifications.where((n) => n.group == 'Hari Ini').toList();
    final yesterdayNotifications = notifications.where((n) => n.group == 'Kemarin').toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifikasi',
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
            child: Text(
              'Tandai Dibaca Semua',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0, // margin-mobile: 16px
            vertical: 24.0, // mt-2 + padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todayNotifications.isNotEmpty) ...[
                _buildSection(
                  title: 'Hari Ini',
                  notifications: todayNotifications,
                  ref: ref,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (yesterdayNotifications.isNotEmpty) ...[
                _buildSection(
                  title: 'Kemarin',
                  notifications: yesterdayNotifications,
                  ref: ref,
                ),
              ],
              if (notifications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Text('Tidak ada notifikasi.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<NotificationItem> notifications,
    required WidgetRef ref,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0), // space-y-3: 12px
          itemBuilder: (context, index) {
            final item = notifications[index];
            return _NotificationCard(
              notification: item,
              onTap: () => ref.read(notificationsProvider.notifier).markAsRead(item.id),
            );
          },
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Resolve styling based on unread warning status
    final bool isUnreadWarning = notification.isUnread && notification.type == NotificationType.warning;

    final Color bgColor = isUnreadWarning ? const Color(0xFFf0f8f7) : AppColors.surfaceContainerLowest;
    final Color borderColor = isUnreadWarning ? const Color(0xFFdcefed) : AppColors.outlineVariant;

    // Resolve icon details based on type
    final (IconData iconData, Color iconColor, Color iconBg) = switch (notification.type) {
      NotificationType.warning => (
          Icons.warning_rounded,
          AppColors.error,
          AppColors.errorContainer,
        ),
      NotificationType.medication => (
          Icons.medication_rounded,
          AppColors.onSecondaryContainer,
          AppColors.secondaryContainer,
        ),
      NotificationType.education => (
          Icons.menu_book_rounded,
          AppColors.tertiary,
          AppColors.tertiaryFixed,
        ),
      NotificationType.targetAchieved => (
          Icons.check_circle_rounded,
          AppColors.onSurfaceVariant,
          AppColors.surfaceContainerHigh,
        ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isUnreadWarning
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0A00695C),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box (48x48 rounded-full)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16.0),

            // Description/Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.poppinsHeadline.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            notification.timestamp,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (notification.isUnread) ...[
                            const SizedBox(width: 8.0),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    notification.description,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
