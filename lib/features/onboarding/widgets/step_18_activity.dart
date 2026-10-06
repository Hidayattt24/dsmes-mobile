import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class ActivityLevelOption {
  final String title;
  final String emoji;
  final String description;
  final String example;

  const ActivityLevelOption({
    required this.title,
    required this.emoji,
    required this.description,
    required this.example,
  });
}

const activityLevelOptions = [
  ActivityLevelOption(
    title: AppStrings.step12Sedentary,
    emoji: AppStrings.step12SedentaryEmoji,
    description: AppStrings.step12SedentaryDesc,
    example: AppStrings.step12SedentaryExample,
  ),
  ActivityLevelOption(
    title: AppStrings.step12LightlyActive,
    emoji: AppStrings.step12LightlyActiveEmoji,
    description: AppStrings.step12LightlyActiveDesc,
    example: AppStrings.step12LightlyActiveExample,
  ),
  ActivityLevelOption(
    title: AppStrings.step12ModeratelyActive,
    emoji: AppStrings.step12ModeratelyActiveEmoji,
    description: AppStrings.step12ModeratelyActiveDesc,
    example: AppStrings.step12ModeratelyActiveExample,
  ),
  ActivityLevelOption(
    title: AppStrings.step12Active,
    emoji: AppStrings.step12ActiveEmoji,
    description: AppStrings.step12ActiveDesc,
    example: AppStrings.step12ActiveExample,
  ),
  ActivityLevelOption(
    title: AppStrings.step12VeryActive,
    emoji: AppStrings.step12VeryActiveEmoji,
    description: AppStrings.step12VeryActiveDesc,
    example: AppStrings.step12VeryActiveExample,
  ),
];

class Step18Activity extends ConsumerStatefulWidget {
  const Step18Activity({super.key});

  @override
  ConsumerState<Step18Activity> createState() => _Step18ActivityState();
}

class _Step18ActivityState extends ConsumerState<Step18Activity> {
  bool _isExpanded = false;

  ActivityLevelOption? _findOption(String? title) {
    if (title == null) return null;
    return activityLevelOptions.firstWhere(
      (opt) =>
          opt.title.trim().toLowerCase() == title.trim().toLowerCase() ||
          title.toLowerCase().contains(opt.title.toLowerCase()),
      orElse: () => activityLevelOptions[1], // Default: Ringan
    );
  }

  void _showDropdownBottomSheet(BuildContext context, String? currentSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDropdownBottomSheet(
        selectedTitle: currentSelected,
        onSelect: (opt) {
          ref.read(onboardingProvider.notifier).onActivitySelected(opt.title);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);
    final selectedTitle = ref.watch(onboardingProvider.select((s) => s.activityLevel));
    final selectedOpt = _findOption(selectedTitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.directions_run,
          question: AppStrings.step12Title,
          description: AppStrings.step12Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Modern Dropdown Trigger Button
        InkWell(
          onTap: () => _showDropdownBottomSheet(context, selectedTitle),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selectedOpt != null
                  ? AppColors.primaryContainer.withValues(alpha: 0.25)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedOpt != null ? AppColors.primary : AppColors.outlineVariant,
                width: selectedOpt != null ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
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
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedOpt?.description ?? 'Klik untuk memilih level aktivitas...',
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Expanded Highlight Card for Selected Option (Shows Example clearly)
        if (selectedOpt != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Contoh Aktivitas:',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  selectedOpt.example,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Clean Quick Selector Chips below dropdown for fast access
        Text(
          'Pilihan Cepat:',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: activityLevelOptions.map((opt) {
              final isSelected = selectedOpt?.title == opt.title;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  avatar: Text(opt.emoji, style: const TextStyle(fontSize: 14)),
                  label: Text(opt.title),
                  labelStyle: AppTextStyles.labelSm.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerLow,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    notifier.onActivitySelected(opt.title);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActivityDropdownBottomSheet extends StatelessWidget {
  const _ActivityDropdownBottomSheet({
    required this.selectedTitle,
    required this.onSelect,
  });

  final String? selectedTitle;
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_run_rounded,
                    color: AppColors.primary,
                  ),
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

            // List of activity options
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                physics: const BouncingScrollPhysics(),
                itemCount: activityLevelOptions.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final opt = activityLevelOptions[index];
                  final isSelected = selectedTitle != null &&
                      (selectedTitle!.trim().toLowerCase() == opt.title.trim().toLowerCase() ||
                          selectedTitle!.toLowerCase().contains(opt.title.toLowerCase()));

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
