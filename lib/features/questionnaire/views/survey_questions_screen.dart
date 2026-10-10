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
    final isAnswered = selectedRating != null;
    final isSUS = widget.survey.isSUS;
    final progress = (_currentIndex + 1) / questions.length;
    final progressPercent = (progress * 100).toInt();

    return PopScope(
      canPop: _answers.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar dari Survei?'),
            content: const Text(
              'Jawaban yang sudah Anda pilih belum dikirim. Yakin ingin keluar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Lanjutkan Survei'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );
        if (shouldLeave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: () async {
              if (_answers.isEmpty) {
                Navigator.of(context).pop();
                return;
              }
              final shouldLeave = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar dari Survei?'),
                  content: const Text(
                    'Jawaban yang sudah Anda pilih belum dikirim. Yakin ingin keluar?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Lanjutkan Survei'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (shouldLeave == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.survey.title,
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSUS
                            ? Colors.blue.withValues(alpha: 0.12)
                            : AppColors.primaryContainer.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        isSUS ? 'SURVEY SUS' : 'SURVEY KEPUASAN',
                        style: AppTextStyles.labelSm.copyWith(
                          color: isSUS ? Colors.blue.shade800 : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSUS ? 'System Usability Scale (SUS)' : 'Kepuasan Pengguna',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Pertanyaan ${_currentIndex + 1}/${questions.length} ($progressPercent%)',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4.0,
                backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    AppSpacing.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Question Card ────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${_currentIndex + 1}',
                                        style: AppTextStyles.labelMd.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pernyataan',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (currentQuestion.isRequired)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Text(
                                      'Wajib Diisi',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              currentQuestion.questionText,
                              style: AppTextStyles.titleMd.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                                height: 1.45,
                              ),
                            ),
                            if (currentQuestion.description != null &&
                                currentQuestion.description!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        currentQuestion.description!,
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Likert Scale Spectrum Guide ──────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pilih Jawaban Anda:',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Skor 1 - 5',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1: Sangat Tidak Setuju',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.outline,
                            ),
                            Text(
                              '5: Sangat Setuju',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Likert Options (1 to 5) ──────────────────────────────
                      ...List.generate(5, (idx) {
                        final val = idx + 1;
                        final labelText =
                            (idx < currentQuestion.likertLabels.length)
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryContainer.withValues(alpha: 0.22)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outlineVariant.withValues(alpha: 0.6),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.background,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.outline,
                                        width: 1.5,
                                      ),
                                    ),
                                     child: Center(
                                       child: Text(
                                         '$val',
                                         style: AppTextStyles.labelLg.copyWith(
                                           fontWeight: FontWeight.bold,
                                           color: isSelected
                                               ? AppColors.onPrimary
                                               : AppColors.onSurfaceVariant,
                                         ),
                                       ),
                                     ),
                                   ),
                                   const SizedBox(width: AppSpacing.md),
                                   Expanded(
                                     child: Text(
                                       labelText,
                                       style: AppTextStyles.bodyMd.copyWith(
                                         fontSize: 14,
                                         fontWeight:
                                             isSelected ? FontWeight.bold : FontWeight.w500,
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
                                      size: 22,
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

              // ── Modern Bottom Navigation Bar ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.page),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // ── Tombol Sebelumnya ──────────────────────────────────
                      if (_currentIndex > 0) ...[
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _currentIndex--);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    AppColors.surfaceTint.withValues(alpha: 0.08),
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Sebelumnya',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelLg.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],

                      // ── Tombol Selanjutnya / Kirim Survey ─────────────────
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    if (currentQuestion.isRequired &&
                                        !_answers.containsKey(currentQuestion.id)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Silakan pilih salah satu jawaban terlebih dahulu.'),
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
                              backgroundColor: isAnswered
                                  ? AppColors.primary
                                  : AppColors.outlineVariant.withValues(alpha: 0.7),
                              foregroundColor: isAnswered
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                              elevation: isAnswered ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          isLast ? 'Kirim Survey' : 'Selanjutnya',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.labelLg.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isAnswered
                                                ? AppColors.onPrimary
                                                : AppColors.onSurfaceVariant
                                                    .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isLast
                                            ? Icons.send_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: isAnswered
                                            ? AppColors.onPrimary
                                            : AppColors.onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                      ),
                                    ],
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
        ),
      ),
    );
  }
}
