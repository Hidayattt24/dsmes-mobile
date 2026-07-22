import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../education/views/education_detail_screen.dart';
import '../data/questionnaire_mock_data.dart';
import '../models/questionnaire.dart';
import '../widgets/empty_questionnaire.dart';
import '../widgets/questionnaire_card.dart';
import '../widgets/questionnaire_category_filter.dart';
import '../widgets/questionnaire_progress_card.dart';
import 'questionnaire_detail_screen.dart';
import 'questionnaire_result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startQuestionnaire(Questionnaire questionnaire) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionnaireDetailScreen(questionnaireId: questionnaire.id),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _viewResult(Questionnaire questionnaire) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionnaireResultScreen(
          questionnaireId: questionnaire.id,
          scorePercentage: questionnaire.scorePercentage ?? 85.0,
          correctCount: (questionnaire.questionCount * 0.85).round(),
          totalQuestions: questionnaire.questionCount,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _openEducationMaterial() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EducationDetailScreen(articleId: 'art_featured'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestionnaires = MockQuestionnaireData.filterQuestionnaires(
      query: _searchQuery,
      category: _selectedCategory,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Hero Title Section
            Text(
              'Kuesioner Pemahaman',
              style: AppTextStyles.headlineLg.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Uji dan evaluasi mandiri pemahaman diabetes Anda.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Analytics Dashboard Card
            QuestionnaireProgressCard(
              completedCount: MockQuestionnaireData.completedCount,
              uncompletedCount: MockQuestionnaireData.uncompletedCount,
              averageScore: MockQuestionnaireData.averageScore,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search Bar Input
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari topik kuesioner...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.outline,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category Filter Chips
            QuestionnaireCategoryFilter(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Questionnaire Cards List
            if (filteredQuestionnaires.isEmpty)
              EmptyQuestionnaireWidget(
                onResetTap: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'Semua';
                    _searchController.clear();
                  });
                },
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredQuestionnaires.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final questionnaire = filteredQuestionnaires[index];
                  return QuestionnaireCard(
                    questionnaire: questionnaire,
                    onStartTap: () => _startQuestionnaire(questionnaire),
                    onViewResultTap: () => _viewResult(questionnaire),
                    onReadMaterialTap: questionnaire.id == 'q_3'
                        ? _openEducationMaterial
                        : null,
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
