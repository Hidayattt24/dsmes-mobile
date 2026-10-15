import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/questionnaire_repository.dart';
import '../models/quiz_attempt_model.dart';
import '../models/questionnaire_detail_model.dart';
import '../viewmodels/questionnaire_notifier.dart';
import 'pre_test_intro_screen.dart';
import 'questionnaire_questions_screen.dart';
import 'questionnaire_review_screen.dart';
import '../widgets/questionnaire_action_button.dart';

class PreTestResultData {
  const PreTestResultData({
    required this.questionnaireId,
    required this.result,
  });

  final String questionnaireId;
  final QuizSubmitResultModel result;
}

/// Displays the result of the patient's latest attempt for a questionnaire.
///
/// Reads from [myAttemptDetailProvider] — the SAME backend source the bottom
/// navigation (history / list) and the review screen use — so the score shown
/// here is always consistent with the rest of the app. There is no local score
/// computation and no `score ?? 0` fallback: until the attempt is loaded a
/// proper loading state is shown instead.
class QuestionnaireResultScreen extends ConsumerWidget {
  const QuestionnaireResultScreen({
    super.key,
    required this.questionnaireId,
    required this.questionnaireTitle,
    this.isPreTest = false,
    this.returnToHome = false,
    this.returnToEducationId,
    this.initialResult,
  });

  final String questionnaireId;
  final String questionnaireTitle;
  final bool isPreTest;
  final bool returnToHome;
  final String? returnToEducationId;
  final QuizSubmitResultModel? initialResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submittedResult = initialResult;
    final attemptQuery =
        submittedResult == null
            ? null
            : AttemptDetailQuery(
              questionnaireId: questionnaireId,
              attemptId: submittedResult.attemptId,
            );
    final detailAsync =
        submittedResult != null && attemptQuery != null
            ? ref.watch(attemptDetailByIdProvider(attemptQuery))
            : ref.watch(myAttemptDetailProvider(questionnaireId));
    final questionnaireAsync = ref.watch(
      questionnaireDetailProvider(questionnaireId),
    );
    final imageUrls = <String, String>{};
    for (final question
        in questionnaireAsync.valueOrNull?.allQuestions ??
            const <QuestionModel>[]) {
      final imageUrl = question.questionImageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrls[question.id] = imageUrl;
      }
    }

    final appBar = AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
      automaticallyImplyLeading: false,
      title: Text(
        returnToEducationId != null
            ? (isPreTest
                ? 'Pre-Test Edukasi Selesai'
                : 'Post-Test Edukasi Selesai')
            : isPreTest
            ? 'Kuesioner Selesai'
            : 'Hasil Post-Test',
        style: AppTextStyles.headlineMd.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: appBar,
      body: detailAsync.when(
        loading:
            () =>
                submittedResult != null
                    ? _ResultBodyFromSubmit(
                      result: submittedResult,
                      questionnaireId: questionnaireId,
                      questionnaireTitle: questionnaireTitle,
                      isPreTest: isPreTest,
                      returnToHome: returnToHome,
                      returnToEducationId: returnToEducationId,
                      imageUrls: imageUrls,
                    )
                    : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
        error:
            (err, _) =>
                submittedResult != null
                    ? _ResultBodyFromSubmit(
                      result: submittedResult,
                      questionnaireId: questionnaireId,
                      questionnaireTitle: questionnaireTitle,
                      isPreTest: isPreTest,
                      returnToHome: returnToHome,
                      returnToEducationId: returnToEducationId,
                      imageUrls: imageUrls,
                    )
                    : _ResultErrorView(
                      message: err.toString().replaceFirst('Exception: ', ''),
                      onRetry:
                          () => ref.invalidate(
                            submittedResult != null && attemptQuery != null
                                ? attemptDetailByIdProvider(attemptQuery)
                                : myAttemptDetailProvider(questionnaireId),
                          ),
                    ),
        data:
            (detail) => _ResultBody(
              detail: detail,
              questionnaireId: questionnaireId,
              questionnaireTitle: questionnaireTitle,
              isPreTest: isPreTest,
              returnToHome: returnToHome,
              returnToEducationId: returnToEducationId,
              imageUrls: imageUrls,
            ),
      ),
    );
  }
}

