import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/survey_model.dart';
import '../viewmodels/survey_notifier.dart';
import 'survey_thank_you_screen.dart';

class SurveyQuestionsScreen extends ConsumerStatefulWidget {
  final SurveyModel survey;

  const SurveyQuestionsScreen({
    super.key,
    required this.survey,
  });

  @override
  ConsumerState<SurveyQuestionsScreen> createState() => _SurveyQuestionsScreenState();
}

class _SurveyQuestionsScreenState extends ConsumerState<SurveyQuestionsScreen> {
  final Map<String, int> _answers = {}; // question_id -> rating (1..5)
  int _currentIndex = 0;
  late final Stopwatch _stopwatch;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate required questions
    final questions = widget.survey.questions;
    for (final q in questions) {
      if (q.isRequired && !_answers.containsKey(q.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harap jawab pertanyaan "${q.questionText}"'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    _stopwatch.stop();

    final success = await ref.read(surveySubmissionProvider.notifier).submit(
          surveyId: widget.survey.id,
          answers: _answers,
          durationSeconds: _stopwatch.elapsed.inSeconds,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ref.invalidate(activeSurveyProvider);
      ref.invalidate(activeSurveysProvider);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SurveyThankYouScreen(),
        ),
      );
    } else {
      final err = ref.read(surveySubmissionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err?.toString().replaceFirst('Exception: ', '') ??
              'Gagal mengirim survei. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.survey.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.survey.title)),
        body: const Center(child: Text('Survei ini belum memiliki pertanyaan.')),
      );
    }

    final currentQuestion = questions[_currentIndex];
    final isLast = _currentIndex == questions.length - 1;
    final selectedRating = _answers[currentQuestion.id];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          widget.survey.title,
          style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / questions.length,
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pertanyaan ${_currentIndex + 1} dari ${questions.length}',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentQuestion.isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'Wajib',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion.questionText,
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              height: 1.4,
                            ),
                          ),
                          if (currentQuestion.description != null &&
                              currentQuestion.description!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              currentQuestion.description!,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Likert Options (1 to 5)
                    Text(
                      'Pilih Jawaban Anda:',
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ...List.generate(5, (idx) {
                      final val = idx + 1;
                      final labelText = (idx < currentQuestion.likertLabels.length)
                          ? currentQuestion.likertLabels[idx]
                          : 'Skor $val';
                      final isSelected = selectedRating == val;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _answers[currentQuestion.id] = val;
                            });
                          },
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryContainer.withValues(alpha: 0.25)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.outline,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$val',
                                      style: AppTextStyles.labelLg.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.onPrimary
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    labelText,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight:
                                          isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.page),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0) ...[
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _currentIndex--);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: const Text('Sebelumnya'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (currentQuestion.isRequired &&
                                    !_answers.containsKey(currentQuestion.id)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Silakan pilih salah satu jawaban.'),
                                    ),
                                  );
                                  return;
                                }

                                if (isLast) {
                                  _submit();
                                } else {
                                  setState(() => _currentIndex++);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isLast ? 'Kirim Survei' : 'Berikutnya'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
