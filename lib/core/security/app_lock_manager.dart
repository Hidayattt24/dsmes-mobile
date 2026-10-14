import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_constants.dart';
import '../network/auth_interceptor.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppLockState {
  final bool isLocked;
  final bool isAuthenticating;

  const AppLockState({
    this.isLocked = false,
    this.isAuthenticating = false,
  });

  AppLockState copyWith({
    bool? isLocked,
    bool? isAuthenticating,
  }) {
    return AppLockState(
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }
}

class AppLockNotifier extends StateNotifier<AppLockState> {
  final Ref _ref;
  final LocalAuthentication _localAuth;
  DateTime? _pausedAt;

  // 5 minutes inactivity timeout
  static const Duration inactivityTimeout = Duration(minutes: 5);

  AppLockNotifier(this._ref, [LocalAuthentication? localAuth])
      : _localAuth = localAuth ?? LocalAuthentication(),
        super(const AppLockState());

  void onAppPaused() {
    _pausedAt = DateTime.now();
  }

  Future<void> onAppResumed() async {
    final paused = _pausedAt;
    _pausedAt = null;

    if (paused == null) return;

    final elapsed = DateTime.now().difference(paused);
    if (elapsed >= inactivityTimeout) {
      final storage = _ref.read(secureStorageProvider);
      final biometricEnabled =
          await storage.read(key: AppConstants.keyBiometricEnabled);

      if (biometricEnabled == 'true') {
        state = state.copyWith(isLocked: true);
        await unlockWithBiometrics();
      }
    }
  }

  Future<bool> unlockWithBiometrics() async {
    if (state.isAuthenticating) return false;

    state = state.copyWith(isAuthenticating: true);
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck && !isSupported) {
        state = state.copyWith(isLocked: false, isAuthenticating: false);
        return true;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason:
            'Verifikasi identitas Anda untuk mengakses data medis DIBA.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        state = state.copyWith(isLocked: false, isAuthenticating: false);
        return true;
      }
    } catch (_) {
      // Biometrics failed or canceled
    } finally {
      if (mounted) {
        state = state.copyWith(isAuthenticating: false);
      }
    }
    return false;
  }

  void unlockManually() {
    state = state.copyWith(isLocked: false);
  }
}

final appLockProvider =
    StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  return AppLockNotifier(ref);
});

/// Overlay screen displayed when app is locked due to inactivity.
class AppLockScreen extends ConsumerWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Aplikasi Terkunci',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sesi Anda dikunci untuk melindungi keamanan data kesehatan pribadi.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: lockState.isAuthenticating
                        ? null
                        : () => ref
                            .read(appLockProvider.notifier)
                            .unlockWithBiometrics(),
                    icon: lockState.isAuthenticating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.fingerprint_rounded),
                    label: const Text('Buka Kunci Biometrik'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
