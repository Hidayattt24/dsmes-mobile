import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/settings_mock_data.dart';
import '../viewmodels/settings_notifier.dart';
import '../widgets/bmi_summary_card.dart';
import '../widgets/body_metric_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// Primary Settings / Profile Screen matching HTML reference design.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(bodyMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            // ── Profile Header Section ───────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            width: 4,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceContainerLowest,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const AppAvatar(
                            imageUrl: SettingsMockData.profileAvatarUrl,
                            radius: 52,
                            initials: 'BS',
                            hasBorder: false,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () =>
                                context.push(RouteNames.personalInformation),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit_rounded,
                                color: AppColors.onPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    SettingsMockData.userName,
                    style: AppTextStyles.headlineLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    SettingsMockData.userRole,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Stats Bento Grid (Avg Blood Sugar & Calorie Target) ─────────
            BmiSummaryCard(metrics: metrics),

            const SizedBox(height: AppSpacing.lg),

            // ── Body Metric Summary Card ─────────────────────────────────────
            BodyMetricCard(
              metrics: metrics,
              onEditTap: () => context.push(RouteNames.editBodyMetrics),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Navigation Menu Section ─────────────────────────────────────
            SettingsSection(
              tiles: [
                SettingsTile(
                  icon: Icons.person_rounded,
                  title: 'Informasi Pribadi',
                  subtitle: 'Data diri dan medis',
                  onTap: () => context.push(RouteNames.personalInformation),
                ),
                SettingsTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Update Body Metrics',
                  subtitle: 'Tinggi, berat badan & aktivitas',
                  onTap: () => context.push(RouteNames.editBodyMetrics),
                ),
                SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Pengaturan Pengingat',
                  subtitle: 'Obat, cek gula & aktivitas',
                  onTap: () => context.push(RouteNames.reminderSettings),
                ),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Keamanan & Privasi',
                  subtitle: 'Kata sandi dan izin',
                  onTap: () => context.push(RouteNames.securityPrivacy),
                ),
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Pusat Bantuan',
                  subtitle: 'FAQ dan kontak dukungan',
                  onTap: () => context.push(RouteNames.helpCenter),
                ),
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang DSMES Aceh',
                  subtitle: 'Versi, informasi tim & lisensi',
                  onTap: () => context.push(RouteNames.about),
                ),
                SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Keluar Akun',
                  subtitle: 'Sesi saat ini akan berakhir',
                  isDestructive: true,
                  onTap: () {
                    context.go(RouteNames.login);
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
