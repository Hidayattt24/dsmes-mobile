import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class EducationReviewDialog extends StatefulWidget {
  const EducationReviewDialog({
    super.key,
    required this.articleTitle,
    this.initialRating = 5,
    this.initialNote = '',
  });

  final String articleTitle;
  final int initialRating;
  final String initialNote;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String articleTitle,
    int initialRating = 5,
    String initialNote = '',
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => EducationReviewDialog(
            articleTitle: articleTitle,
            initialRating: initialRating,
            initialNote: initialNote,
          ),
    );
  }

  @override
  State<EducationReviewDialog> createState() => _EducationReviewDialogState();
}

class _EducationReviewDialogState extends State<EducationReviewDialog> {
  late int _rating;
  late TextEditingController _noteController;

  static const List<String> _ratingLabels = [
    'Sangat Kurang',
    'Kurang',
    'Cukup',
    'Baik',
    'Sangat Baik',
  ];

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating.clamp(1, 5);
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon & Title
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ulasan Artikel Edukasi',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bagaimana pendapat Anda tentang materi "${widget.articleTitle}"?',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 5-Star Rating Selector
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isSelected = starValue <= _rating;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 36,
                        color:
                            isSelected
                                ? const Color(0xFFFFB800)
                                : const Color(0xFFCBD5E1),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${_ratingLabels[_rating - 1]} ($_rating/5)',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Optional Note Input
            Text(
              'Apakah ada hal yang ingin kamu tanyakan lebih lanjut? (Opsional)',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _noteController,
              maxLength: 500,
              maxLines: 3,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText:
                    'Bagikan pendapat atau saran Anda mengenai materi ini...',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.outline,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.poppinsButton.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'rating': _rating,
                        'note': _noteController.text.trim(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Kirim Ulasan',
                      style: AppTextStyles.poppinsButton.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
