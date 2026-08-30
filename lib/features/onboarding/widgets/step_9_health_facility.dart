import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step9HealthFacility extends ConsumerWidget {
  const Step9HealthFacility({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final selectedFacility =
        ref.watch(onboardingProvider.select((s) => s.healthFacility));
    final facilities =
        ref.watch(onboardingProvider.select((s) => s.healthFacilities));
    final isLoading =
        ref.watch(onboardingProvider.select((s) => s.isFacilityLoading));
    final isLoaded =
        ref.watch(onboardingProvider.select((s) => s.facilityLoaded));

    if (!isLoaded && !isLoading) {
      Future.microtask(notifier.loadHealthFacilities);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.local_hospital_outlined,
          question: AppStrings.healthFacilityTitle,
          description: AppStrings.healthFacilitySubtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.healthFacilityHint,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _FacilityPickerField(
          selected: selectedFacility,
          isLoading: isLoading,
          hasOptions: facilities.isNotEmpty,
          onTap: () => _showFacilityPicker(context, ref),
        ),
      ],
    );
  }

  Future<void> _showFacilityPicker(BuildContext context, WidgetRef ref) async {
    final facilities =
        ref.read(onboardingProvider.select((s) => s.healthFacilities));
    if (facilities.isEmpty) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FacilityPickerSheet(facilities: facilities),
    );

    if (selected != null) {
      ref.read(onboardingProvider.notifier).onHealthFacilityChanged(selected);
    }
  }
}

class _FacilityPickerField extends StatelessWidget {
  const _FacilityPickerField({
    required this.selected,
    required this.isLoading,
    required this.hasOptions,
    required this.onTap,
  });

  final String selected;
  final bool isLoading;
  final bool hasOptions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayText = isLoading
        ? AppStrings.healthFacilityLoading
        : selected.isEmpty
            ? AppStrings.healthFacilityHint
            : selected;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: AppTextStyles.bodyLg.copyWith(
                  color: selected.isEmpty
                      ? AppColors.outline
                      : AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(
                Icons.expand_more,
                color: AppColors.outline,
              ),
          ],
        ),
      ),
    );
  }
}

class _FacilityPickerSheet extends StatefulWidget {
  const _FacilityPickerSheet({required this.facilities});

  final List<String> facilities;

  @override
  State<_FacilityPickerSheet> createState() => _FacilityPickerSheetState();
}

class _FacilityPickerSheetState extends State<_FacilityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.facilities
        : widget.facilities
            .where((f) => f.toLowerCase().contains(query))
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              AppStrings.healthFacilityTitle,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: AppStrings.healthFacilitySearchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.healthFacilityEmpty,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final facility = filtered[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.local_hospital_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          facility,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(facility),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