class _ResultBodyFromSubmit extends StatelessWidget {
  const _ResultBodyFromSubmit({
    required this.result,
    required this.questionnaireId,
    required this.questionnaireTitle,
    required this.isPreTest,
    required this.returnToHome,
    this.returnToEducationId,
    required this.imageUrls,
  });

  final QuizSubmitResultModel result;
  final String questionnaireId;
  final String questionnaireTitle;
  final bool isPreTest;
  final bool returnToHome;
  final String? returnToEducationId;
  final Map<String, String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isPreTest
                    ? _PreTestSubmitResultContent(
                      result: result,
                      imageUrls: imageUrls,
                      hideScore: returnToHome,
                      showCorrectAnswers: returnToEducationId != null,
                    )
                    : _PostTestResultContent(
                      score: result.score,
                      isPassed: result.passed,
                      totalQuestions: result.totalQuestions,
                      correctCount: result.correctCount,
                      incorrectCount: result.incorrectCount,
                    ),
              ],
            ),
          ),
        ),
        _ResultBottomActions(
          questionnaireId: questionnaireId,
          questionnaireTitle: questionnaireTitle,
          isPreTest: isPreTest,
          returnToHome: returnToHome,
          returnToEducationId: returnToEducationId,
        ),
      ],
    );
  }
}

/// Pre-Test result entry point used by the router. The Pre-Test is always a
/// single, latest attempt so it only needs the questionnaire id.
class PreTestResultScreen extends ConsumerWidget {
  const PreTestResultScreen({
    super.key,
    required this.questionnaireId,
    this.initialResult,
  });

  final String questionnaireId;
  final QuizSubmitResultModel? initialResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QuestionnaireResultScreen(
      questionnaireId: questionnaireId,
      questionnaireTitle: '',
      isPreTest: true,
      returnToHome: true,
      initialResult: initialResult,
    );
  }
}

// ── Loading / error states ──────────────────────────────────────────────────

class _ResultErrorView extends StatelessWidget {
  const _ResultErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.outline,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Gagal memuat hasil kuesioner',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main result body ─────────────────────────────────────────────────────────

class _ResultBody extends ConsumerWidget {
  const _ResultBody({
    required this.detail,
    required this.questionnaireId,
    required this.questionnaireTitle,
    required this.isPreTest,
    required this.returnToHome,
    this.returnToEducationId,
    required this.imageUrls,
  });

  final AttemptDetailModel detail;
  final String questionnaireId;
  final String questionnaireTitle;
  final bool isPreTest;
  final bool returnToHome;
  final String? returnToEducationId;
  final Map<String, String> imageUrls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = detail.score;
    final totalQuestions = detail.questionAnalysis.length;
    final correctCount =
        detail.questionAnalysis.where((q) => q.isCorrect).length;
    final incorrectCount = (totalQuestions - correctCount).clamp(
      0,
      totalQuestions,
    );
    final isPassed = detail.passed;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isPreTest
                    ? _PreTestResultContent(
                      detail: detail,
                      imageUrls: imageUrls,
                      hideScore: returnToHome,
                      showCorrectAnswers: returnToEducationId != null,
                    )
                    : _PostTestResultContent(
                      score: score,
                      isPassed: isPassed,
                      totalQuestions: totalQuestions,
                      correctCount: correctCount,
                      incorrectCount: incorrectCount,
                    ),
              ],
            ),
          ),
        ),
        _ResultBottomActions(
          questionnaireId: questionnaireId,
          questionnaireTitle: questionnaireTitle,
          isPreTest: isPreTest,
          returnToHome: returnToHome,
          returnToEducationId: returnToEducationId,
        ),
      ],
    );
  }
}

