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

/// Security & Privacy Settings Screen prototype.
class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricEnabled = true;
  bool _healthSyncEnabled = true;
  bool _analyticsEnabled = false;

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text(
            'Ubah Kata Sandi',
            style: AppTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi Saat Ini',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Kata sandi saat ini wajib diisi'
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    prefixIcon: Icon(Icons.key_rounded),
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    prefixIcon: Icon(Icons.check_circle_outline_rounded),
                  ),
                  validator: (val) => val != newPassController.text
                      ? 'Konfirmasi kata sandi tidak cocok'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            AppButton(
              label: 'Simpan',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  AppSnackbar.showSuccess(
                    context,
                    'Kata sandi berhasil diperbarui.',
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
          'Keamanan & Privasi',
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
              // Security Section
              _SectionHeader(title: 'Keamanan Akun'),
              const SizedBox(height: 8),
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
                    ListTile(
                      leading: const Icon(Icons.key_rounded,
                          color: AppColors.primary),
                      title: const Text('Ubah Kata Sandi'),
                      subtitle: const Text('Perbarui kata sandi secara berkala'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint_rounded,
                          color: AppColors.primary),
                      title: const Text('Login Biometrik (Face ID / Fingerprint)'),
                      subtitle: const Text('Masuk cepat dengan sensor biometrik'),
                      value: _biometricEnabled,
                      onChanged: (val) {
                        setState(() => _biometricEnabled = val);
                        AppSnackbar.showInfo(
                          context,
                          val
                              ? 'Biometrik diaktifkan.'
                              : 'Biometrik dinonaktifkan.',
                        );
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Privacy Section
              _SectionHeader(title: 'Privasi & Data'),
              const SizedBox(height: 8),
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
                    SwitchListTile(
                      secondary: const Icon(Icons.sync_rounded,
                          color: AppColors.secondary),
                      title: const Text('Sinkronisasi Data Kesehatan'),
                      subtitle: const Text('Integrasi catatan kesehatan lokal'),
                      value: _healthSyncEnabled,
                      onChanged: (val) =>
                          setState(() => _healthSyncEnabled = val),
                      activeColor: AppColors.primary,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.insights_rounded,
                          color: AppColors.tertiary),
                      title: const Text('Izin Analisis Aplikasi'),
                      subtitle:
                          const Text('Kirim laporan anonim untuk pengembangan'),
                      value: _analyticsEnabled,
                      onChanged: (val) =>
                          setState(() => _analyticsEnabled = val),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Legal & Legal documents section
              _SectionHeader(title: 'Dokumen Hukum'),
              const SizedBox(height: 8),
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
                    ListTile(
                      leading: const Icon(Icons.policy_outlined,
                          color: AppColors.outline),
                      title: const Text('Kebijakan Privasi'),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () {
                        AppSnackbar.showInfo(
                          context,
                          'Menampilkan dokumen Kebijakan Privasi.',
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.gavel_outlined,
                          color: AppColors.outline),
                      title: const Text('Syarat & Ketentuan Penggunaan'),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () {
                        AppSnackbar.showInfo(
                          context,
                          'Menampilkan dokumen Syarat & Ketentuan.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Danger Zone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        AppSnackbar.showError(
                          context,
                          'Hapus akun adalah tindakan permanen.',
                        );
                      },
                      icon: const Icon(Icons.delete_forever_rounded,
                          color: AppColors.error),
                      label: Text(
                        'Hapus Akun Permanen',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.labelLg.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
