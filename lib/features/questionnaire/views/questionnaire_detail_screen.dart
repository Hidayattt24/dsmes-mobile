import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/questionnaire_detail_model.dart';
import 'questionnaire_questions_screen.dart';

/// Displays detail info & instructions about a questionnaire (Pre-Test or Post-Test)
/// before the patient begins answering.
class QuestionnaireDetailScreen extends ConsumerWidget {
  const QuestionnaireDetailScreen({
    super.key,
    required this.questionnaire,
  });

  final QuestionnaireDetailModel questionnaire;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Detail & Instruksi Kuesioner',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: AppSpacing.page,
              right: AppSpacing.page,
              top: AppSpacing.lg,
              bottom: 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type badge ──────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: questionnaire.isPreTest
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: questionnaire.isPreTest
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    questionnaire.isPreTest
                        ? 'PRE-TEST EVALUASI'
                        : 'POST-TEST EDUKASI',
                    style: AppTextStyles.labelMd.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: questionnaire.isPreTest
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Title & Description ─────────────────────────────────
                Text(
                  questionnaire.title,
                  style: AppTextStyles.headlineLg.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                if (questionnaire.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    questionnaire.description,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // ── Info chips ──────────────────────────────────────────
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.quiz_rounded,
                      label: '${questionnaire.questionCount} Pertanyaan',
                    ),
                    if (questionnaire.difficulty != null)
                      _InfoChip(
                        icon: Icons.bar_chart_rounded,
                        label: questionnaire.difficulty!,
                      ),
                    if (questionnaire.passingScore != null)
                      _InfoChip(
                        icon: Icons.grade_rounded,
                        label: 'Nilai Lulus: ${questionnaire.passingScore}%',
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Instructions Banner ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Petunjuk & Instruksi Pengerjaan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InstructionPoint(
                        number: '1',
                        text: 'Bacalah setiap pertanyaan dengan saksama.',
                      ),
                      const SizedBox(height: 8),
                      _InstructionPoint(
                        number: '2',
                        text:
                            'Pilihlah salah satu jawaban yang paling tepat menurut Anda.',
                      ),
                      const SizedBox(height: 8),
                      _InstructionPoint(
                        number: '3',
                        text:
                            'Nilai dan pembahasan jawaban akan ditampilkan secara otomatis setelah Anda menekan tombol Selesai.',
                      ),
                      const SizedBox(height: 8),
                      _InstructionPoint(
                        number: '4',
                        text: questionnaire.isPreTest
                            ? 'Pre-Test ini wajib diselesaikan 1x sebelum menggunakan aplikasi.'
                            : 'Anda dapat mengerjakan ulang Post-Test ini kapan saja untuk mengasah pemahaman.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Question Categories Section (Pre-Test Only) ─────────────────
                if (questionnaire.isPreTest && questionnaire.categories.isNotEmpty) ...[
                  Text(
                    'Kategori Pertanyaan',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final cat in questionnaire.categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CategoryRow(
                        title: cat.title,
                        questionCount: cat.questions.length,
                        description: cat.description,
                      ),
                    ),
                ],
              ],
            ),
          ),

          // ── Fixed Bottom CTA Button ─────────────────────────────────
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuestionnaireQuestionsScreen(
                          questionnaire: questionnaire,
                          isPreTest: questionnaire.isPreTest,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 22),
                  label: Text(
                    'Mulai Mengerjakan',
                    style: AppTextStyles.poppinsButton.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Instruction Point Widget ──────────────────────────────────────────────────

class _InstructionPoint extends StatelessWidget {
  const _InstructionPoint({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              fontSize: 13,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.title,
    required this.questionCount,
    required this.description,
  });

  final String title;
  final int questionCount;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$questionCount',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
