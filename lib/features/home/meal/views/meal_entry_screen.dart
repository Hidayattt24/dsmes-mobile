import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/food_item.dart';
import '../viewmodels/meal_entry_notifier.dart';
import '../widgets/food_card.dart';
import '../widgets/food_detail_sheet.dart';
import '../widgets/food_skeleton.dart';

class MealEntryScreen extends ConsumerStatefulWidget {
  const MealEntryScreen({super.key});

  static const _mealTypes = ['Sarapan', 'Makan Siang', 'Makan Malam'];

  @override
  ConsumerState<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends ConsumerState<MealEntryScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(mealEntryProvider.notifier).fetchFoods(isRefresh: false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealEntryProvider);
    final notifier = ref.read(mealEntryProvider.notifier);
    final foods = state.recommendedFoods;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Log Makanan',
          style: AppTextStyles.headlineMdMobile.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Meal Type Tabs ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final type in MealEntryScreen._mealTypes) ...[
                            _MealTypeTab(
                              label: type,
                              isSelected: state.selectedMealType == type,
                              onTap: () => notifier.setMealType(type),
                            ),
                            if (type != MealEntryScreen._mealTypes.last)
                              const SizedBox(width: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Search Bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: TextField(
                        onChanged: notifier.setSearchQuery,
                        style: AppTextStyles.bodyLg,
                        decoration: InputDecoration(
                          hintText: 'Cari makanan atau minuman...',
                          hintStyle: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.outline,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.outline,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Recent Searches ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pencatatan Terakhir',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final search in state.recentSearches)
                              GestureDetector(
                                onTap: () => notifier.selectRecentSearch(search),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                  child: Text(
                                    search,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Food Recommendation List ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Rekomendasi Makanan Sehat',
                      style: AppTextStyles.headlineMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: state.isLoading
                        ? ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) => const FoodSkeleton(),
                          )
                        : foods.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(32),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 48,
                                      color: AppColors.outline,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Makanan tidak ditemukan',
                                      style: AppTextStyles.labelLg.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Coba kata kunci pencarian yang lain.',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: foods.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final food = foods[index];
                                      return FoodCard(
                                        food: food,
                                        isSelected: state.selectedFoodIds
                                            .contains(food.id),
                                        onAddPressed: () => _onFoodAddPressed(
                                          context,
                                          ref,
                                          food,
                                        ),
                                      );
                                    },
                                  ),
                                  if (state.isMoreLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                  ),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),

          // ── Sticky Footer ──────────────────────────────────────────────
          _StickyFooter(
            totalCalories: state.totalCalories,
            selectedCount: state.selectedFoodIds.length,
            onSave: () async {
              if (state.selectedFoodIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih minimal satu makanan terlebih dahulu'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              final success = await notifier.saveMealLogs();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Log makanan berhasil disimpan!'
                          : 'Gagal menyimpan log makanan.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _onFoodAddPressed(BuildContext context, WidgetRef ref, FoodItem food) {
    final notifier = ref.read(mealEntryProvider.notifier);

    if (ref.read(mealEntryProvider).selectedFoodIds.contains(food.id)) {
      notifier.removeFoodFromLog(food.id);
    } else {
      showFoodDetailSheet(
        context: context,
        food: food,
        onAddToLog: () => notifier.addFoodToLog(food.id),
      );
    }
  }
}

class _MealTypeTab extends StatelessWidget {
  const _MealTypeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLg.copyWith(
            color:
                isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.totalCalories,
    required this.selectedCount,
    required this.onSave,
  });

  final int totalCalories;
  final int selectedCount;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1400695C),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASUPAN HARI INI',
                      style: AppTextStyles.labelMd.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.outline,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCalories kcal',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DIPILIH',
                      style: AppTextStyles.labelMd.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.outline,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$selectedCount makanan',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 4,
                  shadowColor: AppColors.shadowPrimary.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onSave,
                child: Text(
                  'Simpan Log Makanan',
                  style: AppTextStyles.poppinsButton.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
