import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/education_mock_data.dart';
import '../models/education_article.dart';
import '../widgets/education_card.dart';
import '../widgets/education_category_filter.dart';
import '../widgets/education_search_bar.dart';
import '../widgets/featured_article_card.dart';
import 'all_articles_screen.dart';
import 'education_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _activeTabIndex = 0; // 0 = Semua Artikel, 1 = Disimpan / Markah Buku
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(EducationArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EducationDetailScreen(articleId: article.id),
      ),
    ).then((_) {
      // Refresh state when returning to reflect bookmark changes
      setState(() {});
    });
  }

  void _navigateToAllArticles() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllArticlesScreen(),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _toggleBookmark(String articleId) {
    setState(() {
      MockEducationData.toggleBookmark(articleId);
    });
    final isSaved = MockEducationData.isBookmarked(articleId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved
              ? 'Artikel berhasil disimpan di Markah Buku'
              : 'Artikel dihapus dari Markah Buku',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkedArticles = MockEducationData.getBookmarkedArticles();
    final filteredArticles = MockEducationData.filterArticles(
      query: _searchQuery,
      category: _selectedCategory,
    );

    final featured = MockEducationData.featuredArticle;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Header Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edukasi Kesehatan',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informasi & artikel terpercaya untuk mengelola diabetes.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Segmented Tab Switcher: "Semua Artikel" vs "Disimpan (Markah Buku)"
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 0
                              ? AppColors.surfaceContainerLowest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeTabIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: _activeTabIndex == 0
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Semua Artikel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: _activeTabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _activeTabIndex == 0
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 1
                              ? AppColors.surfaceContainerLowest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeTabIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_rounded,
                              size: 18,
                              color: _activeTabIndex == 1
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Disimpan (${bookmarkedArticles.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: _activeTabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _activeTabIndex == 1
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tab 0: Semua Artikel Content
            if (_activeTabIndex == 0) ...[
              // Search Bar Section
              EducationSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Filter Chips (Horizontal Scrollable)
              EducationCategoryFilter(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Featured Article Banner (Show when no search filter active)
              if (_searchQuery.isEmpty && _selectedCategory == 'Semua') ...[
                FeaturedArticleCard(
                  article: featured,
                  onTap: () => _navigateToDetail(featured),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Article List Section Header with "Lihat Semua" Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pelajari Lebih Lanjut',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _navigateToAllArticles,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                    label: Text(
                      'Lihat Semua',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Vertical Article List
              if (filteredArticles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Artikel Tidak Ditemukan',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coba cari dengan kata kunci lain atau ubah kategori.',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredArticles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return EducationCard(
                      article: article,
                      onTap: () => _navigateToDetail(article),
                      onBookmarkTap: () => _toggleBookmark(article.id),
                    );
                  },
                ),
            ]
            // Tab 1: Disimpan (Markah Buku) Content
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Markah / Artikel Disimpan',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '${bookmarkedArticles.length} artikel',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (bookmarkedArticles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 40,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Belum Ada Artikel Disimpan',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tandai artikel yang ingin Anda baca kembali nanti dengan menekan ikon markah buku pada artikel.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => setState(() => _activeTabIndex = 0),
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text('Jelajahi Artikel Edukasi'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookmarkedArticles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final article = bookmarkedArticles[index];
                    return EducationCard(
                      article: article,
                      onTap: () => _navigateToDetail(article),
                      onBookmarkTap: () => _toggleBookmark(article.id),
                    );
                  },
                ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
