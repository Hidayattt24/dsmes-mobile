import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../models/onboarding_form_state.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step19Summary extends ConsumerWidget {
  const Step19Summary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CelebrationHeader(),
        const SizedBox(height: AppSpacing.lg),
        _CalorieCard(state: state),
        const SizedBox(height: AppSpacing.lg),

        _PersonalSummary(state: state),
        const SizedBox(height: AppSpacing.lg),
        const _HealthRecommendations(),
        const SizedBox(height: AppSpacing.lg),
        const _NextStepsCard(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppStrings.step13CelebrationTitle,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppStrings.step13CelebrationSubtitle,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _CalorieCard extends StatelessWidget {
  const _CalorieCard({required this.state});

  final OnboardingFormState state;

  @override
  Widget build(BuildContext context) {
    final res = state.calorieResult;
    final int tdee = res != null
        ? ((res['daily_calorie_target'] as num?)?.toInt() ?? (res['tdee'] as num?)?.toInt() ?? 2150)
        : 2150;
    final rec = res?['recommendations'] as Map<String, dynamic>?;

    Map<String, dynamic> getRecDetail(String key) {
      if (rec != null && rec.containsKey(key)) {
        final val = rec[key];
        if (val is Map) {
          return Map<String, dynamic>.from(val);
        }
      }
      return {};
    }

    final maintainData = getRecDetail('maintain');
    final mildLossData = getRecDetail('mild_loss');
    final weightLossData = getRecDetail('weight_loss');
    final extremeLossData = getRecDetail('extreme_loss');

    final maintainCal = maintainData['calories'] as int? ?? tdee;
    final mildCal = mildLossData['calories'] as int? ?? (tdee - 250);
    final weightCal = weightLossData['calories'] as int? ?? (tdee - 500);
    final extremeCal = extremeLossData['calories'] as int? ?? (tdee - 1000);

    final formatter = NumberFormat('#,###', 'id_ID');

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      color: AppColors.primaryContainer,
      borderColor: AppColors.primaryContainer,
      hasBorder: false,
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 36,
            color: AppColors.onPrimary.withValues(alpha: 0.9),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.step13CalorieTitle,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            formatter.format(tdee),
            style: GoogleFonts.poppins(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.step13CalorieUnit,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          if (res != null && (res.containsKey('bmi') || res.containsKey('bmi_category'))) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    color: AppColors.onPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'BMI: ${(res['bmi'] as num?)?.toStringAsFixed(1) ?? ''} • ${res['bmi_category'] ?? ''}',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 48,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.step13CalorieNote,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _TargetCalorieRow(
                  label: 'Pertahankan BB',
                  calories: '${formatter.format(maintainCal)} kcal/hari',
                  percentage: '100%',
                ),
                const Divider(color: Colors.white24, height: 16),
                _TargetCalorieRow(
                  label: 'Turun BB Ringan',
                  calories: '${formatter.format(mildCal)} kcal/hari',
                  percentage: '${mildLossData['percentage'] ?? 90}%',
                ),
                const Divider(color: Colors.white24, height: 16),
                _TargetCalorieRow(
                  label: 'Turun BB Sedang',
                  calories: '${formatter.format(weightCal)} kcal/hari',
                  percentage: '${weightLossData['percentage'] ?? 80}%',
                ),
                const Divider(color: Colors.white24, height: 16),
                _TargetCalorieRow(
                  label: 'Turun BB Ekstrem',
                  calories: '${formatter.format(extremeCal)} kcal/hari',
                  percentage: '${extremeLossData['percentage'] ?? 60}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetCalorieRow extends StatelessWidget {
  const _TargetCalorieRow({
    required this.label,
    required this.calories,
    required this.percentage,
  });

  final String label;
  final String calories;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              calories,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            percentage,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonalSummary extends StatelessWidget {
  const _PersonalSummary({required this.state});

  final OnboardingFormState state;

  @override
  Widget build(BuildContext context) {
    final birthDate = state.birthDate;
    final birthText =
        birthDate != null
            ? DateFormat('dd MMMM yyyy', 'id').format(birthDate)
            : '-';

    final items = [
      (Icons.person_outline, AppStrings.step13LabelName, state.fullName),
      (
        Icons.badge_outlined,
        AppStrings.step13LabelNickname,
        state.nickname.isEmpty ? '-' : state.nickname,
      ),
      (Icons.email_outlined, AppStrings.step13LabelEmail, state.email),
      (
        Icons.phone_outlined,
        AppStrings.step13LabelPhone,
        '+62${state.phoneNumber}',
      ),
      (Icons.wc, AppStrings.step13LabelGender, state.gender ?? '-'),
      (Icons.cake_outlined, AppStrings.step13LabelBirthDate, birthText),
      (
        Icons.bloodtype_outlined,
        AppStrings.step13LabelBloodType,
        state.bloodType ?? '-',
      ),
      (
        Icons.height,
        AppStrings.step13LabelHeight,
        state.heightCm.isEmpty ? '-' : '${state.heightCm} cm',
      ),
      (
        Icons.monitor_weight_outlined,
        AppStrings.step13LabelWeight,
        state.weightKg.isEmpty ? '-' : '${state.weightKg} kg',
      ),
      (
        Icons.directions_run,
        AppStrings.step13LabelActivity,
        state.activityLevel ?? '-',
      ),
      (
        Icons.home_outlined,
        AppStrings.summaryLabelAddress,
        state.address.isEmpty ? '-' : state.address,
      ),
      (
        Icons.location_on_outlined,
        AppStrings.summaryLabelDistrict,
        state.district.isEmpty ? '-' : state.district,
      ),
      (
        Icons.local_hospital_outlined,
        AppStrings.summaryLabelFacility,
        state.healthFacility.isEmpty ? '-' : state.healthFacility,
      ),
      (
        Icons.people_outline,
        AppStrings.summaryLabelLiving,
        state.livingArrangement ?? '-',
      ),
      (
        Icons.menu_book_outlined,
        AppStrings.summaryLabelEducation,
        state.educationLevel ?? '-',
      ),
      (
        Icons.bloodtype_rounded,
        AppStrings.summaryLabelDiabetesDuration,
        state.diabetesDuration ?? '-',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.assignment_rounded,
          title: AppStrings.step13SummaryTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: List.generate(items.length, (i) {
              final (icon, label, value) = items[i];
              final showBorder = i < items.length - 1;
              return _InfoRow(
                icon: icon,
                label: label,
                value: value,
                showBorder: showBorder,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showBorder = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration:
          showBorder
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
              )
              : null,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }
}

class _HealthRecommendations extends StatelessWidget {
  const _HealthRecommendations();

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      (
        Icons.local_fire_department_rounded,
        AppStrings.step13RecCalories,
        AppStrings.step13RecCaloriesValue,
        AppColors.error,
      ),
      (
        Icons.monitor_weight_outlined,
        AppStrings.step13RecWeight,
        AppStrings.step13RecWeightValue,
        AppColors.tertiary,
      ),
      (
        Icons.directions_run,
        AppStrings.step13RecActivity,
        AppStrings.step13RecActivityValue,
        AppColors.secondary,
      ),
      (
        Icons.water_drop_rounded,
        AppStrings.step13RecHydration,
        AppStrings.step13RecHydrationValue,
        AppColors.primary,
      ),
      (
        Icons.restaurant_rounded,
        AppStrings.step13RecEating,
        AppStrings.step13RecEatingValue,
        AppColors.tertiary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.favorite_rounded,
          title: AppStrings.step13RecommendationTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: List.generate(recommendations.length, (i) {
              final (icon, title, desc, color) = recommendations[i];
              final showBorder = i < recommendations.length - 1;
              return _RecommendationItem(
                icon: icon,
                title: title,
                description: desc,
                color: color,
                showBorder: showBorder,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  const _RecommendationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.showBorder = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration:
          showBorder
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
              )
              : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.bloodtype_rounded,
        AppColors.error,
        AppStrings.step13NextStepBloodSugar,
        AppStrings.step13NextStepBloodSugarDesc,
      ),
      (
        Icons.restaurant_rounded,
        AppColors.tertiary,
        AppStrings.step13NextStepMeals,
        AppStrings.step13NextStepMealsDesc,
      ),
      (
        Icons.directions_run,
        AppColors.secondary,
        AppStrings.step13NextStepActivity,
        AppStrings.step13NextStepActivityDesc,
      ),
      (
        Icons.article_rounded,
        AppColors.primary,
        AppStrings.step13NextStepEducation,
        AppStrings.step13NextStepEducationDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.flag_rounded,
          title: AppStrings.step13NextStepsTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: List.generate(steps.length, (i) {
              final (icon, color, title, desc) = steps[i];
              final showBorder = i < steps.length - 1;
              return _NextStepItem(
                icon: icon,
                color: color,
                title: title,
                description: desc,
                showBorder: showBorder,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _NextStepItem extends StatelessWidget {
  const _NextStepItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.showBorder = true,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration:
          showBorder
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
              )
              : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: color.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