// ── Bottom action area (SafeArea + consistent layout) ───────────────────────

class _ResultBottomActions extends ConsumerWidget {
  const _ResultBottomActions({
    required this.questionnaireId,
    required this.questionnaireTitle,
    required this.isPreTest,
    required this.returnToHome,
    this.returnToEducationId,
  });

  final String questionnaireId;
  final String questionnaireTitle;
  final bool isPreTest;
  final bool returnToHome;
  final String? returnToEducationId;

  void _openReview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => QuestionnaireReviewScreen(
              questionnaireId: questionnaireId,
              quizTitle: isPreTest ? 'Hasil Pre-Test' : questionnaireTitle,
            ),
      ),
    );
  }

  Future<void> _retake(BuildContext context, WidgetRef ref) async {
    final detail = await ref
        .read(questionnaireRepositoryProvider)
        .getQuestionnaireById(questionnaireId);
    if (!context.mounted) return;
    if (isPreTest) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => QuestionnaireQuestionsScreen(
                questionnaire: detail,
                isPreTest: true,
                returnToEducationId: returnToEducationId,
              ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => QuestionnaireQuestionsScreen(
                questionnaire: detail,
                isPreTest: false,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPreTest) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: QuestionnaireActionButton(
                  onPressed: () => _openReview(context),
                  icon: Icons.visibility_outlined,
                  label: 'Lihat Pembahasan Jawaban',
                ),
              ),
              const SizedBox(height: 8),
            ],

            SizedBox(
              width: double.infinity,
              height: 48,
              child: QuestionnaireActionButton(
                onPressed: () => _retake(context, ref),
                icon: Icons.replay_rounded,
                label:
                    isPreTest ? 'Kerjakan Ulang' : 'Kerjakan Ulang Post-Test',
                variant: QuestionnaireActionVariant.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Primary: Lanjutkan ke Beranda / Kembali
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  alignment: Alignment.center,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  if (returnToEducationId != null) {
                    Navigator.of(context).pop();
                  } else if (returnToHome) {
                    await ref.read(preTestHistoryProvider.notifier).refresh();
                    if (!context.mounted) return;
                    context.go(RouteNames.home);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(
                  returnToEducationId != null
                      ? Icons.menu_book_rounded
                      : returnToHome
                      ? Icons.home_rounded
                      : Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  returnToEducationId != null
                      ? 'Lanjut Baca Edukasi'
                      : returnToHome
                      ? 'Mulai Menggunakan Aplikasi'
                      : 'Kembali',
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
    );
  }
}

// ── Post-Test result content ─────────────────────────────────────────────────

class _PostTestResultContent extends StatelessWidget {
  const _PostTestResultContent({
    required this.score,
    required this.isPassed,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
  });

  final int score;
  final bool isPassed;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  border: Border.all(color: AppColors.primary, width: 6),
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

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 4,
                children: [
                  const Icon(
                    Icons.percent_rounded,
                    size: 14,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$score% benar',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 13,
                      color: AppColors.outline,
                    ),
                  ),
                  const Icon(
                    Icons.quiz_rounded,
                    size: 14,
                    color: AppColors.outline,
                  ),
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
              const Icon(
                Icons.lightbulb_rounded,
                color: Colors.white,
                size: 22,
              ),
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
                        text:
                            isPassed
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
    );
  }
}

class _ApplicationPreTestCompleteContent extends StatelessWidget {
  const _ApplicationPreTestCompleteContent();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                'Kuesioner Selesai',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLg.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Terima kasih telah mengisi kuesioner awal. Selamat mencoba aplikasi DIBA.',
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
    );
  }
}

// ── Pre-Test result content ──────────────────────────────────────────────────

class _PreTestResultContent extends StatelessWidget {
  const _PreTestResultContent({
    required this.detail,
    required this.imageUrls,
    this.hideScore = false,
    this.showCorrectAnswers = false,
  }) : score = null,
       selfEfficacyCategory = null;

