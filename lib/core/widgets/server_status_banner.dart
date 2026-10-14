import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/server_status_notifier.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Non-blocking, contextual status banner displayed when the app is offline
/// or when backend server API is unreachable/down.
class ServerStatusBanner extends ConsumerWidget {
  const ServerStatusBanner({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverStatusProvider);

    if (status.isOnline) {
      return const SizedBox.shrink();
    }

    final isOffline = status.isOffline;
    final backgroundColor = isOffline
        ? const Color(0xFF424242)
        : const Color(0xFFD97706); // Amber/Orange for server outage
    final icon = isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded;
    final title = isOffline
        ? 'Mode Offline'
        : 'Server Gangguan';
    final subtitle = status.message ??
        (isOffline
            ? 'Tidak ada koneksi internet. Bekerja dengan data lokal.'
            : 'Layanan sedang gangguan. Menampilkan data tersimpan.');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: subtitle),
                ],
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.xs),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 2),
                    Text(
                      'Coba',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
