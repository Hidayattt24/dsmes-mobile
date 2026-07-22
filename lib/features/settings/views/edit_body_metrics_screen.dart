import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';

import '../viewmodels/settings_notifier.dart';
import '../widgets/activity_selector.dart';
import '../widgets/save_button.dart';

/// Screen allowing the user to edit height, weight, and activity level.
class EditBodyMetricsScreen extends ConsumerStatefulWidget {
  const EditBodyMetricsScreen({super.key});

  @override
  ConsumerState<EditBodyMetricsScreen> createState() =>
      _EditBodyMetricsScreenState();
}

class _EditBodyMetricsScreenState
    extends ConsumerState<EditBodyMetricsScreen> {
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late String _selectedActivity;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final current = ref.read(bodyMetricsProvider);
    _heightController =
        TextEditingController(text: current.heightCm.toInt().toString());
    _weightController =
        TextEditingController(text: current.weightKg.toInt().toString());
    _selectedActivity = current.activityLevel;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (height < 50 || height > 250) {
      AppSnackbar.showError(
          context, 'Masukkan tinggi badan yang valid (50 - 250 cm).');
      return;
    }

    if (weight < 20 || weight > 300) {
      AppSnackbar.showError(
          context, 'Masukkan berat badan yang valid (20 - 300 kg).');
      return;
    }

    ref.read(bodyMetricsProvider.notifier).updateBodyMetrics(
          heightCm: height,
          weightKg: weight,
          activityLevel: _selectedActivity,
        );

    // Navigate to RecalculateResultScreen
    context.push(RouteNames.recalculateResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Update Body Metrics',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header explanation card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.onPrimary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Perbarui indikator tubuh Anda untuk memperhitungkan kembali BMI dan target kalori harian.',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Input card for Height & Weight
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: AppRadius.card,
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengukuran Fisik',
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                // Height Field
                                Expanded(
                                  child: _MetricInputField(
                                    controller: _heightController,
                                    label: 'Tinggi Badan',
                                    unit: 'cm',
                                    icon: Icons.height_rounded,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                // Weight Field
                                Expanded(
                                  child: _MetricInputField(
                                    controller: _weightController,
                                    label: 'Berat Badan',
                                    unit: 'kg',
                                    icon: Icons.monitor_weight_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Activity Level Selector
                      ActivitySelector(
                        selectedActivity: _selectedActivity,
                        onActivitySelected: (activity) {
                          setState(() {
                            _selectedActivity = activity;
                          });
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Bottom Save Action Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: SaveButton(
                  onPressed: _onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricInputField extends StatelessWidget {
  const _MetricInputField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixText: unit,
            suffixStyle: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }
}
