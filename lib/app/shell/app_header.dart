import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_icon_button.dart';

/// Application-level shared top header bar.
///
/// Contains top-level branding ("DSMES Aceh"), Calendar trigger,
/// Notification trigger with unread badge count, Profile Avatar,
/// and contextual greeting/subtitles.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.userName,
    this.greetingText = 'Halo',
    this.subtitle,
    this.avatarUrl,
    this.onCalendarTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 0,
    this.showLogo = true,
  });

  final String userName;
  final String greetingText;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top action bar (Logo + actions)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showLogo)
              Row(
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'DSMES Aceh',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
            Row(
              children: [
                AppIconButton(
                  icon: Icons.calendar_today_rounded,
                  onTap: onCalendarTap,
                  tooltip: 'Kalender',
                ),
                const SizedBox(width: AppSpacing.xxs),
                AppIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationTap,
                  badgeCount: notificationCount,
                  tooltip: 'Notifikasi',
                ),
                const SizedBox(width: AppSpacing.xs),
                AppAvatar(
                  imageUrl: avatarUrl,
                  initials: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  onTap: onProfileTap,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Greeting & Subtitle
        Text(
          '$greetingText, $userName',
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
