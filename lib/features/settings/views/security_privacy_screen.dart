import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

class SecurityPrivacyScreen extends ConsumerStatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  ConsumerState<SecurityPrivacyScreen> createState() =>
      _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends ConsumerState<SecurityPrivacyScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _healthSyncEnabled = true;
  bool _analyticsEnabled = false;
  bool _isChangingPassword = false;
  bool _isTogglingBiometric = false;

  @override
  void initState() {
    super.initState();
    _initBiometricState();
  }

  Future<void> _initBiometricState() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final stored = await storage.read(key: AppConstants.keyBiometricEnabled);
      final available = await _localAuth.canCheckBiometrics;
      final enrolled = await _localAuth.isDeviceSupported();

      if (mounted) {
        setState(() {
          _biometricAvailable = available && enrolled;
          _biometricEnabled = stored == 'true' && _biometricAvailable;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _biometricEnabled = false;
        });
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (_isTogglingBiometric) return;

    if (enable) {
      if (!_biometricAvailable) {
        if (mounted) {
          AppSnackbar.showError(
            context,
            'Perangkat tidak mendukung biometrik atau belum terdaftar. '
            'Daftarkan sidik jari / Face ID di pengaturan perangkat terlebih dahulu.',
          );
        }
        return;
      }

      setState(() => _isTogglingBiometric = true);
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason:
              'Verifikasi identitas Anda untuk mengaktifkan login biometrik.',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated && mounted) {
          final storage = ref.read(secureStorageProvider);
          await storage.write(
            key: AppConstants.keyBiometricEnabled,
            value: 'true',
          );
          setState(() => _biometricEnabled = true);
          AppSnackbar.showSuccess(context, 'Login biometrik diaktifkan.');
        } else if (mounted) {
          AppSnackbar.showError(
            context,
            'Verifikasi biometrik gagal. Silakan coba lagi.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, e.toString());
        }
      } finally {
        if (mounted) setState(() => _isTogglingBiometric = false);
      }
    } else {
      try {
        final storage = ref.read(secureStorageProvider);
        await storage.delete(key: AppConstants.keyBiometricEnabled);
        if (mounted) {
          setState(() => _biometricEnabled = false);
          AppSnackbar.showInfo(context, 'Login biometrik dinonaktifkan.');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, e.toString());
        }
      }
    }
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
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
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: (MediaQuery.sizeOf(ctx).height -
                      MediaQuery.viewInsetsOf(ctx).bottom -
                      220)
                  .clamp(160.0, 520.0),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
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
                      validator:
                          (val) =>
                              val == null || val.isEmpty
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
                      validator:
                          (val) =>
                              val == null || val.length < 6
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
                      validator:
                          (val) =>
                              val != newPassController.text
                                  ? 'Konfirmasi kata sandi tidak cocok'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            AppButton(
              label: _isChangingPassword ? 'Menyimpan...' : 'Simpan',
              onPressed:
                  _isChangingPassword
                      ? null
                      : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => _isChangingPassword = true);
                        try {
                          final authRepo = ref.read(authRepositoryProvider);
                          await authRepo.changePassword(
                            currentPassword: oldPassController.text,
                            newPassword: newPassController.text,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            AppSnackbar.showSuccess(
                              context,
                              'Kata sandi berhasil diperbarui.',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            AppSnackbar.showError(context, e.toString());
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isChangingPassword = false);
                          }
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.onSurface,
          ),
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
                      leading: const Icon(
                        Icons.key_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Ubah Kata Sandi'),
                      subtitle: const Text(
                        'Perbarui kata sandi secara berkala',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary:
                          _isTogglingBiometric
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(
                                Icons.fingerprint_rounded,
                                color: AppColors.primary,
                              ),
                      title: const Text(
                        'Login Biometrik (Face ID / Fingerprint)',
                      ),
                      subtitle: Text(
                        _biometricAvailable
                            ? 'Masuk cepat dengan sensor biometrik'
                            : 'Biometrik tidak tersedia di perangkat ini',
                      ),
                      value: _biometricEnabled,
                      onChanged: _biometricAvailable ? _toggleBiometric : null,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

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
                      secondary: const Icon(
                        Icons.sync_rounded,
                        color: AppColors.secondary,
                      ),
                      title: const Text('Sinkronisasi Data Kesehatan'),
                      subtitle: const Text('Integrasi catatan kesehatan lokal'),
                      value: _healthSyncEnabled,
                      onChanged:
                          (val) => setState(() => _healthSyncEnabled = val),
                      activeColor: AppColors.primary,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(
                        Icons.insights_rounded,
                        color: AppColors.tertiary,
                      ),
                      title: const Text('Izin Analisis Aplikasi'),
                      subtitle: const Text(
                        'Kirim laporan anonim untuk pengembangan',
                      ),
                      value: _analyticsEnabled,
                      onChanged:
                          (val) => setState(() => _analyticsEnabled = val),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

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
                      leading: const Icon(
                        Icons.policy_outlined,
                        color: AppColors.outline,
                      ),
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
                      leading: const Icon(
                        Icons.gavel_outlined,
                        color: AppColors.outline,
                      ),
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
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                      ),
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
