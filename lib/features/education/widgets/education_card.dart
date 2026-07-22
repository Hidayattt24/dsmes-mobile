import 'package:flutter/material.dart';

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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(
                          Icons.article_rounded,
                          color: AppColors.outline,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
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

                    // Read Status & Duration Row
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.readTime,
                          style: AppTextStyles.labelMd.copyWith(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        if (article.readStatus != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.outlineVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatusWidget(article)),
                        ],
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
