import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../viewmodels/settings_notifier.dart';
import '../widgets/bmi_summary_card.dart';
import '../widgets/body_metric_card.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../home/viewmodels/home_dashboard_notifier.dart';
import '../../ai_chat/viewmodels/ai_chat_notifier.dart';
import '../../questionnaire/viewmodels/questionnaire_notifier.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _userName = '';
  String _avatarUrl = '';
  double? _averageBloodSugar;

  @override
  void initState() {
    super.initState();
    _fetchLatestProfile();
  }

  Future<void> _fetchLatestProfile() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final profile = await authRepo.getPatientProfile();
      final h = (profile['height_cm'] as num?)?.toDouble();
      final w = (profile['weight_kg'] as num?)?.toDouble();
      final act = profile['physical_activity_level'] as String?;
      final target = (profile['daily_calorie_target'] as num?)?.toInt();

      final bmi = (profile['bmi'] as num?)?.toDouble();
      final bmiCategory = profile['bmi_category'] as String?;
      final recommendations = profile['recommendations'] as Map<String, dynamic>?;

      if (mounted) {
        _userName = (profile['full_name'] as String?) ?? '';
        _avatarUrl = (profile['profile_photo_url'] as String?) ?? '';
        _averageBloodSugar = (profile['average_blood_sugar'] as num?)?.toDouble();

        if (h != null || w != null) {
          ref.read(bodyMetricsProvider.notifier).updateBodyMetrics(
                heightCm: h ?? 170,
                weightKg: w ?? 65,
                activityLevel: act ?? 'Ringan',
                calculatedTdee: target,
                bmiVal: bmi,
                bmiCatVal: bmiCategory,
                recommendations: recommendations,
              );
        }
        ref.invalidate(homeDashboardProvider);
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar? Sesi saat ini akan berakhir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
      ref.read(bodyMetricsProvider.notifier).reset();
      ref.read(aiChatProvider.notifier).reset();
      ref.invalidate(preTestHistoryProvider);
      if (mounted) context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(bodyMetricsProvider);
    final initials = _userName.isNotEmpty
        ? _userName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

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
                          child: AppAvatar(
                            imageUrl: _avatarUrl,
                            radius: 52,
                            initials: initials,
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
                    _userName,
                    style: AppTextStyles.headlineLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            BmiSummaryCard(metrics: metrics, averageBloodSugar: _averageBloodSugar),

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
                  onTap: () async {
                    await context.push(RouteNames.personalInformation);
                    _fetchLatestProfile();
                  },
                ),
                SettingsTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Update Body Metrics',
                  subtitle: 'Tinggi, berat badan & aktivitas',
                  onTap: () async {
                    await context.push(RouteNames.editBodyMetrics);
                    _fetchLatestProfile();
                  },
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
                  onTap: _logout,
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
