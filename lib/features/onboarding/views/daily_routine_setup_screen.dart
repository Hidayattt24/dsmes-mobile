import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/info_card.dart';
import '../constants/routine_icons.dart';
import '../models/routine_model.dart';
import '../viewmodels/daily_routine_notifier.dart';
import '../viewmodels/onboarding_notifier.dart';
import '../widgets/icon_picker_bottom_sheet.dart';
import '../widgets/rename_routine_dialog.dart';
import '../widgets/routine_card.dart';

class DailyRoutineSetupScreen extends ConsumerWidget {
  const DailyRoutineSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyRoutineProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 0, AppSpacing.page, AppSpacing.md,
                ),
                child: _buildBody(context, ref, state),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(context, ref, bottomPadding),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppStrings.appName,
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DailyRoutineState state) {
    final notifier = ref.read(dailyRoutineProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          AppStrings.dailyRoutineTitle,
          style: AppTextStyles.headlineLg.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.dailyRoutineSubtitle,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoCard(text: AppStrings.dailyRoutineInfo),
        const SizedBox(height: AppSpacing.xl),

        ...List.generate(state.routines.length, (i) {
          final routine = state.routines[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < state.routines.length - 1 ? AppSpacing.md : 0,
            ),
            child: _buildRoutineCard(context, ref, routine, notifier),
          );
        }),

        const SizedBox(height: AppSpacing.xl),
        _buildAddRoutineButton(context, ref, notifier),
        const SizedBox(height: AppSpacing.xl),
        _buildReminderSection(context, ref, state),
      ],
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
    DailyRoutineNotifier notifier,
  ) {
    return RoutineCard(
      name: routine.name,
      iconName: routine.iconName,
      scheduleText: routine.scheduleText,
      customTimes: routine.customTimes,
      isPredefined: routine.isPredefined,
      onRenameTap: () => _onRename(context, ref, routine),
      onIconTap: () => _onChangeIcon(context, ref, routine),
      onTimeTap: (index) => _onTimeTap(context, ref, routine, index),
      onDeleteTime: (index) => notifier.removeCustomTime(routine.id, index),
      onAddTime: () => notifier.addCustomTime(routine.id),
      onDeleteRoutine: () => _onDeleteRoutine(context, ref, routine),
    );
  }

  Future<void> _onRename(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    final newName = await RenameRoutineDialog.show(context, routine.name);
    if (newName != null) {
      ref.read(dailyRoutineProvider.notifier).renameRoutine(routine.id, newName);
    }
  }

  Future<void> _onChangeIcon(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    final iconKey = await showIconPicker(context, currentKey: routine.iconName);
    if (iconKey != null) {
      ref.read(dailyRoutineProvider.notifier).changeIcon(routine.id, iconKey);
    }
  }

  Future<void> _onTimeTap(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
    int index,
  ) async {
    final current = routine.customTimes[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked != null) {
      ref
          .read(dailyRoutineProvider.notifier)
          .updateCustomTime(routine.id, index, picked);
    }
  }

  Future<bool> _onDeleteRoutine(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          AppStrings.routineConfirmDeleteTitle,
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          AppStrings.routineConfirmDeleteMessage,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppStrings.labelCancel,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.labelDelete,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(dailyRoutineProvider.notifier).deleteRoutine(routine.id);
    }
    return confirmed ?? false;
  }

  Widget _buildAddRoutineButton(
    BuildContext context,
    WidgetRef ref,
    DailyRoutineNotifier notifier,
  ) {
    return GestureDetector(
      onTap: () => _showAddRoutineSheet(context, ref, notifier),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.onPrimary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.dailyRoutineAddCustom,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoutineSheet(
    BuildContext context,
    WidgetRef ref,
    DailyRoutineNotifier notifier,
  ) {
    String name = '';
    String description = '';
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);
    final iconKey = ValueNotifier<String>('walk');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.dailyRoutineAddTitle,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: AppStrings.dailyRoutineNameLabel,
                      hintText: AppStrings.dailyRoutineNameHint,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: AppStrings.dailyRoutineDescHint,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    onChanged: (v) => description = v,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.dailyRoutineTimeLabel,
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: time,
                                );
                                if (picked != null) {
                                  setSheetState(() => time = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: AppRadius.card,
                                  color: AppColors.surfaceContainerLow,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: AppTextStyles.headlineMd.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                    const Icon(Icons.schedule, color: AppColors.outline, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.routineIconLabel,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showIconPicker(
                                context,
                                currentKey: iconKey.value,
                              );
                              if (picked != null) {
                                iconKey.value = picked;
                                setSheetState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.outlineVariant),
                                borderRadius: AppRadius.card,
                              ),
                              child: Icon(
                                resolveRoutineIcon(iconKey.value),
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (name.trim().isEmpty) return;
                        final uuid = DateTime.now()
                            .millisecondsSinceEpoch
                            .toString();
                        notifier.addRoutine(RoutineModel(
                          id: 'custom_$uuid',
                          name: name.trim(),
                          iconName: iconKey.value,
                          scheduleText: description.trim().isNotEmpty
                              ? description.trim()
                              : AppStrings.dailyRoutineAddCustom,
                          isPredefined: false,
                          customTimes: [time],
                        ));
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.dailyRoutineAddButton,
                        style: AppTextStyles.poppinsButton,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReminderSection(
    BuildContext context,
    WidgetRef ref,
    DailyRoutineState state,
  ) {
    final notifier = ref.read(dailyRoutineProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dailyRoutineReminderQuestion,
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _OptionCard(
                label: AppStrings.dailyRoutineReminderYes,
                icon: Icons.check,
                iconBgColor: AppColors.secondaryContainer,
                iconColor: AppColors.onSecondaryContainer,
                selected: state.useReminder,
                onTap: () => notifier.toggleReminder(true),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _OptionCard(
                label: AppStrings.dailyRoutineReminderNo,
                icon: Icons.close,
                iconBgColor: AppColors.errorContainer,
                iconColor: AppColors.onErrorContainer,
                selected: !state.useReminder,
                onTap: () => notifier.toggleReminder(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, double bottomPadding) {
    final state = ref.watch(dailyRoutineProvider);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.lg + bottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0),
            AppColors.surface,
          ],
        ),
      ),
      child: AppButton(
        label: AppStrings.dailyRoutineButton,
        trailingIcon: Icons.arrow_forward,
        borderRadius: AppRadius.buttonPill,
        isLoading: state.isLoading,
        onPressed: () async {
          final ok = await ref.read(dailyRoutineProvider.notifier).finishOnboarding();
          if (context.mounted) {
            if (ok) {
              context.go(RouteNames.accountCreatedSuccess);
            } else {
              final currState = ref.read(dailyRoutineProvider);
              if (currState.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(currState.errorMessage!),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected ? AppShadows.soft : null,
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.onPrimary : iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
