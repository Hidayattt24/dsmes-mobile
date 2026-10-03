import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/notification_item.dart';
import '../viewmodels/notifications_notifier.dart';
import '../widgets/notification_detail_bottom_sheet.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Belum Dibaca',
    'Pengingat',
    'Edukasi',
  ];

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((n) => n.isUnread).length;

    // Apply filter
    final filteredNotifications = notifications.where((n) {
      if (_selectedFilter == 'Belum Dibaca') return n.isUnread;
      if (_selectedFilter == 'Pengingat') {
        return n.type == NotificationType.medication ||
            n.type == NotificationType.warning;
      }
      if (_selectedFilter == 'Edukasi') {
        return n.type == NotificationType.education;
      }
      return true;
    }).toList();

    final todayNotifications =
        filteredNotifications.where((n) => n.group == 'Hari Ini').toList();
    final yesterdayNotifications =
        filteredNotifications.where((n) => n.group == 'Kemarin').toList();
    final otherNotifications = filteredNotifications
        .where((n) => n.group != 'Hari Ini' && n.group != 'Kemarin')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              'Notifikasi',
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount Baru',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'read_all') {
                ref.read(notificationsProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi telah ditandai dibaca. ✓'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.primary,
                  ),
                );
              } else if (value == 'clear_all') {
                ref.read(notificationsProvider.notifier).clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi telah dihapus.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.onSurfaceVariant,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text('Tandai Dibaca Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Hapus Semua Notifikasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Interactive Filter Bar
            Container(
              width: double.infinity,
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(filter),
                        labelStyle: AppTextStyles.labelSm.copyWith(
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                        backgroundColor: AppColors.surfaceContainerLow,
                        selectedColor: AppColors.primary,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFilter = filter);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Notification List Area
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(notificationsProvider.notifier).loadFromBackend(),
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todayNotifications.isNotEmpty) ...[
                              _buildSection(
                                title: 'Hari Ini',
                                notifications: todayNotifications,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            if (yesterdayNotifications.isNotEmpty) ...[
                              _buildSection(
                                title: 'Kemarin',
                                notifications: yesterdayNotifications,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            if (otherNotifications.isNotEmpty) ...[
                              _buildSection(
                                title: 'Sebelumnya',
                                notifications: otherNotifications,
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F9F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Notifikasi!',
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua jadwal pengingat dan catatan kesehatanmu berjalan dengan baik. Tetap semangat! ✨',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<NotificationItem> notifications,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10.0),
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
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
              ),
              onDismissed: (_) {
                ref
                    .read(notificationsProvider.notifier)
                    .deleteNotification(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notifikasi telah dihapus.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: _NotificationCard(
                notification: item,
                onMarkRead: () {
                  ref.read(notificationsProvider.notifier).markAsRead(item.id);
                },
                onDelete: () {
                  ref.read(notificationsProvider.notifier).deleteNotification(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifikasi telah dihapus.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onTap: () {
                  ref.read(notificationsProvider.notifier).markAsRead(item.id);
                  NotificationDetailBottomSheet.show(
                    context,
                    item: item,
                    interactiveTitle: item.title,
                    interactiveDescription: item.description,
                    onDelete: () {
                      ref.read(notificationsProvider.notifier).deleteNotification(item.id);
                    },
                  );
                },
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
    this.onMarkRead,
    this.onDelete,
  });

  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isUnread = notification.isUnread;

    // Resolve icon details based on type
    final (IconData iconData, Color iconColor, Color iconBg, String typeBadge) =
        switch (notification.type) {
      NotificationType.warning => (
          Icons.warning_rounded,
          AppColors.error,
          AppColors.errorContainer.withValues(alpha: 0.6),
          'Peringatan',
        ),
      NotificationType.medication => (
          Icons.alarm_on_rounded,
          AppColors.primary,
          const Color(0xFFE6F2F1),
          'Pengingat',
        ),
      NotificationType.education => (
          Icons.menu_book_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFFFBEB),
          'Edukasi',
        ),
      NotificationType.targetAchieved => (
          Icons.emoji_events_rounded,
          const Color(0xFF059669),
          const Color(0xFFECFDF5),
          'Target',
        ),
    };

    final Color cardBg =
        isUnread ? const Color(0xFFF7FBFB) : AppColors.surfaceContainerLowest;
    final Color borderColor = isUnread
        ? AppColors.primary.withValues(alpha: 0.25)
        : AppColors.outlineVariant.withValues(alpha: 0.35);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : const Color(0x06000000),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12.0),

              // Notification Texts & Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeBadge,
                            style: AppTextStyles.labelSm.copyWith(
                              color: iconColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              notification.timestamp,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 6.0),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                size: 18,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              onSelected: (value) {
                                if (value == 'read') onMarkRead?.call();
                                if (value == 'delete') onDelete?.call();
                              },
                              itemBuilder: (context) => [
                                if (isUnread)
                                  const PopupMenuItem(
                                    value: 'read',
                                    child: Row(
                                      children: [
                                        Icon(Icons.done_rounded, size: 18, color: AppColors.primary),
                                        SizedBox(width: 10),
                                        Text('Tandai dibaca', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                      SizedBox(width: 10),
                                      Text('Hapus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      notification.title,
                      style: AppTextStyles.poppinsHeadline.copyWith(
                        fontSize: 14.5,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      notification.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12.5,
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
      ),
    );
  }
}
