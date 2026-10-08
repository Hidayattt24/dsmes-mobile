import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

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
    'Cukup Baik',
    'Baik',
    'Sangat Bermanfaat',
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height - bottomInset - 48,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon Badge
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                'Beri Ulasan Materi',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              // Article Context Subtitle
              Text(
                'Bagaimana pendapat Anda tentang materi\n"${widget.articleTitle}"?',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 13.5,
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
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 38,
                            color:
                                isSelected
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),

              // Rating Label Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_ratingLabels[_rating - 1]} ($_rating/5)',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Note Input Header
              Text(
                'Pertanyaan atau Saran Tambahan (Opsional)',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              // Note Input Field
              TextField(
                controller: _noteController,
                maxLength: 500,
                maxLines: 3,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 13.5,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Tuliskan masukan atau hal yang ingin Anda tanyakan mengenai artikel ini...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.outline.withValues(alpha: 0.7),
                    fontSize: 12.5,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  counterStyle: AppTextStyles.labelSm.copyWith(
                    color: AppColors.outline,
                    fontSize: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Action Buttons Stacked (Spacious & Ergonomic)
              AppButton(
                label: 'Kirim Ulasan',
                icon: Icons.send_rounded,
                height: 50,
                variant: AppButtonVariant.primary,
                borderRadius: BorderRadius.circular(16),
                onPressed: () {
                  Navigator.of(context).pop({
                    'rating': _rating,
                    'note': _noteController.text.trim(),
                  });
                },
              ),
              const SizedBox(height: 8),

              AppButton(
                label: 'Lewati untuk sekarang',
                height: 44,
                variant: AppButtonVariant.text,
                borderRadius: BorderRadius.circular(16),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
