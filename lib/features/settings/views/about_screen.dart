import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// About Screen displaying application version, vision, developers, and copyright.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tentang DIBA',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // Logo & App Name Header
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Diabetes Behaviour & Adherence Application',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Versi 1.0.0 (Build 2026)',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // About Description Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Tentang Aplikasi',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Aplikasi DIBA (Diabetes Behaviour & Adherence Application) dirancang khusus untuk memfasilitasi perawatan, kepatuhan, dan edukasi mandiri penderita diabetes melitus tipe 2 di Provinsi Aceh.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Aplikasi ini mencakup pemantauan gula darah, kalkulasi kalori harian, edukasi kesehatan terintegrasi, dan kuesioner evaluasi mandiri.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Development Team Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_outlined,
                            color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        Text(
                          'Tim Pengembang',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _TeamMemberRow(
                      name: 'Tim Penelitian DIBA Aceh',
                      role: 'Konseptor & Pakar Klinis Diabetes',
                    ),
                    const Divider(height: 20),
                    const _TeamMemberRow(
                      name: 'Universitas Syiah Kuala',
                      role: 'Mitra Riset & Institusi Akademik',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Copyright Footer
              Text(
                '© 2026 DIBA Project. Hak Cipta Dilindungi.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.outline,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          role,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
