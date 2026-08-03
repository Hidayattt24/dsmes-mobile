import 'package:flutter/material.dart';

import '../../../../core/widgets/app_smart_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/education_article.dart';

class EducationCard extends StatelessWidget {
  const EducationCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmarkTap,
  });

  final EducationArticle article;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail Image (96x96 px)
              AppSmartImage(
                imageUrl: article.imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(20),
                fallbackIcon: Icons.article_rounded,
              ),
              const SizedBox(width: AppSpacing.md),

              // Article Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Author & Read Status Row
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMd.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          article.readTime,
                          style: AppTextStyles.labelMd.copyWith(
                            fontSize: 11.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bookmark Action Button
              if (onBookmarkTap != null)
                IconButton(
                  icon: Icon(
                    article.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: article.isBookmarked
                        ? AppColors.primary
                        : AppColors.outline,
                    size: 22,
                  ),
                  onPressed: onBookmarkTap,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(EducationArticle article) {
    if (article.isCompleted || article.readStatus == 'Selesai') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Selesai',
            style: AppTextStyles.labelMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      );
    } else if (article.readStatus == 'Sedang dibaca' && article.readProgress != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: article.readProgress,
          minHeight: 6,
          backgroundColor: AppColors.surfaceContainerHighest,
          color: AppColors.primary,
        ),
      );
    }

    return Text(
      article.readStatus ?? 'Belum dibaca',
      style: AppTextStyles.labelMd.copyWith(
        fontSize: 12,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
