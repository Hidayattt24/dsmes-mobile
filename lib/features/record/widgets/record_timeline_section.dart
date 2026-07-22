import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/record_entry.dart';

class RecordTimelineSection extends StatelessWidget {
  const RecordTimelineSection({
    super.key,
    required this.selectedDate,
    required this.selectedFilter,
    required this.items,
    required this.onDateSelected,
    required this.onFilterSelected,
    required this.onOpenCalendarSheet,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  final DateTime selectedDate;
  final RecordType selectedFilter;
  final List<TimelineRecordItem> items;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<RecordType> onFilterSelected;
  final VoidCallback onOpenCalendarSheet;
  final ValueChanged<TimelineRecordItem> onEditItem;
  final ValueChanged<TimelineRecordItem> onDeleteItem;

  String _getDateLabel(DateTime date) {
    final now = MockRecordHistoryData.today;
    if (MockRecordHistoryData.isSameDate(date, now)) return 'Hari Ini';
    if (MockRecordHistoryData.isSameDate(date, MockRecordHistoryData.yesterday)) return 'Kemarin';
    if (MockRecordHistoryData.isSameDate(date, MockRecordHistoryData.lastTuesday)) return 'Selasa (21 Jul)';
    if (MockRecordHistoryData.isSameDate(date, MockRecordHistoryData.threeDaysAgo)) return '20 Jul 2026';
    return '${date.day} Jul ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isToday = MockRecordHistoryData.isSameDate(selectedDate, MockRecordHistoryData.today);

    // Apply active RecordType filter
    final filteredItems = selectedFilter == RecordType.all
        ? items
        : items.where((item) => item.type == selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Title & Open Calendar Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Aktivitas',
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            InkWell(
              onTap: onOpenCalendarSheet,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outlineVariant),
                  color: AppColors.surfaceContainerLow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getDateLabel(selectedDate),
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Quick Date Selector Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _DateChoiceChip(
                label: 'Hari Ini',
                isSelected: MockRecordHistoryData.isSameDate(selectedDate, MockRecordHistoryData.today),
                onTap: () => onDateSelected(MockRecordHistoryData.today),
              ),
              const SizedBox(width: 6),
              _DateChoiceChip(
                label: 'Kemarin',
                isSelected: MockRecordHistoryData.isSameDate(selectedDate, MockRecordHistoryData.yesterday),
                onTap: () => onDateSelected(MockRecordHistoryData.yesterday),
              ),
              const SizedBox(width: 6),
              _DateChoiceChip(
                label: 'Selasa (21 Jul)',
                isSelected: MockRecordHistoryData.isSameDate(selectedDate, MockRecordHistoryData.lastTuesday),
                onTap: () => onDateSelected(MockRecordHistoryData.lastTuesday),
              ),
              const SizedBox(width: 6),
              _DateChoiceChip(
                label: '20 Jul',
                isSelected: MockRecordHistoryData.isSameDate(selectedDate, MockRecordHistoryData.threeDaysAgo),
                onTap: () => onDateSelected(MockRecordHistoryData.threeDaysAgo),
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                label: const Text('Kalender Lengkap'),
                labelStyle: AppTextStyles.labelMd.copyWith(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                side: BorderSide.none,
                onPressed: onOpenCalendarSheet,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Lightweight Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: RecordType.values.map((type) {
              final isSelected = selectedFilter == type;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(type.label),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer,
                  labelStyle: AppTextStyles.labelMd.copyWith(
                    fontSize: 12,
                    color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.surfaceContainerLow,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      onFilterSelected(type);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Timeline Content or Empty State
        if (filteredItems.isEmpty)
          _RecordEmptyState(
            isToday: isToday,
            selectedFilter: selectedFilter,
          )
        else
          Stack(
            children: [
              // Vertical connecting line
              Positioned(
                left: 9,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 2,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              // Timeline items
              Column(
                children: filteredItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline dot
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: item.dotOuterColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: item.dotInnerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Content Icon
                        Icon(
                          item.icon,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (item.badgeText != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.badgeBgColor ??
                                        AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.badgeText!,
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: item.badgeTextColor ??
                                          AppColors.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Time & More (⋮) Action Menu
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.time,
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  item.dateText,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontSize: 10,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 2),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 18,
                                color: AppColors.outline,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 140),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              color: AppColors.surfaceContainerLowest,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  onEditItem(item);
                                } else if (action == 'delete') {
                                  onDeleteItem(item);
                                }
                              },
                              itemBuilder: (context) => <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ubah Catatan',
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Hapus Catatan',
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }
}

class _DateChoiceChip extends StatelessWidget {
  const _DateChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer,
      labelStyle: AppTextStyles.labelMd.copyWith(
        fontSize: 12,
        color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.outlineVariant.withValues(alpha: 0.3),
      ),
      onSelected: (val) {
        if (val) onTap();
      },
    );
  }
}

class _RecordEmptyState extends StatelessWidget {
  const _RecordEmptyState({
    required this.isToday,
    required this.selectedFilter,
  });

  final bool isToday;
  final RecordType selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filterLabel = selectedFilter == RecordType.all ? '' : selectedFilter.label;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceContainerLow,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: AppColors.outline,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isToday
                ? (filterLabel.isEmpty
                    ? 'Belum Ada Catatan Hari Ini'
                    : 'Belum Ada Catatan $filterLabel Hari Ini')
                : (filterLabel.isEmpty
                    ? 'Tidak Ada Catatan Kesehatan'
                    : 'Tidak Ada Catatan $filterLabel'),
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isToday
                ? 'Mulai catat gula darah, makanan, atau aktivitas fisik Anda hari ini. Catatan akan muncul di sini.'
                : 'Tidak ada aktivitas kesehatan yang dicatat pada tanggal ini.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
