import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/chat_session.dart';
import '../viewmodels/ai_chat_notifier.dart';

/// Shows the modern Chat History modal bottom sheet
void showChatHistorySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ChatHistorySheet(),
  );
}

class ChatHistorySheet extends ConsumerWidget {
  const ChatHistorySheet({super.key});

  String _formatSessionTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes == 0 ? 1 : difference.inMinutes}m lalu';
    } else if (difference.inHours < 24 && dt.day == now.day) {
      final hourStr = dt.hour.toString().padLeft(2, '0');
      final minStr = dt.minute.toString().padLeft(2, '0');
      return 'Hari ini $hourStr:$minStr';
    } else if (difference.inDays < 2) {
      return 'Kemarin';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  void _confirmDeleteSession(
    BuildContext context,
    WidgetRef ref,
    ChatSession session,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Hapus Sesi Percakapan?',
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${session.title}" dari riwayat?',
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(aiChatProvider.notifier).deleteSession(session.id);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Hapus Seluruh Riwayat?',
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            content: Text(
              'Semua sesi percakapan dengan Asisten AI akan dihapus secara permanen.',
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  ref.read(aiChatProvider.notifier).clearAllHistory();
                },
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);
    final sessions = chatState.sessions;
    final activeId = chatState.activeSessionId;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Percakapan',
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sessions.length} Sesi Terdiskusikan',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.onSurfaceVariant,
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Centered "+ Sesi Baru" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Sesi Baru',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  ref.read(aiChatProvider.notifier).startNewSession();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Session List
          Expanded(
            child:
                sessions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history_toggle_off_rounded,
                            size: 48,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada riwayat percakapan',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      itemCount: sessions.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isActive = session.id == activeId;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(aiChatProvider.notifier)
                                  .selectSession(session.id);
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? AppColors.primaryContainer.withValues(
                                          alpha: 0.35,
                                        )
                                        : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isActive
                                          ? AppColors.primary
                                          : AppColors.outlineVariant.withValues(
                                            alpha: 0.5,
                                          ),
                                  width: isActive ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isActive
                                              ? AppColors.primary
                                              : AppColors.surfaceContainerHigh,
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 18,
                                      color:
                                          isActive
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                session.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.labelLg
                                                    .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          isActive
                                                              ? FontWeight.bold
                                                              : FontWeight.w600,
                                                      color:
                                                          AppColors.onSurface,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatSessionTime(
                                                session.updatedAt,
                                              ),
                                              style: AppTextStyles.bodyMd
                                                  .copyWith(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors
                                                            .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          session.lastMessageText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodyMd.copyWith(
                                            fontSize: 12,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                    ),
                                    color: AppColors.error.withValues(
                                      alpha: 0.8,
                                    ),
                                    onPressed:
                                        () => _confirmDeleteSession(
                                          context,
                                          ref,
                                          session,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // Footer - Hapus Semua Riwayat
          if (sessions.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded, size: 18),
                    label: const Text(
                      'Hapus Seluruh Riwayat Percakapan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _confirmClearAll(context, ref),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
