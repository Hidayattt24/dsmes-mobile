import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/quiz_attempt_model.dart';
import '../views/questionnaire_review_screen.dart';

/// Grouped questionnaire attempt history, grouped by questionnaire module.
class QuestionnaireHistorySection extends StatelessWidget {
  const QuestionnaireHistorySection({super.key, required this.history});

  final List<MyHistoryItemModel> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_toggle_off_rounded,
                color: AppColors.outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada riwayat pengerjaan kuesioner.',
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group history items by questionnaireId
    final Map<String, List<MyHistoryItemModel>> grouped = {};
    for (final item in history) {
      grouped.putIfAbsent(item.questionnaireId, () => []).add(item);
    }

    return Column(
      children: [
        for (final entry in grouped.entries) ...[
          _ModuleHistoryCard(attempts: entry.value),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ModuleHistoryCard extends StatefulWidget {
  const _ModuleHistoryCard({required this.attempts});

  final List<MyHistoryItemModel> attempts;

  @override
  State<_ModuleHistoryCard> createState() => _ModuleHistoryCardState();
}

class _ModuleHistoryCardState extends State<_ModuleHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.attempts.isEmpty) {
      return const SizedBox.shrink();
    }
    final latest = widget.attempts.first;
    final total = widget.attempts.length;
    final highestScore =
        widget.attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
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
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: latest.passed
                        ? const Color(0xFFABF4AC)
                        : const Color(0xFFFFDAD6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${latest.score}',
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: latest.passed
                            ? const Color(0xFF07521D)
                            : const Color(0xFF93000A),
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
                        latest.questionnaireTitle,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total $total Percobaan · Skor Tertinggi: $highestScore%',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // Collapsible list of attempt entries
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  for (int i = 0; i < widget.attempts.length; i++) ...[
                    _AttemptSubItemRow(
                      attempt: widget.attempts[i],
                      attemptIndex: widget.attempts.length - i,
                    ),
                    if (i < widget.attempts.length - 1)
                      const Divider(height: 16),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Default single attempt row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terakhir: ${DateFormat('d MMM yyyy', 'id').format(latest.completedAt.toLocal())}',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuestionnaireReviewScreen(
                            questionnaireId: latest.questionnaireId,
                            quizTitle: latest.questionnaireTitle,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Hasil',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
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

class _AttemptSubItemRow extends StatelessWidget {
  const _AttemptSubItemRow({
    required this.attempt,
    required this.attemptIndex,
  });

  final MyHistoryItemModel attempt;
  final int attemptIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#$attemptIndex',
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skor: ${attempt.score}% (${attempt.passed ? "Lulus" : "Gagal"})',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: attempt.passed
                      ? const Color(0xFF07521D)
                      : const Color(0xFF93000A),
                ),
              ),
              Text(
                DateFormat('d MMM yyyy · HH:mm', 'id')
                    .format(attempt.completedAt.toLocal()),
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: const Size(0, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuestionnaireReviewScreen(
                  questionnaireId: attempt.questionnaireId,
                  quizTitle: attempt.questionnaireTitle,
                ),
              ),
            );
          },
          child: Text(
            'Lihat Hasil',
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
