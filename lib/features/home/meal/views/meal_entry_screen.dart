import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../viewmodels/home_dashboard_notifier.dart';
import '../models/food_item.dart';
import '../viewmodels/meal_entry_notifier.dart';
import '../widgets/food_card.dart';
import '../widgets/food_detail_sheet.dart';
import '../widgets/food_skeleton.dart';

class MealTypeOption {
  final String label;
  final IconData icon;

  const MealTypeOption({required this.label, required this.icon});
}

class MealEntryScreen extends ConsumerStatefulWidget {
  const MealEntryScreen({super.key});

  static const mealTypes = [
    MealTypeOption(label: 'Sarapan', icon: Icons.free_breakfast_outlined),
    MealTypeOption(label: 'Makan Siang', icon: Icons.lunch_dining_outlined),
    MealTypeOption(label: 'Makan Malam', icon: Icons.dinner_dining_outlined),
    MealTypeOption(label: 'Cemilan', icon: Icons.cookie_outlined),
  ];

  @override
  ConsumerState<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends ConsumerState<MealEntryScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always reset selection when entering the screen to start fresh from 0
      ref.read(mealEntryProvider.notifier).resetSelection();
    });
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
                          for (final type in MealEntryScreen.mealTypes) ...[
                            _MealTypeTab(
                              label: type.label,
                              icon: type.icon,
                              isSelected: state.selectedMealType == type.label,
                              onTap: () => notifier.setMealType(type.label),
                            ),
                            if (type != MealEntryScreen.mealTypes.last)
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
                            for (final search in state.recentSearches.take(4))
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
            onViewDetails: state.selectedFoodIds.isNotEmpty
                ? () => _showSelectedFoodsSheet(context, ref)
                : null,
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

              final dashState = ref.read(homeDashboardProvider).valueOrNull;
              final currentConsumed = dashState?.consumedCalories ?? 0;
              final target = dashState?.dailyCalorieTarget ?? 2000;
              final isTargetMetOrExceeded = target > 0 && (currentConsumed + state.totalCalories) >= target;

              final success = await notifier.saveMealLogs();
              if (context.mounted) {
                final message = success
                    ? (isTargetMetOrExceeded
                        ? 'Catatan berhasil disimpan! Asupan kalori Anda hari ini telah mencapai target. Pastikan cukup minum air putih dan pertimbangkan aktivitas fisik ringan (seperti jalan santai 15 menit) untuk membantu menjaga stabilitas gula darah.'
                        : 'Log makanan berhasil disimpan!')
                    : 'Gagal menyimpan log makanan.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: isTargetMetOrExceeded ? 5 : 3),
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

  void _showSelectedFoodsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectedFoodsSheet(
        onEditFood: (food) {
          Navigator.of(ctx).pop();
          _onFoodAddPressed(context, ref, food);
        },
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
        onAddToLog: (multiplier) => notifier.addFoodToLog(food.id, multiplier),
      );
    }
  }
}

class _MealTypeTab extends StatelessWidget {
  const _MealTypeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLg.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
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
    this.onViewDetails,
  });

  final int totalCalories;
  final int selectedCount;
  final VoidCallback onSave;
  final VoidCallback? onViewDetails;

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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                GestureDetector(
                  onTap: onViewDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedCount > 0
                          ? AppColors.primaryContainer.withValues(alpha: 0.25)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedCount > 0
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'DIPILIH',
                              style: AppTextStyles.labelMd.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: selectedCount > 0 ? AppColors.primary : AppColors.outline,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$selectedCount makanan',
                              style: AppTextStyles.labelLg.copyWith(
                                color: selectedCount > 0 ? AppColors.primary : AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (selectedCount > 0) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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

class _SelectedFoodsSheet extends ConsumerWidget {
  const _SelectedFoodsSheet({required this.onEditFood});

  final void Function(FoodItem food) onEditFood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealEntryProvider);
    final notifier = ref.read(mealEntryProvider.notifier);
    final selectedFoods = state.selectedFoods;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Makanan Terpilih (${selectedFoods.length})',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sesi: ${state.selectedMealType}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    notifier.resetSelection();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: selectedFoods.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final food = selectedFoods[index];
                  final multiplier = state.foodPortionMultipliers[food.id] ?? 1.0;
                  final calories = (food.energyKcal * multiplier).round();
                  final portionDesc = food.isPer100g
                      ? '${(multiplier * 100).round()} gram'
                      : '${multiplier == multiplier.roundToDouble() ? multiplier.toInt() : multiplier.toStringAsFixed(1)} porsi (${food.servingSize})';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: AppTextStyles.labelLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (food.manufacturer.trim().isNotEmpty &&
                                  food.manufacturer.trim().toLowerCase() != 'tidak diketahui' &&
                                  food.manufacturer.trim().toLowerCase() != 'tidak ada' &&
                                  food.manufacturer.trim() != '-') ...[
                                Text(
                                  food.manufacturer.trim(),
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                '$portionDesc · $calories kcal',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit portion button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                          onPressed: () => onEditFood(food),
                          tooltip: 'Ubah porsi',
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                          onPressed: () {
                            notifier.removeFoodFromLog(food.id);
                            if (state.selectedFoodIds.length <= 1) {
                              Navigator.of(context).pop();
                            }
                          },
                          tooltip: 'Hapus dari pilihan',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
