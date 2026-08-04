import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/survey_model.dart';
import '../viewmodels/survey_notifier.dart';
import 'survey_questions_screen.dart';

class SurveyCardSection extends ConsumerWidget {
  const SurveyCardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(activeSurveysProvider);

    return surveysAsync.when(
      loading: () => const _SurveyLoadingSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (surveys) {
        if (surveys.isEmpty) {
          return const _SurveyEmptyState();
        }

        return Column(
          children: surveys
              .map(
                (survey) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SingleSurveyCard(survey: survey),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SingleSurveyCard extends StatelessWidget {
  final SurveyModel survey;

  const _SingleSurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    final isSUS = survey.isSUS;
    final hasSubmitted = survey.hasSubmitted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: hasSubmitted ? Colors.teal.shade50.withValues(alpha: 0.3) : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: hasSubmitted
              ? Colors.teal.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasSubmitted ? Colors.teal : AppColors.primary).withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: hasSubmitted
                      ? Colors.teal.shade100
                      : isSUS
                          ? Colors.blue.withValues(alpha: 0.1)
                          : AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  hasSubmitted
                      ? '✓ SUDAH DIISI'
                      : isSUS
                          ? 'SURVEY SUS'
                          : 'SURVEY KEPUASAN',
                  style: AppTextStyles.labelSm.copyWith(
                    color: hasSubmitted
                        ? Colors.teal.shade800
                        : isSUS
                            ? Colors.blue[800]
                            : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            survey.title,
            style: AppTextStyles.titleLg.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          if (survey.description != null && survey.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              survey.description!,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: hasSubmitted
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SurveyQuestionsScreen(survey: survey),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSubmitted ? Colors.teal.shade50 : AppColors.primary,
                foregroundColor: hasSubmitted ? Colors.teal.shade700 : AppColors.onPrimary,
                disabledBackgroundColor: Colors.teal.shade50,
                disabledForegroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: hasSubmitted ? BorderSide(color: Colors.teal.shade200) : BorderSide.none,
                ),
              ),
              icon: Icon(
                hasSubmitted ? Icons.check_circle_rounded : Icons.assignment_turned_in_rounded,
                size: 20,
                color: hasSubmitted ? Colors.teal.shade600 : AppColors.onPrimary,
              ),
              label: Text(
                hasSubmitted ? 'Sudah Selesai Diisi' : 'Mulai Survey',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasSubmitted ? Colors.teal.shade800 : AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyEmptyState extends StatelessWidget {
  const _SurveyEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 40,
            color: AppColors.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Belum Ada Survey Penelitian',
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Survey akhir periode akan ditampilkan di sini jika telah dipublikasikan oleh administrator.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SurveyLoadingSkeleton extends StatelessWidget {
  const _SurveyLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
