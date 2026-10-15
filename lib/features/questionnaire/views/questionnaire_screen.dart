import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../viewmodels/questionnaire_notifier.dart';
import '../models/questionnaire_detail_model.dart';
import '../models/quiz_attempt_model.dart';
import '../../../../data/repositories/questionnaire_repository.dart';
import 'questionnaire_detail_screen.dart';
import 'questionnaire_review_screen.dart';
import '../widgets/questionnaire_empty_state.dart';
import '../widgets/questionnaire_history_section.dart';
import '../widgets/questionnaire_list_card.dart';
import '../widgets/questionnaire_section_header.dart';
import '../widgets/questionnaire_skeleton.dart';
import '../widgets/questionnaire_action_button.dart';
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: handleRefresh,
            color: AppColors.primary,
            child: NestedScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              headerSliverBuilder:
                  (_, __) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          AppSpacing.md,
                          AppSpacing.page,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.md),

                            // ── Header Title ─────────────────────────────────────────
                            Text(
                              'Kuesioner DIBA',
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
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const TabBar(
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(11),
                                  ),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor:
                                    AppColors.onSurfaceVariant,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                tabs: [
                                  Tab(text: 'Aktif'),
                                  Tab(text: 'Riwayat'),
                                  Tab(text: 'Survey'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
              body: TabBarView(
                children: [
                  _ActiveQuestionnaireTab(
                    listAsync: listAsync,
                    historyAsync: historyAsync,
                  ),
                  _HistoryTab(historyAsync: historyAsync),
                  const _SurveyTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveQuestionnaireTab extends ConsumerWidget {
  const _ActiveQuestionnaireTab({
    required this.listAsync,
    required this.historyAsync,
  });

  final AsyncValue<PaginatedQuestionnaireResult> listAsync;
  final AsyncValue<List<MyHistoryItemModel>> historyAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return listAsync.when(
      loading: () => const QuestionnaireSkeleton(),
      error:
          (_, __) => _RetryMessageCard(
            icon: Icons.cloud_off_rounded,
            title: 'Gagal memuat kuesioner',
            message: 'Periksa koneksi internet lalu coba lagi.',
            onRetry:
                () => ref.read(questionnaireListProvider.notifier).refresh(),
          ),
      data: (result) {
        // Backend already filters published questionnaires. Keep all returned
        // items so valid status variants cannot disappear from the UI.
        final active = result.items;
        final application =
            active.where((item) => item.educationId == null).toList();
        final education =
            active.where((item) => item.educationId != null).toList();
        final modules = <String, List<PatientQuestionnaireItemModel>>{};
        for (final item in education) {
          modules.putIfAbsent(item.educationId ?? item.id, () => []).add(item);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            100,
          ),
          children: [
            _SectionLabel(
              title: 'Kuesioner Aplikasi',
              subtitle: 'Evaluasi umum penggunaan dan pengelolaan diabetes.',
            ),
            ..._cards(application),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(
              title: 'Kuesioner Edukasi',
              subtitle: 'Pre-Test dan Post-Test berdasarkan materi edukasi.',
            ),
            for (final items in modules.values) ...[
              _EducationModuleCard(
                items: items,
                history: historyAsync.valueOrNull ?? const [],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (application.isEmpty && education.isEmpty)
              const _DataMessageCard(
                icon: Icons.assignment_outlined,
                title: 'Belum ada kuesioner aktif',
                message: 'Kuesioner yang tersedia akan muncul di sini.',
              ),
          ],
        );
      },
    );
  }

  List<Widget> _cards(List<PatientQuestionnaireItemModel> items) => [
    for (int i = 0; i < items.length; i++) ...[
      QuestionnaireListCard(item: items[i]),
      if (i < items.length - 1) const SizedBox(height: AppSpacing.md),
    ],
  ];
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.historyAsync});

  final AsyncValue<List<MyHistoryItemModel>> historyAsync;

  @override
  Widget build(BuildContext context) => historyAsync.when(
    loading: () => const _SkeletonCard(height: 100),
    error:
        (_, __) => const _DataMessageCard(
          icon: Icons.cloud_off_rounded,
          title: 'Gagal memuat riwayat',
          message: 'Periksa koneksi internet lalu coba lagi.',
        ),
    data:
        (history) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            100,
          ),
          children: [
            const QuestionnaireSectionHeader(
              title: 'Riwayat Pengerjaan',
              subtitle: 'Lihat kembali hasil Pre-Test dan Post-Test Anda.',
            ),
            const SizedBox(height: AppSpacing.md),
            QuestionnaireHistorySection(history: history),
          ],
        ),
  );
}

class _SurveyTab extends StatelessWidget {
  const _SurveyTab();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.lg,
      AppSpacing.page,
      100,
    ),
    children: const [
      QuestionnaireSectionHeader(
        title: 'Survey Penelitian',
        subtitle:
            'Bantu kami meningkatkan pengalaman penggunaan aplikasi DIBA.',
      ),
      SizedBox(height: AppSpacing.md),
      SurveyCardSection(),
    ],
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _EducationModuleCard extends StatelessWidget {
  const _EducationModuleCard({required this.items, required this.history});

  final List<PatientQuestionnaireItemModel> items;
  final List<MyHistoryItemModel> history;

  @override
  Widget build(BuildContext context) {
    final title =
        items.first.educationTitle?.isNotEmpty == true
            ? items.first.educationTitle!
            : 'Modul Edukasi';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEFEB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => _ModuleQuizRow(
              item: item,
              latestAttempt: history
                  .where((attempt) => attempt.questionnaireId == item.id)
                  .fold<MyHistoryItemModel?>(
                    null,
                    (latest, attempt) =>
                        latest == null ||
                                attempt.completedAt.isAfter(latest.completedAt)
                            ? attempt
                            : latest,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleQuizRow extends ConsumerWidget {
  const _ModuleQuizRow({required this.item, this.latestAttempt});

  final PatientQuestionnaireItemModel item;
  final MyHistoryItemModel? latestAttempt;

  Future<void> _openQuestionnaire(BuildContext context, WidgetRef ref) async {
    try {
      final detail = await ref
          .read(questionnaireRepositoryProvider)
          .getQuestionnaireById(item.id);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionnaireDetailScreen(questionnaire: detail),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail kuesioner.')),
      );
    }
  }

  void _openResult(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => QuestionnaireReviewScreen(
              questionnaireId: item.id,
              quizTitle: item.title,
              attemptId: latestAttempt?.attemptId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap:
        item.isCompleted
            ? () => _openResult(context)
            : () => _openQuestionnaire(context, ref),
    child: Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.isPreTest
                    ? Icons.play_circle_outline_rounded
                    : Icons.verified_outlined,
                color:
                    item.isCompleted
                        ? Colors.green.shade700
                        : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.isPreTest ? 'Pre-Test' : 'Post-Test',
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.isCompleted
                          ? 'Sudah selesai${item.score == null ? '' : ' · Skor ${item.score}'}'
                          : '${item.questionCount} pertanyaan',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.isCompleted) ...[
                QuestionnaireActionButton(
                  onPressed: () => _openResult(context),
                  label: 'Lihat Detail',
                  icon: Icons.visibility_outlined,
                ),
                const SizedBox(height: 8),
                QuestionnaireActionButton(
                  onPressed: () => _openQuestionnaire(context, ref),
                  label: 'Kerjakan Ulang',
                  icon: Icons.replay_rounded,
                ),
              ] else
                QuestionnaireActionButton(
                  onPressed: () => _openQuestionnaire(context, ref),
                  label: 'Mulai Kuesioner',
                  icon: Icons.play_arrow_rounded,
                  variant: QuestionnaireActionVariant.primary,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _DataMessageCard extends StatelessWidget {
  const _DataMessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: AppColors.outlineVariant.withValues(alpha: 0.35),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 36),
        const SizedBox(height: 10),
        Text(
          title,
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _RetryMessageCard extends StatelessWidget {
  const _RetryMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: AppColors.outlineVariant.withValues(alpha: 0.35),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 36),
        const SizedBox(height: 10),
        Text(
          title,
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
      ],
    ),
  );
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