  const _PreTestResultContent.fromSubmit({
    required this.score,
    required this.selfEfficacyCategory,
    required this.imageUrls,
    this.hideScore = false,
    this.showCorrectAnswers = false,
  }) : detail = null;

  final AttemptDetailModel? detail;
  final int? score;
  final String? selfEfficacyCategory;
  final Map<String, String> imageUrls;
  final bool hideScore;
  final bool showCorrectAnswers;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = _selfEfficacyLabel(
      detail?.selfEfficacyCategory ?? selfEfficacyCategory ?? '',
    );

    return Column(
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
                'Kuesioner Awal Selesai',
                style: AppTextStyles.headlineLg.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              if (!hideScore) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  showCorrectAnswers
                      ? 'Skor Pemahaman Pre-Test'
                      : 'Total Skor Keyakinan Diri (DMSES)',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${detail?.score ?? score ?? 0}',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    categoryLabel,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  showCorrectAnswers
                      ? 'Hasil ini menunjukkan pemahaman awal Anda sebelum membaca materi edukasi.'
                      : 'Nilai ini menggambarkan tingkat keyakinan Anda dalam mengelola diabetes. Tidak ada jawaban benar atau salah pada kuesioner ini.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Terima kasih telah mengisi kuesioner awal. Selamat mencoba aplikasi DIBA.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (detail != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pertanyaan dan Jawaban Anda',
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in detail!.questionAnalysis) ...[
            _PreTestQuestionAnswerCard(
              item: item,
              imageUrl: imageUrls[item.id],
              showCorrectAnswer: showCorrectAnswers,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ] else ...[
          const _AnswerLoadingCard(),
        ],
      ],
    );
  }
}

class _PreTestSubmitResultContent extends StatelessWidget {
  const _PreTestSubmitResultContent({
    required this.result,
    required this.imageUrls,
    this.hideScore = false,
    this.showCorrectAnswers = false,
  });

  final QuizSubmitResultModel result;
  final Map<String, String> imageUrls;
  final bool hideScore;
  final bool showCorrectAnswers;

  @override
  Widget build(BuildContext context) {
    return _PreTestResultContent.fromSubmit(
      score: result.score,
      selfEfficacyCategory: result.selfEfficacyCategory,
      imageUrls: imageUrls,
      hideScore: hideScore,
      showCorrectAnswers: showCorrectAnswers,
    );
  }
}

class _AnswerLoadingCard extends StatelessWidget {
  const _AnswerLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Memuat pertanyaan dan jawaban Anda...')),
        ],
      ),
    );
  }
}

class _PreTestQuestionAnswerCard extends StatelessWidget {
  const _PreTestQuestionAnswerCard({
    required this.item,
    this.imageUrl,
    this.showCorrectAnswer = false,
  });

  final QuestionAnalysisModel item;
  final String? imageUrl;
  final bool showCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pertanyaan ${item.questionNumber}',
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.questionText,
            style: AppTextStyles.bodyLg.copyWith(
              fontSize: 15,
              height: 1.4,
              color: AppColors.onSurface,
            ),
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.patientAnswer.isEmpty ? '-' : item.patientAnswer,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showCorrectAnswer && item.correctAnswer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Jawaban Benar: ${item.correctAnswer}',
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ],
          if (showCorrectAnswer && item.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Pembahasan: ${item.explanation}',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _selfEfficacyLabel(String category) {
  switch (category) {
    case 'Low Self-Efficacy':
      return 'Keyakinan Diri Rendah';
    case 'Moderate Self-Efficacy':
      return 'Keyakinan Diri Sedang';
    case 'Good Self-Efficacy':
      return 'Keyakinan Diri Baik';
    case 'Very High Self-Efficacy':
      return 'Keyakinan Diri Sangat Baik';
    default:
      return category.isEmpty ? 'Belum terklasifikasi' : category;
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
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
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
