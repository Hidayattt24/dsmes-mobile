import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../onboarding/constants/routine_icons.dart';
import '../../../onboarding/models/routine_model.dart';
import '../../../onboarding/viewmodels/daily_routine_notifier.dart';
import '../../../onboarding/widgets/icon_picker_bottom_sheet.dart';
import '../../../onboarding/widgets/rename_routine_dialog.dart';
import '../../../onboarding/widgets/routine_card.dart';

class RemindersManagementScreen extends ConsumerWidget {
  const RemindersManagementScreen({super.key});

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
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.md,
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
              'Pengaturan Pengingat',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
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
              'Batal',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(dailyRoutineProvider.notifier).deleteRoutine(routine.id);
      return true;
    }
    return false;
  }

  Widget _buildAddRoutineButton(
    BuildContext context,
    WidgetRef ref,
    DailyRoutineNotifier notifier,
  ) {
    return InkWell(
      onTap: () => _showAddRoutineSheet(context, ref, notifier),
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.5),
            width: 1.5,
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
                      labelText: AppStrings.dailyRoutineNameHint,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: AppStrings.dailyRoutineDescHint,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => description = val,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        'Pilih Ikon:',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ValueListenableBuilder<String>(
                        valueListenable: iconKey,
                        builder: (context, currentIcon, _) {
                          return GestureDetector(
                            onTap: () async {
                              final selected = await showIconPicker(
                                context,
                                currentKey: currentIcon,
                              );
                              if (selected != null) {
                                iconKey.value = selected;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                                borderRadius: AppRadius.cardMd,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    resolveRoutineIcon(currentIcon),
                                    color: AppColors.secondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.dailyRoutineTimeLabel,
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setSheetState(() => time = picked);
                          }
                        },
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (name.trim().isEmpty) return;
                        notifier.addRoutine(RoutineModel(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
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

  Widget _buildFooter(BuildContext context, WidgetRef ref, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.md + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: AppButton(
        label: 'Simpan Pengaturan Pengingat',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengaturan pengingat berhasil disimpan!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        },
      ),
    );
  }
}
