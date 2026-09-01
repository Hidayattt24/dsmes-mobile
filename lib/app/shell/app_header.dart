import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_icon_button.dart';

/// Application-level shared top header bar.
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
    this.showGreeting = true,
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
  final bool showGreeting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final actionSize = isNarrow ? 36.0 : 40.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showLogo)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.health_and_safety,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            'DSMES Aceh',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineMd.copyWith(
                              color: AppColors.primary,
                              fontSize: isNarrow ? 17 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                AppIconButton(
                  icon: Icons.calendar_today_rounded,
                  onTap: onCalendarTap,
                  tooltip: 'Kalender',
                  size: actionSize,
                ),
                const SizedBox(width: AppSpacing.xxs),
                AppIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationTap,
                  badgeCount: notificationCount,
                  tooltip: 'Notifikasi',
                  size: actionSize,
                ),
                const SizedBox(width: AppSpacing.xs),
                AppAvatar(
                  imageUrl: avatarUrl,
                  initials:
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  onTap: onProfileTap,
                  radius: isNarrow ? 16 : 18,
                ),
              ],
            ),
            if (showGreeting) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$greetingText, $userName',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.poppinsHeadline.copyWith(
                  fontSize: isNarrow ? 21 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
