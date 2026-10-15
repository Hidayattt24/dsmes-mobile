import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// About Screen displaying application version, vision, medical references, dataset credits, and legal links.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.onSurface,
          ),
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
              const SizedBox(height: AppSpacing.sm),

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
                        horizontal: 12,
                        vertical: 4,
                      ),
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

              const SizedBox(height: AppSpacing.lg),

              // About Description Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                        ),
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

              const SizedBox(height: AppSpacing.md),

              // Medical Guidelines Reference Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Standar & Pedoman Klinis',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Klasifikasi kadar glukosa dan rekomendasi medis merujuk pada standar otoritatif resmi:',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Nasional: PERKENI
                    _buildReferenceTile(
                      badge: 'Nasional (Indonesia)',
                      organization: 'PB PERKENI',
                      title:
                          'Pedoman Pemantauan Glukosa Darah Mandiri (PGDM 2021)',
                      description:
                          'Acuan rentang target glukosa darah puasa, sebelum makan, dan sewaktu.',
                      url:
                          'https://pbperkeni.or.id/wp-content/uploads/2021/11/22-10-21-Website-Pedoman-Pemantauan-Glukosa-Darah-Mandiri-Ebook.pdf',
                    ),

                    const Divider(height: 24),

                    // Internasional: ADA
                    _buildReferenceTile(
                      badge: 'Internasional',
                      organization: 'ADA (American Diabetes Association)',
                      title: 'Standards of Care in Diabetes',
                      description:
                          'Kriteria Diagnosis & Pengujian Glukosa Darah terkini.',
                      url: 'https://diabetes.org/about-diabetes/diagnosis',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Dataset & Open Source Credits Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.dataset_outlined,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kredit Data & Tipografi',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Dataset Gizi Kaggle
                    InkWell(
                      onTap:
                          () => _launchExternalUrl(
                            'https://www.kaggle.com/datasets/fritze/informasi-nilai-gizi-indonesia',
                          ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Informasi Nilai Gizi Indonesia',
                                          style: AppTextStyles.labelMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dataset nilai gizi makanan Indonesia di Kaggle oleh Fritz E.',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Font Credits
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.font_download_outlined,
                              size: 20,
                              color: AppColors.tertiary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Poppins & Plus Jakarta Sans',
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Didistribusikan melalui Google Fonts di bawah lisensi SIL Open Font License.',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Legal Documents Navigation Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.policy_outlined,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ketentuan & Privasi',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Kebijakan Privasi',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Pengelolaan data pribadi & penelitian (05-Okt-2026)',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(RouteNames.privacyPolicy),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.gavel_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Syarat & Ketentuan',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Batasan tanggung jawab & aturan penggunaan DIBA',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(RouteNames.termsConditions),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Development Team Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          color: AppColors.tertiary,
                        ),
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

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }

  Widget _buildReferenceTile({
    required String badge,
    required String organization,
    required String title,
    required String description,
    required String url,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: AppTextStyles.labelMd.copyWith(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                organization,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodyLg.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _launchExternalUrl(url),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Lihat Dokumen Pedoman',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
