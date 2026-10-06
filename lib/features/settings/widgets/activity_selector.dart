import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../onboarding/widgets/step_18_activity.dart';

/// Reusable Activity Selector matching the onboarding activity card design with modern dropdown.
class ActivitySelector extends StatelessWidget {
  const ActivitySelector({
    super.key,
    required this.selectedActivity,
    required this.onActivitySelected,
  });

  final String selectedActivity;
  final ValueChanged<String> onActivitySelected;

  ActivityLevelOption? _findOption(String title) {
    return activityLevelOptions.firstWhere(
      (opt) =>
          opt.title.trim().toLowerCase() == title.trim().toLowerCase() ||
          title.toLowerCase().contains(opt.title.toLowerCase()),
      orElse: () => activityLevelOptions[1],
    );
  }

  void _showDropdownBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDropdownSheet(
        selectedTitle: selectedActivity,
        onSelect: (opt) {
          onActivitySelected(opt.title);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOpt = _findOption(selectedActivity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tingkat Aktivitas Fisik',
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih tingkat aktivitas harian Anda yang paling sesuai saat ini',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Dropdown Trigger Card
        InkWell(
          onTap: () => _showDropdownBottomSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      selectedOpt?.emoji ?? '🏃',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedOpt?.title ?? 'Pilih Aktivitas Harian',
                        style: AppTextStyles.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedOpt?.description ?? '',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        if (selectedOpt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Text(
                    'Contoh: ${selectedOpt.example}',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityDropdownSheet extends StatelessWidget {
  const _ActivityDropdownSheet({
    required this.selectedTitle,
    required this.onSelect,
  });

  final String selectedTitle;
  final ValueChanged<ActivityLevelOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_run_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pilih Level Aktivitas Harian',
                      style: AppTextStyles.labelLg.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                physics: const BouncingScrollPhysics(),
                itemCount: activityLevelOptions.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final opt = activityLevelOptions[index];
                  final isSelected = selectedTitle.trim().toLowerCase() == opt.title.trim().toLowerCase() ||
                      selectedTitle.toLowerCase().contains(opt.title.toLowerCase());

                  return InkWell(
                    onTap: () => onSelect(opt),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer.withValues(alpha: 0.3)
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(opt.emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  opt.title,
                                  style: AppTextStyles.labelLg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                                size: 22,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt.description,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text('💡 ', style: TextStyle(fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    'Contoh: ${opt.example}',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontSize: 11.5,
                                      color: AppColors.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
