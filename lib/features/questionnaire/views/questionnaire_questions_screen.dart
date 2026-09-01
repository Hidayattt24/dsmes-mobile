import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/questionnaire_detail_model.dart';
import '../viewmodels/questionnaire_notifier.dart';
import 'questionnaire_result_screen.dart';

/// Screen that presents questions one by one and submits answers to backend.
///
/// [isPreTest] controls post-submission navigation:
/// - Pre-Test → after result, user goes to Home
/// - Post-Test → after result, user goes back to questionnaire list
class QuestionnaireQuestionsScreen extends ConsumerStatefulWidget {
  const QuestionnaireQuestionsScreen({
    super.key,
    required this.questionnaire,
    this.isPreTest = false,
  });

  final QuestionnaireDetailModel questionnaire;
  final bool isPreTest;

  @override
  ConsumerState<QuestionnaireQuestionsScreen> createState() =>
      _QuestionnaireQuestionsScreenState();
}

class _QuestionnaireQuestionsScreenState
    extends ConsumerState<QuestionnaireQuestionsScreen> {
  late final List<QuestionModel> _questions;
  int _currentIndex = 0;

  /// Maps questionID → selected optionID (backend IDs, not indices)
  final Map<String, String> _answers = {};

  late final Stopwatch _stopwatch;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.questionnaire.allQuestions;
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  QuestionModel get _currentQuestion => _questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == _questions.length - 1;
  bool get _isAnswered => _answers.containsKey(_currentQuestion.id);
  bool get _allAnswered => _questions.every((q) => _answers.containsKey(q.id));
  double get _progress =>
      ((_currentIndex + 1) / _questions.length).clamp(0.0, 1.0);

  void _selectOption(String optionId) {
    setState(() {
      _answers[_currentQuestion.id] = optionId;
    });
  }

  void _goNext() {
    if (!_isAnswered) return;
    if (!_isLastQuestion) {
      setState(() => _currentIndex++);
    } else {
      _submitAnswers();
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Future<void> _submitAnswers() async {
    if (_isSubmitting) return;

    // Validate all answered
    if (!_allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap jawab semua pertanyaan sebelum mengirim.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF93000A),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    _stopwatch.stop();
    debugPrint('PRETEST_SUBMIT_START questionnaire=${widget.questionnaire.id}');

    final durationSeconds = _stopwatch.elapsed.inSeconds;

    final result = await ref
        .read(quizSubmissionProvider.notifier)
        .submit(
          questionnaireId: widget.questionnaire.id,
          answers: _answers,
          durationSeconds: durationSeconds,
          isPreTest: widget.isPreTest,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      debugPrint(
        'PRETEST_SUBMIT_SUCCESS attempt=${result.attemptId} score=${result.score}',
      );
      if (widget.isPreTest) {
        debugPrint('PRETEST_RESULT_OPEN attempt=${result.attemptId}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => QuestionnaireResultScreen(
                  questionnaireId: widget.questionnaire.id,
                  questionnaireTitle: widget.questionnaire.title,
                  isPreTest: true,
                  returnToHome: true,
                  initialResult: result,
                ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => QuestionnaireResultScreen(
                  questionnaireId: widget.questionnaire.id,
                  questionnaireTitle: widget.questionnaire.title,
                  isPreTest: false,
                ),
          ),
        );
      }

      // Do not refresh the completion guard while the Pre-Test result is on
      // screen. It is refreshed when the user explicitly continues to Home.
      if (!widget.isPreTest) {
        ref
            .read(quizSubmissionProvider.notifier)
            .refreshAfterSubmission(widget.questionnaire.id);
      }
    } else {
      // Show error from state
      final errMsg = ref.read(quizSubmissionProvider).errorMessage;
      debugPrint('PRETEST_SUBMIT_ERROR $errMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg ?? 'Gagal mengirim jawaban. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.questionnaire.title),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(
          child: Text('Kuesioner ini belum memiliki pertanyaan.'),
        ),
      );
    }

    final currentQuestion = _currentQuestion;
    final selectedOptionId = _answers[currentQuestion.id];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          onPressed: () => _showExitDialog(context),
        ),
        title: Text(
          widget.isPreTest ? 'Pre-Test' : 'Kuesioner',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Progress indicator ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.outline,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Question Illustration Image (If present) ─────────────
                  if (currentQuestion.questionImageUrl != null &&
                      currentQuestion.questionImageUrl!.isNotEmpty) ...[
                    _QuestionImageWidget(
                      imageUrl: currentQuestion.questionImageUrl!,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Question text ──────────────────────────────────────
                  Text(
                    currentQuestion.questionText,
                    style: AppTextStyles.headlineLg.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Answer options ─────────────────────────────────────
                  if (widget.isPreTest) ...[
                    // Pre-Test DMSES 1-5 Likert scale confidence cards
                    Text(
                      'Tingkat Keyakinan Anda:',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final choice in currentQuestion.choices) ...[
                      _LikertOptionCard(
                        choice: choice,
                        isSelected: selectedOptionId == choice.id,
                        onTap: () => _selectOption(choice.id),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ] else ...[
                    // Standard Multiple Choice cards for Post-Test
                    for (final choice in currentQuestion.choices) ...[
                      _OptionCard(
                        optionText: choice.optionText,
                        isSelected: selectedOptionId == choice.id,
                        onTap: () => _selectOption(choice.id),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom navigation bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.page),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentIndex > 0) ...[
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceTint.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppColors.primary,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _goPrevious,
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
                                  style: AppTextStyles.poppinsButton.copyWith(
                                    fontSize: 14,
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
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isAnswered
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                          foregroundColor: Colors.white,
                          elevation: _isAnswered ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed:
                            _isAnswered && !_isSubmitting ? _goNext : null,
                        child:
                            _isSubmitting
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
                                        _isLastQuestion
                                            ? 'Selesai & Kirim'
                                            : 'Selanjutnya',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.poppinsButton
                                            .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _isLastQuestion
                                          ? Icons.check_circle_rounded
                                          : Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
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
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Keluar dari Kuesioner?'),
            content: const Text(
              'Jawaban yang belum dikirim tidak akan disimpan. '
              'Apakah Anda yakin ingin keluar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Keluar', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
    if (confirm == true && mounted) {
      Navigator.of(context).pop();
    }
  }
}

// ── Option card ───────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: 2,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.04,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  optionText,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: AppColors.outline,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikertOptionCard extends StatelessWidget {
  const _LikertOptionCard({
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  final ChoiceModel choice;
  final bool isSelected;
  final VoidCallback onTap;

  String _getEmoji(String id, int order) {
    if (id == '1' || order == 1) return '😟';
    if (id == '2' || order == 2) return '🙁';
    if (id == '3' || order == 3) return '😐';
    if (id == '4' || order == 4) return '🙂';
    if (id == '5' || order == 5) return '😊';
    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmoji(choice.id, choice.displayOrder);

    final int displayNum =
        choice.displayOrder > 0
            ? choice.displayOrder
            : (int.tryParse(choice.id) ?? 1);

    final String optionTextDisplay =
        choice.optionText.contains(RegExp(r'^\d+\.'))
            ? choice.optionText
            : '$displayNum. ${choice.optionText}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  optionTextDisplay,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionImageWidget extends StatelessWidget {
  const _QuestionImageWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = imageUrl.substring(commaIndex + 1);
          final bytes = base64Decode(base64Str.replaceAll(RegExp(r'\s+'), ''));
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              bytes,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          );
        }
      } catch (_) {
        return const SizedBox.shrink();
      }
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
