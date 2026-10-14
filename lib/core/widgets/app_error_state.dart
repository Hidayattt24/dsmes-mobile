import 'dart:async';
import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Comprehensive fallback and error screen for offline, timeout, or server downtime.
/// Features a cooldown timer on retry to prevent request hammering.
class AppErrorState extends StatefulWidget {
  const AppErrorState({
    super.key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.showEmergencyContact = true,
  });

  final Object? error;
  final String? title;
  final String? message;
  final FutureOr<void> Function()? onRetry;
  final bool showEmergencyContact;

  @override
  State<AppErrorState> createState() => _AppErrorStateState();
}

class _AppErrorStateState extends State<AppErrorState> {
  int _cooldownRemaining = 0;
  Timer? _cooldownTimer;
  bool _isRetrying = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _triggerRetry() async {
    if (_cooldownRemaining > 0 || _isRetrying || widget.onRetry == null) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      await widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _cooldownRemaining = 5; // 5-second cooldown
        });

        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            if (_cooldownRemaining > 1) {
              _cooldownRemaining--;
            } else {
              _cooldownRemaining = 0;
              timer.cancel();
            }
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    bool isServerDown = false;
    bool isOffline = false;

    if (error is ApiException) {
      if (error.statusCode != null && error.statusCode! >= 500) {
        isServerDown = true;
      } else if (error.message.toLowerCase().contains('koneksi') ||
          error.message.toLowerCase().contains('internet')) {
        isOffline = true;
      }
    }

    final resolvedTitle = widget.title ??
        (isServerDown
            ? 'Server Sedang Dalam Pemeliharaan'
            : isOffline
                ? 'Tidak Ada Koneksi Internet'
                : 'Gagal Memuat Data');

    final resolvedMessage = widget.message ??
        (error is ApiException
            ? error.message
            : isServerDown
                ? 'Sistem kami sedang mengalami gangguan sementara. Silakan coba beberapa saat lagi.'
                : isOffline
                    ? 'Periksa jaringan Wi-Fi atau data seluler Anda, lalu coba lagi.'
                    : 'Terjadi kendala saat memproses permintaan Anda.');

    final icon = isServerDown
        ? Icons.cloud_off_rounded
        : isOffline
            ? Icons.wifi_off_rounded
            : Icons.error_outline_rounded;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisAlignment: MainTestAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isServerDown
                    ? const Color(0xFFFEF3C7) // Amber tint
                    : AppColors.errorContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 54,
                color: isServerDown ? const Color(0xFFD97706) : AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              resolvedTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              resolvedMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (widget.onRetry != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cooldownRemaining > 0 || _isRetrying
                      ? null
                      : _triggerRetry,
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    _cooldownRemaining > 0
                        ? 'Tunggu ($_cooldownRemaining detik)'
                        : 'Coba Lagi',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (widget.showEmergencyContact) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perlu Bantuan Medis Segera?',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Hubungi Puskesmas atau faskes terdekat Anda.',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Temporary alias to avoid Flutter analyzer enum naming collision if any
typedef MainTestAxisAlignment = MainAxisAlignment;
