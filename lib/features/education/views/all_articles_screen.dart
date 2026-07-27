import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/education_article.dart';
import '../viewmodels/education_notifier.dart';
import '../widgets/education_card.dart';
import '../widgets/education_category_filter.dart';
import '../widgets/education_search_bar.dart';
import '../widgets/education_skeleton.dart';
import 'education_detail_screen.dart';

class AllArticlesScreen extends ConsumerStatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  ConsumerState<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends ConsumerState<AllArticlesScreen> {
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
    ).then((_) {
      ref.invalidate(educationListProvider);
      ref.invalidate(savedArticlesProvider);
    });
  }

  Future<void> _toggleBookmark(String articleId) async {
    try {
      await ref.read(educationListProvider.notifier).toggleBookmark(articleId);
      final list = ref.read(educationListProvider).value ?? [];
      final index = list.indexWhere((a) => a.id == articleId);
      final isSaved = index != -1 ? list[index].isBookmarked : false;
      if (mounted) {
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengubah bookmark. Coba lagi.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  List<EducationArticle> _applyFilters(List<EducationArticle> all) {
    var result = all.where((article) {
      final matchesQuery =
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              article.quoteText.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' ||
          article.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();

    switch (_selectedSortBy) {
      case 'Terpopuler':
        result.sort((a, b) => b.views.compareTo(a.views));
      case 'Durasi':
        // Parse "X menit" → int for sorting
        result.sort((a, b) {
          final aMin = int.tryParse(a.readTime.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bMin = int.tryParse(b.readTime.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return aMin.compareTo(bMin);
        });
      default: // 'Terbaru' — keep original order (already sorted by created_at DESC from backend)
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final educationListAsync = ref.watch(educationListProvider);
    final categoriesAsync = ref.watch(educationCategoriesProvider);

    final allArticles = educationListAsync.value ?? [];
    final categories = categoriesAsync.value ?? const ['Semua'];
    final filteredArticles = _applyFilters(allArticles);

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
        actions: [
          if (educationListAsync.isLoading && educationListAsync.hasValue)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(educationListProvider);
          ref.invalidate(educationCategoriesProvider);
        },
        child: educationListAsync.isLoading && !educationListAsync.hasValue
            ? const EducationScreenSkeleton()
            : educationListAsync.hasError && !educationListAsync.hasValue
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.outline),
                        const SizedBox(height: 16),
                        Text('Gagal memuat artikel',
                            style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(educationListProvider),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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

                        // Horizontal Scrollable Category Filter — dynamic from backend
                        EducationCategoryFilter(
                          selectedCategory: _selectedCategory,
                          categories: categories,
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
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _sortOptions.map((opt) {
                                    final isSelected = opt == _selectedSortBy;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(opt),
                                        selected: isSelected,
                                        selectedColor: AppColors.primary,
                                        checkmarkColor: Colors.white,
                                        labelStyle: AppTextStyles.labelMd.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.outlineVariant.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        onSelected: (val) {
                                          if (val) setState(() => _selectedSortBy = opt);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
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
                                  textAlign: TextAlign.center,
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

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
      ),
    );
  }
}
