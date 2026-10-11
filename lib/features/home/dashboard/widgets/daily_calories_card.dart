import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../meal/models/nutrition_summary_model.dart';

class DailyCaloriesCard extends StatefulWidget {
  const DailyCaloriesCard({
    super.key,
    required this.consumed,
    required this.remaining,
    required this.target,
    this.nutritionSummary,
    required this.onRecordFoodPressed,
    this.onViewHistoryPressed,
    this.isToday = true,
    this.hasRecord = true,
    this.historyMessage,
  });

  const DailyCaloriesCard.empty({
    super.key,
    required this.onRecordFoodPressed,
    this.onViewHistoryPressed,
    this.isToday = true,
    this.historyMessage,
  })  : consumed = 0,
        remaining = 0,
        target = 0,
        nutritionSummary = null,
        hasRecord = false;

  final int consumed;
  final int remaining;
  final int target;
  final DailyNutritionSummary? nutritionSummary;
  final VoidCallback onRecordFoodPressed;
  final VoidCallback? onViewHistoryPressed;
  final bool isToday;
  final bool hasRecord;
  final String? historyMessage;

  @override
  State<DailyCaloriesCard> createState() => _DailyCaloriesCardState();
}

class _DailyCaloriesCardState extends State<DailyCaloriesCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _progressAnim;
  bool _isNutrientsExpanded = false;

  double get _targetProgress {
    if (widget.target <= 0) return 0.0;
    return (widget.consumed / widget.target).clamp(0.0, 1.0);
  }

  Color get _gaugeColor {
    if (widget.target <= 0) return const Color(0xFF38BDF8);
    final ratio = widget.consumed / widget.target;
    if (ratio < 0.50) {
      return const Color(0xFF38BDF8); // Rendah (0–49%): Biru muda
    } else if (ratio < 0.80) {
      return const Color(0xFF14B8A6); // Sedang (50–79%): Teal
    } else if (ratio < 1.00) {
      return const Color(0xFF84CC16); // Mendekati target (80–99%): Hijau limau
    } else {
      return const Color(0xFFF59E0B); // Target tercapai / terlampaui (>=100%): Amber
    }
  }

  String get _calorieStatusText {
    if (widget.target <= 0) return 'Belum Ada Target';
    final ratio = widget.consumed / widget.target;
    if (ratio < 0.50) {
      return 'Rendah';
    } else if (ratio < 0.80) {
      return 'Sedang';
    } else if (ratio < 1.00) {
      return 'Mendekati Target';
    } else {
      return widget.consumed > widget.target ? 'Target Terlampaui' : 'Target Tercapai';
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _progressAnim = Tween<double>(
      begin: 0.0,
      end: _targetProgress,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant DailyCaloriesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed ||
        oldWidget.target != widget.target) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: _targetProgress,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _animController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatNumber(double val) {
    if (val == val.truncateToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  String _formatInt(int val) {
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showInfoSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Tentang Kalori & Target Harian',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '• Kalori dikonsumsi dihitung dari makanan yang Anda catat pada hari yang bersangkutan.\n\n'
                  '• Kalori tersisa merupakan selisih target kalori harian dikurangi total konsumsi kalori Anda.\n\n'
                  '• Angka nutrisi bergantung pada ketersediaan data makanan. Target harian ini berfungsi sebagai panduan hidup sehat dan kepatuhan pola makan.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGaugeDetailSheet() {
    final isExceeded = widget.target > 0 && widget.consumed > widget.target;
    final percent = widget.target > 0
        ? ((widget.consumed / widget.target) * 100).toInt()
        : 0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Asupan Kalori',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExceeded
                          ? Colors.orange.shade50
                          : AppColors.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isExceeded
                            ? Colors.orange.shade300
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isExceeded ? 'Melebihi Target' : '$percent% Terpenuhi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isExceeded ? Colors.orange.shade900 : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _DetailRow(
                label: 'Kalori Dikonsumsi',
                value: '${_formatInt(widget.consumed)} kkal',
                color: AppColors.primary,
                bold: true,
              ),
              const Divider(height: 16),
              _DetailRow(
                label: 'Target Kalori Harian',
                value: '${_formatInt(widget.target)} kkal',
              ),
              const Divider(height: 16),
              _DetailRow(
                label: 'Kalori Tersisa',
                value: '${_formatInt(math.max(widget.target - widget.consumed, 0))} kkal',
                color: isExceeded ? Colors.orange.shade800 : AppColors.onSurface,
                bold: true,
              ),
              if (isExceeded) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Asupan kalori hari ini melebihi target harian sebesar ${_formatInt(widget.consumed - widget.target)} kkal.',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Catat Makanan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    widget.onRecordFoodPressed();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // ── Empty State ──────────────────────────────────────────────────────────
    if (!widget.hasRecord && widget.consumed == 0) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kalori Hari Ini',
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.outline),
                  onPressed: _showInfoSheet,
                  tooltip: 'Penjelasan kalori',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Centered Empty State Details
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_outlined,
                      color: AppColors.outlineVariant,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Belum ada makanan yang dicatat.',
                    style: AppTextStyles.poppinsHeadline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    widget.isToday
                        ? 'Catat makanan yang Anda konsumsi hari ini.'
                        : (widget.historyMessage ?? 'Data makanan tidak diisi pada hari ini.'),
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // CTA or Read-only banner
            if (widget.isToday)
              AppButton(
                label: 'Catat Makanan',
                icon: Icons.restaurant_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: widget.onRecordFoodPressed,
              )
            else
              _buildHistoryBanner(),
            if (widget.isToday && widget.onViewHistoryPressed != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Riwayat Makanan',
                icon: Icons.history_rounded,
                variant: AppButtonVariant.text,
                onPressed: widget.onViewHistoryPressed,
              ),
            ],
          ],
        ),
      );
    }

    // ── Modern Card with Semi-Circle Gauge & 7 Nutrients ───────────────────────
    final safeRemaining = math.max(widget.target - widget.consumed, 0);
    final isExceeded = widget.target > 0 && widget.consumed > widget.target;

    final summary = widget.nutritionSummary;
    final proteinG = summary?.totalProteinG ?? 0.0;
    final carbsG = summary?.totalCarbsG ?? 0.0;
    final fatG = summary?.totalFatG ?? 0.0;
    final sugarG = summary?.totalSugarG ?? 0.0;
    final sodiumMg = summary?.totalSodiumMg ?? 0.0;
    final fiberG = summary?.totalFiberG ?? 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title & Info Icon ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Kalori Hari Ini',
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _gaugeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _gaugeColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      _calorieStatusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _gaugeColor == const Color(0xFF84CC16)
                            ? const Color(0xFF3F6212)
                            : (_gaugeColor == const Color(0xFF38BDF8)
                                ? const Color(0xFF0369A1)
                                : (_gaugeColor == const Color(0xFFF59E0B)
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF0F766E))),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: _showInfoSheet,
                tooltip: 'Penjelasan kalori',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Semi-Circle Gauge Visualization ────────────────────────────────
          GestureDetector(
            onTap: _showGaugeDetailSheet,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final gaugeWidth = math.min(constraints.maxWidth, 280.0);
                    final gaugeHeight = gaugeWidth * 0.52;

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: gaugeWidth,
                            height: gaugeHeight + 6,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                CustomPaint(
                                  size: Size(gaugeWidth, gaugeHeight),
                                  painter: _SemiCircleGaugePainter(
                                    progress: _progressAnim.value,
                                    trackColor: const Color(0xFFE2E8F0),
                                    progressColor: _gaugeColor,
                                    strokeWidth: 14.0,
                                  ),
                                ),
                                Positioned(
                                  top: gaugeHeight * 0.35,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatInt(safeRemaining),
                                        style: AppTextStyles.poppinsHeadline.copyWith(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.onSurface,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'kkal tersisa',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (isExceeded)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            '+${_formatInt(widget.consumed - widget.target)} kkal lebih',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _GaugeSubLabel(
                                  label: 'Dikonsumsi',
                                  value: '${_formatInt(widget.consumed)} kkal',
                                  isLeft: true,
                                ),
                                _GaugeSubLabel(
                                  label: 'Target',
                                  value: '${_formatInt(widget.target)} kkal',
                                  isLeft: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Divider ────────────────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: AppSpacing.sm),

          // ── 7 Complete Nutrition Metrics with Expand/Collapse Dropdown ─────
          InkWell(
            onTap: () {
              setState(() {
                _isNutrientsExpanded = !_isNutrientsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'INFORMASI ASUPAN NUTRISI',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.6,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isNutrientsExpanded ? 'Tutup' : 'Lihat Detail',
                          style: AppTextStyles.labelSm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isNutrientsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (_isNutrientsExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            // Row 1: Protein, Karbohidrat, Lemak (Makronutrien Utama)
            Row(
              children: [
                Expanded(
                  child: _NutrientCard(
                    label: 'Protein',
                    value: '${_formatNumber(proteinG)} g',
                    color: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFF0F9FF),
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientCard(
                    label: 'Karbohidrat',
                    value: '${_formatNumber(carbsG)} g',
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                    icon: Icons.grain_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientCard(
                    label: 'Lemak',
                    value: '${_formatNumber(fatG)} g',
                    color: const Color(0xFFE11D48),
                    bgColor: const Color(0xFFFFF1F2),
                    icon: Icons.opacity_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Gula, Natrium, Serat (Nutrisi Pendukung)
            Row(
              children: [
                Expanded(
                  child: _NutrientCard(
                    label: 'Gula',
                    value: '${_formatNumber(sugarG)} g',
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    icon: Icons.cookie_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientCard(
                    label: 'Natrium',
                    value: '${_formatNumber(sodiumMg)} mg',
                    color: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFF0FDFA),
                    icon: Icons.shutter_speed_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientCard(
                    label: 'Serat Pangan',
                    value: '${_formatNumber(fiberG)} g',
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    icon: Icons.eco_outlined,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // ── CTA Buttons / History Banner ───────────────────────────────────
          if (widget.isToday)
            AppButton(
              label: 'Catat Makanan',
              icon: Icons.restaurant_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: widget.onRecordFoodPressed,
            )
          else
            _buildHistoryBanner(),
          if (widget.isToday && widget.onViewHistoryPressed != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: 'Riwayat Makanan',
              icon: Icons.history_rounded,
              variant: AppButtonVariant.text,
              onPressed: widget.onViewHistoryPressed,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.cardMd,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history_toggle_off_rounded,
            color: AppColors.outline,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.historyMessage ??
                  'Anda sedang melihat data riwayat. Catatan masa lalu tidak dapat diubah.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiCircleGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _SemiCircleGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint (Background arc 180 degrees)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // 180 degrees (9 o'clock)
      math.pi, // sweep 180 degrees to 3 o'clock
      false,
      trackPaint,
    );

    // Progress Paint (Foreground arc)
    if (progress > 0.001) {
      final sweepAngle = math.pi * progress.clamp(0.0, 1.0);
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _GaugeSubLabel extends StatelessWidget {
  final String label;
  final String value;
  final bool isLeft;

  const _GaugeSubLabel({
    required this.label,
    required this.value,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _NutrientCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color ?? AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
