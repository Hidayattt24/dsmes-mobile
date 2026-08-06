import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../viewmodels/questionnaire_notifier.dart';
import '../widgets/questionnaire_empty_state.dart';
import '../widgets/questionnaire_history_section.dart';
import '../widgets/questionnaire_list_card.dart';
import '../widgets/questionnaire_section_header.dart';
import '../widgets/questionnaire_skeleton.dart';
import 'survey_card.dart';
import '../viewmodels/survey_notifier.dart';

/// Questionnaire tab.
class QuestionnaireScreen extends ConsumerWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(questionnaireListProvider);
    final historyAsync = ref.watch(allQuestionnaireHistoryProvider);

    Future<void> handleRefresh() async {
      ref.invalidate(allQuestionnaireHistoryProvider);
      ref.invalidate(preTestHistoryProvider);
      ref.invalidate(activeSurveyProvider);
      ref.invalidate(activeSurveysProvider);
      await ref.read(questionnaireListProvider.notifier).refresh();
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

                // ── Header Title ─────────────────────────────────────────
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

                // ── Unified Questionnaire List ───────────────────────────
                listAsync.when(
                  loading: () => const QuestionnaireSkeleton(),
                  error: (err, _) => _ErrorCard(
                    message: 'Gagal memuat kuesioner',
                    onRetry: () =>
                        ref.read(questionnaireListProvider.notifier).refresh(),
                  ),
                  data: (result) {
                    if (result.items.isEmpty) {
                      return const QuestionnaireEmptyState();
                    }
                    return Column(
                      children: [
                        for (int i = 0; i < result.items.length; i++) ...[
                          QuestionnaireListCard(item: result.items[i]),
                          if (i < result.items.length - 1)
                            const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Survey Penelitian Section ────────────────────────────
                const QuestionnaireSectionHeader(
                  title: 'Survey Penelitian',
                  subtitle: 'Evaluasi akhir periode penggunaan aplikasi',
                ),
                const SizedBox(height: AppSpacing.sm),
                const SurveyCardSection(),
                const SizedBox(height: AppSpacing.xl),

                // ── Riwayat Kuesioner ────────────────────────────────────
                const QuestionnaireSectionHeader(
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
                  data: (history) =>
                      QuestionnaireHistorySection(history: history),
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
