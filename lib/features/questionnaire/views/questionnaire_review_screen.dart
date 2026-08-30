import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/questionnaire_repository.dart';
import '../models/quiz_attempt_model.dart';
import '../viewmodels/questionnaire_notifier.dart';
import 'questionnaire_questions_screen.dart';

class QuestionnaireReviewScreen extends ConsumerWidget {
  const QuestionnaireReviewScreen({
    super.key,
    required this.questionnaireId,
    this.quizTitle,
  });

  final String questionnaireId;
  final String? quizTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(myAttemptDetailProvider(questionnaireId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          quizTitle ?? 'Detail Jawaban',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat detail jawaban',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (detail) => _ReviewContent(
          detail: detail,
          questionnaireId: questionnaireId,
        ),
      ),
    );
  }
}

class _ReviewContent extends ConsumerWidget {
  const _ReviewContent({
    required this.detail,
    required this.questionnaireId,
  });

  final AttemptDetailModel detail;
  final String questionnaireId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPreTest = detail.isPreTest ||
        detail.quizTitle.toLowerCase().contains('pre-test') ||
        detail.quizTitle.toLowerCase().contains('pretest');

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.page,
            right: AppSpacing.page,
            top: AppSpacing.lg,
            bottom: isPreTest ? 100 : 160,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Summary Card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.quizTitle,
                                style: AppTextStyles.headlineMd.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Durasi Pengerjaan: ${detail.duration}',
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontSize: 13,
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isPreTest
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : detail.passed
                                    ? const Color(0xFFABF4AC)
                                    : const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Skor: ${detail.score}',
                            style: AppTextStyles.headlineMd.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPreTest
                                  ? AppColors.primary
                                  : detail.passed
                                      ? const Color(0xFF07521D)
                                      : const Color(0xFF93000A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Section Title ────────────────────────────────────────────
              Text(
                'Analisis Pertanyaan & Jawaban',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Itemized Question Analysis Cards ─────────────────────────
              for (final item in detail.questionAnalysis) ...[
                _QuestionReviewCard(item: item, isPreTest: isPreTest),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),

        // ── Pinned Bottom Bar ──────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.lg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.97),
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isPreTest) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final qDetail = await ref
                            .read(questionnaireRepositoryProvider)
                            .getQuestionnaireById(questionnaireId);
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => QuestionnaireQuestionsScreen(
                                questionnaire: qDetail,
                                isPreTest: false,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.replay_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                        'Kerjakan Ulang Post-Test',
                        style: AppTextStyles.poppinsButton.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.primary, size: 18),
                    label: Text(
                      'Kembali',
                      style: AppTextStyles.poppinsButton.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Question Review Card ──────────────────────────────────────────────────────

class _QuestionReviewCard extends StatelessWidget {
  const _QuestionReviewCard({required this.item, required this.isPreTest});

  final QuestionAnalysisModel item;
  final bool isPreTest;

  @override
  Widget build(BuildContext context) {
    final borderColor = isPreTest
        ? AppColors.outlineVariant.withValues(alpha: 0.4)
        : item.isCorrect
            ? const Color(0xFFABF4AC)
            : const Color(0xFFFFDAD6);
    final answerBg = isPreTest
        ? AppColors.primary.withValues(alpha: 0.06)
        : item.isCorrect
            ? const Color(0xFF07521D).withValues(alpha: 0.06)
            : const Color(0xFF93000A).withValues(alpha: 0.06);
    final answerBorder = isPreTest
        ? AppColors.primary.withValues(alpha: 0.2)
        : item.isCorrect
            ? const Color(0xFF07521D).withValues(alpha: 0.2)
            : const Color(0xFF93000A).withValues(alpha: 0.2);
    final answerLabelColor = isPreTest
        ? AppColors.primary
        : item.isCorrect
            ? const Color(0xFF07521D)
            : const Color(0xFF93000A);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1.5,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header Badge (Soal #N + Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soal No. ${item.questionNumber}',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              if (!isPreTest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isCorrect
                        ? const Color(0xFFABF4AC)
                        : const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 16,
                        color: item.isCorrect
                            ? const Color(0xFF07521D)
                            : const Color(0xFF93000A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.isCorrect ? 'Benar' : 'Salah',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: item.isCorrect
                              ? const Color(0xFF07521D)
                              : const Color(0xFF93000A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Question Text
          Text(
            item.questionText,
            style: AppTextStyles.bodyLg.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // User's Answer Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: answerBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: answerBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jawaban Anda:',
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: answerLabelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.patientAnswer,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Correct Answer Box (post-test only, if user was incorrect)
          if (!isPreTest && !item.isCorrect && item.correctAnswer.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF07521D).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF07521D).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jawaban Benar:',
                    style: AppTextStyles.labelMd.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF07521D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.correctAnswer,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Explanation Box (Pembahasan — post-test only)
          if (!isPreTest && item.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Pembahasan:',
                        style: AppTextStyles.labelMd.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.explanation,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
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
