import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/settings_mock_data.dart';

/// Help Center Screen featuring FAQ list, Contact Support, and Feedback modal.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _searchQuery = '';
  final _feedbackController = TextEditingController();

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text(
            'Kirim Masukan',
            style: AppTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tuliskan saran atau kendala yang Anda alami untuk perbaikan aplikasi DSMES Aceh.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan pesan Anda di sini...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            AppButton(
              label: 'Kirim',
              onPressed: () {
                if (_feedbackController.text.trim().isNotEmpty) {
                  _feedbackController.clear();
                  Navigator.pop(context);
                  AppSnackbar.showSuccess(
                    context,
                    'Terima kasih! Masukan Anda telah terkirim.',
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = SettingsMockData.faqList.where((faq) {
      final (q, a) = faq;
      return q.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
          'Pusat Bantuan',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan atau bantuan...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Contact Support Card Options
              Row(
                children: [
                  Expanded(
                    child: _SupportActionCard(
                      icon: Icons.chat_rounded,
                      iconColor: AppColors.secondary,
                      title: 'Hubungi WhatsApp',
                      subtitle: 'Dukungan langsung',
                      onTap: () {
                        AppSnackbar.showInfo(
                          context,
                          'Menghubungkan ke Tim Layanan WhatsApp DSMES.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SupportActionCard(
                      icon: Icons.feedback_outlined,
                      iconColor: AppColors.tertiary,
                      title: 'Kirim Masukan',
                      subtitle: 'Saran & kritik',
                      onTap: _showFeedbackDialog,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // FAQ Section Title
              Text(
                'Pertanyaan Sering Diajukan (FAQ)',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Accordion FAQ List Container Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  children: [
                    if (filteredFaqs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'Tidak ada pertanyaan yang sesuai pencarian.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    else
                      for (int i = 0; i < filteredFaqs.length; i++) ...[
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.help_outline_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              filteredFaqs[i].$1,
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 16),
                                child: Text(
                                  filteredFaqs[i].$2,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < filteredFaqs.length - 1)
                          const Divider(height: 1),
                      ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Link to About Screen Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary),
                  title: const Text('Tentang Aplikasi DSMES Aceh'),
                  subtitle: const Text('Versi, pengembang, & informasi lisensi'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(RouteNames.about),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportActionCard extends StatelessWidget {
  const _SupportActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
