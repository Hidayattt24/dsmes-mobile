import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
            onSelected: (value) {
              if (value == 'read_all') {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              } else if (value == 'clear_all') {
                ref.read(notificationsProvider.notifier).clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Tandai Dibaca Semua'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Hapus Semua Notifikasi'),
                  ],
                ),
              ),
            ],
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
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(notificationsProvider.notifier).loadFromBackend(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
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
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Dismissible(
              key: Key('notif_${item.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              ),
              onDismissed: (_) {
                ref.read(notificationsProvider.notifier).deleteNotification(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notifikasi "${item.title}" telah dihapus.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: _NotificationCard(
                notification: item,
                onTap: () {
                  ref.read(notificationsProvider.notifier).markAsRead(item.id);
                  if (item.type == NotificationType.education &&
                      item.articleId != null) {
                    context.push(
                      '${RouteNames.educationDetail}/${item.articleId}',
                    );
                  }
                },
                onDelete: () => ref.read(notificationsProvider.notifier).deleteNotification(item.id),
              ),
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
    this.onDelete,
  });

  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

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
