import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/questionnaire_repository.dart';
import '../models/quiz_attempt_model.dart';
import 'questionnaire_questions_screen.dart';
import 'questionnaire_review_screen.dart';

/// Displays the result returned by the backend after submitting a questionnaire.
///
/// For Post-Test, allows retaking the test ("Kerjakan Ulang Post-Test") anytime.
class QuestionnaireResultScreen extends ConsumerWidget {
  const QuestionnaireResultScreen({
    super.key,
    required this.result,
    required this.questionnaireTitle,
    this.isPreTest = false,
  });

  final QuizSubmitResultModel result;
  final String questionnaireTitle;
  final bool isPreTest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = result.score;
    final percentage = result.percentage;
    final correctCount = result.correctCount;
    final incorrectCount = result.incorrectCount;
    final totalQuestions = result.totalQuestions;
    final isPassed = result.passed;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        automaticallyImplyLeading: false,
        title: Text(
          isPreTest ? 'Kuesioner Selesai' : 'Hasil Post-Test',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: AppSpacing.page,
              right: AppSpacing.page,
              top: AppSpacing.lg,
              bottom: isPreTest ? 120 : 250,
            ),
            child: isPreTest
                ? Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 64,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              'Terima Kasih',
                              style: AppTextStyles.headlineLg.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Terima kasih telah menyelesaikan Kuesioner Awal DSMES. Jawaban Anda telah berhasil disimpan dan akan digunakan untuk membantu memahami tingkat keyakinan Anda dalam mengelola diabetes.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLg.copyWith(
                                fontSize: 15,
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Score hero card ──────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Nilai Akhir',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.outline,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Circular score ring
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 6,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$score',
                                  style: AppTextStyles.headlineLg.copyWith(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            Text(
                              isPassed ? 'Sangat Baik!' : 'Perlu Belajar Lagi',
                              style: AppTextStyles.headlineMd.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.percent_rounded,
                                    size: 14, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text(
                                  '$percentage% benar',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontSize: 13,
                                    color: AppColors.outline,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.quiz_rounded,
                                    size: 14, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalQuestions soal',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontSize: 13,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Correct / Incorrect stats ────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_rounded,
                              iconBg: const Color(0xFFABF4AC),
                              iconColor: const Color(0xFF07521D),
                              count: correctCount,
                              label: 'Benar',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.cancel_rounded,
                              iconBg: const Color(0xFFFFDAD6),
                              iconColor: const Color(0xFF93000A),
                              count: incorrectCount,
                              label: 'Salah',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Recommendation banner ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                  children: [
                                    if (isPassed)
                                      const TextSpan(
                                        text: 'Luar Biasa! ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    TextSpan(
                                      text: isPassed
                                          ? 'Pengetahuan Anda sangat baik. Anda dapat mempelajari materi lain atau mengulang Post-Test kapan saja.'
                                          : 'Jangan khawatir! Anda dapat membaca pembahasan jawaban dan mengerjakan ulang Post-Test ini kapan saja.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          // ── Fixed bottom CTA buttons ─────────────────────────────────────
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
                    // Button: Lihat Pembahasan Jawaban (Post-Test only)
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuestionnaireReviewScreen(
                                questionnaireId: result.questionnaireId,
                                quizTitle: questionnaireTitle,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment_turned_in_outlined,
                            size: 18),
                        label: Text(
                          'Lihat Pembahasan Jawaban',
                          style: AppTextStyles.poppinsButton.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Button: Kerjakan Ulang Post-Test (Post-Test only)
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
                          final detail = await ref
                              .read(questionnaireRepositoryProvider)
                              .getQuestionnaireById(result.questionnaireId);
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => QuestionnaireQuestionsScreen(
                                  questionnaire: detail,
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

                  // Main Navigation Button (Home or Back)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (isPreTest) {
                          context.go(RouteNames.home);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        isPreTest
                            ? Icons.home_rounded
                            : Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        isPreTest ? 'Lanjutkan ke Beranda' : 'Kembali',
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
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card widget ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 12,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
