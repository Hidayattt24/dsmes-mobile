import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/education_mock_data.dart';
import '../models/education_article.dart';
import '../widgets/education_card.dart';
import '../widgets/education_category_filter.dart';
import '../widgets/education_search_bar.dart';
import 'education_detail_screen.dart';

class AllArticlesScreen extends StatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedSortBy = 'Terbaru';

  final List<String> _sortOptions = ['Terbaru', 'Terpopuler', 'Durasi'];

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
    );
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
              ? 'Artikel disimpan di Markah Buku'
              : 'Artikel dihapus dari Markah Buku',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = MockEducationData.filterArticles(
      query: _searchQuery,
      category: _selectedCategory,
      sortBy: _selectedSortBy,
    );

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
          'Semua Artikel Edukasi',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Search Bar
            EducationSearchBar(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Horizontal Scrollable Category Filter
            EducationCategoryFilter(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Sorting Selector Row
            Row(
              children: [
                Text(
                  'Urutkan:',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  children: _sortOptions.map((opt) {
                    final isSelected = _selectedSortBy == opt;
                    return ChoiceChip(
                      label: Text(opt),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: AppTextStyles.labelMd.copyWith(
                        fontSize: 12,
                        color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedSortBy = opt);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Results count label
            Text(
              'Menampilkan ${filteredArticles.length} artikel',
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Article List
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
