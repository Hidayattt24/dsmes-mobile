import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/questionnaire_repository.dart';
import '../models/questionnaire_detail_model.dart';
import '../models/quiz_attempt_model.dart';
import '../viewmodels/questionnaire_notifier.dart';
import '../widgets/questionnaire_skeleton.dart';
import 'questionnaire_detail_screen.dart';
import 'questionnaire_review_screen.dart';

class QuestionnaireScreen extends ConsumerWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preTestHistoryAsync = ref.watch(preTestHistoryProvider);
    final postTestsAsync =
        ref.watch(patientQuestionnaireListProvider('POST_TEST'));
    final historyAsync = ref.watch(allQuestionnaireHistoryProvider);

    Future<void> handleRefresh() async {
      ref.invalidate(patientQuestionnaireListProvider('POST_TEST'));
      ref.invalidate(preTestHistoryProvider);
      ref.invalidate(allQuestionnaireHistoryProvider);
      ref.invalidate(activePreTestProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: handleRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // ── Header Title ─────────────────────────────────────────────
              Text(
                'Kuesioner DSMES',
                style: AppTextStyles.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Evaluasi dan ukur pemahaman Anda tentang pengelolaan Diabetes.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 1. Pre-Test Section (Green Accent) ────────────────────────
              const _SectionHeader(
                title: 'Pre-Test Evaluasi',
                subtitle: 'Wajib diisi 1x saat pertama kali menggunakan aplikasi',
              ),
              const SizedBox(height: AppSpacing.sm),
              preTestHistoryAsync.when(
                loading: () => const _SkeletonCard(height: 140),
                error: (_, __) => const SizedBox.shrink(),
                data: (history) => _PreTestSection(history: history),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 2. Post-Test Edukasi Section (Primary Color: AppColors.primary) ──
              const _SectionHeader(
                title: 'Post-Test Edukasi',
                subtitle: 'Dapat dikerjakan & diulang kapan saja setelah membaca materi',
              ),
              const SizedBox(height: AppSpacing.sm),
              postTestsAsync.when(
                loading: () => const _SkeletonCard(height: 120),
                error: (err, _) => _ErrorCard(
                  message: 'Gagal memuat modul Post-Test',
                  onRetry: () => ref.refresh(
                    patientQuestionnaireListProvider('POST_TEST'),
                  ),
                ),
                data: (result) => _PostTestListSection(items: result.items),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 3. Riwayat Kuesioner Section (Grouped by Module) ─────────
              const _SectionHeader(
                title: 'Riwayat Kuesioner',
                subtitle: 'Diklasifikasikan per modul kuesioner',
              ),
              const SizedBox(height: AppSpacing.sm),
              historyAsync.when(
                loading: () => const _SkeletonCard(height: 100),
                error: (err, _) => _ErrorCard(
                  message: 'Gagal memuat riwayat',
                  onRetry: () =>
                      ref.read(allQuestionnaireHistoryProvider.notifier).refresh(),
                ),
                data: (history) => _GroupedHistorySection(history: history),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

// ── Section Header Widget ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMd.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(
            fontSize: 12,
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}

// ── Pre-Test Section Card ─────────────────────────────────────────────────────

class _PreTestSection extends ConsumerWidget {
  const _PreTestSection({required this.history});

  final List<MyHistoryItemModel> history;

  static const Color greenPrimary = Color(0xFF006C4C);
  static const Color greenBg = Color(0xFFE8F5E9);
  static const Color greenBorder = Color(0xFFA5D6A7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool completed = history.isNotEmpty;
    final item = completed ? history.first : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: completed ? greenBg : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed ? greenBorder : AppColors.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: completed
                      ? greenPrimary.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed
                      ? Icons.task_alt_rounded
                      : Icons.assignment_rounded,
                  size: 24,
                  color: completed ? greenPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pre-Test Pengetahuan',
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      completed
                          ? 'Sudah Diselesaikan (1x)'
                          : 'Belum Diisi · Wajib Sebelum Memulai',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 13,
                        color: completed ? greenPrimary : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (completed && item != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: greenPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Skor: ${item.score}',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                    ),
                  ),
                ),
            ],
          ),

          if (completed && item != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: greenPrimary,
                  side: const BorderSide(color: greenPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuestionnaireReviewScreen(
                        questionnaireId: item.questionnaireId,
                        quizTitle: item.questionnaireTitle,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                label: Text(
                  'Lihat Hasil Jawaban',
                  style: AppTextStyles.poppinsButton.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: greenPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Post-Test List Section ────────────────────────────────────────────────────

class _PostTestListSection extends StatelessWidget {
  const _PostTestListSection({required this.items});

  final List<PatientQuestionnaireItemModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada kuesioner Post-Test yang tersedia.',
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final item in items) ...[
          _PostTestCard(item: item),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

// ── Post-Test Card (Opens Instructions Screen First) ─────────────────────────

class _PostTestCard extends ConsumerWidget {
  const _PostTestCard({required this.item});

  final PatientQuestionnaireItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCompleted = item.isCompleted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary,
          width: isCompleted ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.questionCount} Soal${item.educationTitle != null ? " · ${item.educationTitle}" : ""}',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCompleted && item.score != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Skor: ${item.score}',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.description,
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Opens Instructions Screen First before starting questions
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final detail = await ref
                    .read(questionnaireRepositoryProvider)
                    .getQuestionnaireById(item.id);
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuestionnaireDetailScreen(
                        questionnaire: detail,
                      ),
                    ),
                  ).then((_) {
                    ref.invalidate(patientQuestionnaireListProvider('POST_TEST'));
                    ref.invalidate(preTestHistoryProvider);
                    ref.invalidate(allQuestionnaireHistoryProvider);
                  });
                }
              },
              icon: Icon(
                isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                isCompleted ? 'Kerjakan Ulang Post-Test' : 'Mulai Post-Test',
                style: AppTextStyles.poppinsButton.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grouped History Section (Grouped by Questionnaire Module) ────────────────

class _GroupedHistorySection extends StatelessWidget {
  const _GroupedHistorySection({required this.history});

  final List<MyHistoryItemModel> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_toggle_off_rounded,
                color: AppColors.outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada riwayat pengerjaan kuesioner.',
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group history items by questionnaireId
    final Map<String, List<MyHistoryItemModel>> grouped = {};
    for (final item in history) {
      grouped.putIfAbsent(item.questionnaireId, () => []).add(item);
    }

    return Column(
      children: [
        for (final entry in grouped.entries) ...[
          _ModuleHistoryCard(attempts: entry.value),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

// ── Module History Card (Grouped attempts for a single questionnaire module) ──

class _ModuleHistoryCard extends StatefulWidget {
  const _ModuleHistoryCard({required this.attempts});

  final List<MyHistoryItemModel> attempts;

  @override
  State<_ModuleHistoryCard> createState() => _ModuleHistoryCardState();
}

class _ModuleHistoryCardState extends State<_ModuleHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final latest = widget.attempts.first;
    final total = widget.attempts.length;
    final highestScore =
        widget.attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: latest.passed
                        ? const Color(0xFFABF4AC)
                        : const Color(0xFFFFDAD6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${latest.score}',
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: latest.passed
                            ? const Color(0xFF07521D)
                            : const Color(0xFF93000A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest.questionnaireTitle,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total $total Percobaan · Skor Tertinggi: $highestScore%',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // Collapsible list of attempt entries
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  for (int i = 0; i < widget.attempts.length; i++) ...[
                    _AttemptSubItemRow(
                      attempt: widget.attempts[i],
                      attemptIndex: widget.attempts.length - i,
                    ),
                    if (i < widget.attempts.length - 1)
                      const Divider(height: 16),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Default single attempt row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terakhir: ${DateFormat('d MMM yyyy', 'id').format(latest.completedAt.toLocal())}',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuestionnaireReviewScreen(
                            questionnaireId: latest.questionnaireId,
                            quizTitle: latest.questionnaireTitle,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Hasil',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sub-item row for grouped attempts ─────────────────────────────────────────

class _AttemptSubItemRow extends StatelessWidget {
  const _AttemptSubItemRow({
    required this.attempt,
    required this.attemptIndex,
  });

  final MyHistoryItemModel attempt;
  final int attemptIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#$attemptIndex',
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skor: ${attempt.score}% (${attempt.passed ? "Lulus" : "Gagal"})',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: attempt.passed
                      ? const Color(0xFF07521D)
                      : const Color(0xFF93000A),
                ),
              ),
              Text(
                DateFormat('d MMM yyyy · HH:mm', 'id')
                    .format(attempt.completedAt.toLocal()),
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: const Size(0, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuestionnaireReviewScreen(
                  questionnaireId: attempt.questionnaireId,
                  quizTitle: attempt.questionnaireTitle,
                ),
              ),
            );
          },
          child: Text(
            'Lihat Hasil',
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Skeleton Loader ───────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ── Error Card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
