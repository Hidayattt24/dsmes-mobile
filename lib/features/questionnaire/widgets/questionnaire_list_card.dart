import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/questionnaire_repository.dart';
import '../models/questionnaire_detail_model.dart';
import '../viewmodels/questionnaire_notifier.dart';
import '../views/questionnaire_detail_screen.dart';
import '../views/questionnaire_result_screen.dart';
import '../views/questionnaire_review_screen.dart';

/// Single dynamic questionnaire card.
///
/// Renders one of two states driven entirely by backend data:
/// - [PatientQuestionnaireItemModel.isCompleted] → "Selesai" badge + "Lihat Hasil"
/// - otherwise → "Mulai Kuesioner" primary button
class QuestionnaireListCard extends ConsumerWidget {
  const QuestionnaireListCard({super.key, required this.item});

  final PatientQuestionnaireItemModel item;

  String get _subtitle {
    final parts = <String>['${item.questionCount} Soal'];
    if (item.educationTitle != null && item.educationTitle!.isNotEmpty) {
      parts.add(item.educationTitle!);
    }
    return parts.join(' · ');
  }

  Color get _accent => item.isPreTest ? AppColors.primary : AppColors.secondary;

  Future<void> _startQuestionnaire(BuildContext context, WidgetRef ref) async {
    try {
      final detail = await ref
          .read(questionnaireRepositoryProvider)
          .getQuestionnaireById(item.id);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionnaireDetailScreen(questionnaire: detail),
        ),
      );
      ref.invalidate(questionnaireListProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat kuesioner. Silakan coba lagi.'),
        ),
      );
    }
  }

  void _viewResult(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) =>
                item.isPreTest
                    ? QuestionnaireResultScreen(
                      questionnaireId: item.id,
                      questionnaireTitle: item.title,
                      isPreTest: true,
                    )
                    : QuestionnaireReviewScreen(
                      questionnaireId: item.id,
                      quizTitle: item.title,
                    ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accent;
    final isCompleted = item.isCompleted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: accent.withValues(alpha: isCompleted ? 0.3 : 0.55),
          width: 1.2,
        ),
        boxShadow: AppShadows.soft,
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
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.isPreTest
                      ? Icons.assignment_rounded
                      : Icons.quiz_rounded,
                  color: accent,
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
                      _subtitle,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCompleted && item.score != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: _ScoreBadge(score: item.score!, accent: accent),
                ),
              ],
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                isCompleted
                    ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _viewResult(context),
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                      label: Text(
                        'Lihat Hasil',
                        style: AppTextStyles.poppinsButton.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: accent,
                        ),
                      ),
                    )
                    : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _startQuestionnaire(context, ref),
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Mulai Kuesioner',
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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.accent});

  final int score;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Skor: $score',
        style: AppTextStyles.labelMd.copyWith(
          fontWeight: FontWeight.bold,
          color: accent,
          fontSize: 13,
        ),
      ),
    );
  }
}
