import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/questionnaire_detail_model.dart';
import '../viewmodels/questionnaire_notifier.dart';
import 'questionnaire_questions_screen.dart';

class PreTestIntroScreen extends ConsumerWidget {
  const PreTestIntroScreen({super.key, this.initialPreTest});

  final QuestionnaireDetailModel? initialPreTest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preTestAsync =
        initialPreTest != null
            ? AsyncData(initialPreTest!)
            : ref.watch(activePreTestProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: preTestAsync.when(
        loading: () => const _PreTestLoadingSkeleton(),
        error:
            (err, _) => _PreTestErrorView(
              message: err.toString().replaceFirst('Exception: ', ''),
              onRetry: () => ref.read(activePreTestProvider.notifier).refresh(),
            ),
        data:
            (preTest) => _PreTestIntroContent(
              preTest: preTest,
              useDirectNavigation: initialPreTest != null,
            ),
      ),
    );
  }
}

// ── Content ──────────────────────────────────────────────────────────────────

class _PreTestIntroContent extends StatelessWidget {
  const _PreTestIntroContent({
    required this.preTest,
    this.useDirectNavigation = false,
  });

  final QuestionnaireDetailModel preTest;
  final bool useDirectNavigation;

  @override
  Widget build(BuildContext context) {
    final questionCount = preTest.questionCount;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero illustration ──────────────────────────────────
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        size: 72,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Title ──────────────────────────────────────────────
                  Text(
                    'Diabetes Management Self-Efficacy Scale (DMSES)',
                    style: AppTextStyles.headlineLg.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Subtitle ───────────────────────────────────────────
                  Text(
                    'Kuesioner ini bertujuan mengetahui tingkat keyakinan Anda dalam mengelola diabetes sebelum menggunakan aplikasi DSMES.',
                    style: AppTextStyles.bodyLg.copyWith(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Instructions Card ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Petunjuk Pengisian',
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const _InstructionBulletItem(
                          text: 'Tidak ada jawaban benar ataupun salah.',
                        ),
                        const SizedBox(height: 8),
                        const _InstructionBulletItem(
                          text:
                              'Mohon jawab sesuai kondisi dan keyakinan Anda saat ini.',
                        ),
                        const SizedBox(height: 8),
                        const _InstructionBulletItem(
                          text:
                              'Semua jawaban bersifat rahasia dan hanya digunakan untuk evaluasi.',
                        ),
                        const SizedBox(height: 12),
                        const _InstructionBulletItem(
                          text: 'Pilihan respon skala keyakinan (1 s/d 5):',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            children: const [
                              _ScaleLegendRow(
                                emoji: '😟',
                                number: '1.',
                                text: 'Tidak Yakin Sama Sekali',
                              ),
                              SizedBox(height: 6),
                              _ScaleLegendRow(
                                emoji: '🙁',
                                number: '2.',
                                text: 'Kurang Yakin',
                              ),
                              SizedBox(height: 6),
                              _ScaleLegendRow(
                                emoji: '😐',
                                number: '3.',
                                text: 'Cukup Yakin',
                              ),
                              SizedBox(height: 6),
                              _ScaleLegendRow(
                                emoji: '🙂',
                                number: '4.',
                                text: 'Yakin',
                              ),
                              SizedBox(height: 6),
                              _ScaleLegendRow(
                                emoji: '😊',
                                number: '5.',
                                text: 'Sangat Yakin',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Quick stats ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          icon: Icons.quiz_rounded,
                          label: '$questionCount Pertanyaan',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatChip(
                          icon: Icons.psychology_rounded,
                          label: 'Skala Keyakinan',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // ── CTA button (fixed bottom) ──────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.lg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (useDirectNavigation) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (_) => QuestionnaireQuestionsScreen(
                              questionnaire: preTest,
                              isPreTest: true,
                            ),
                      ),
                    );
                  } else {
                    context.push(RouteNames.preTestQuestions, extra: preTest);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mulai Kuesioner',
                      style: AppTextStyles.poppinsButton.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMd.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _PreTestLoadingSkeleton extends StatelessWidget {
  const _PreTestLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _shimmer(width: double.infinity, height: 32),
            const SizedBox(height: 12),
            _shimmer(width: double.infinity, height: 20),
            const SizedBox(height: 8),
            _shimmer(width: 200, height: 20),
            const SizedBox(height: AppSpacing.xl),
            _shimmer(width: double.infinity, height: 120),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _PreTestErrorView extends StatelessWidget {
  const _PreTestErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              size: 72,
              color: AppColors.outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Gagal Memuat Pre-Test',
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Tidak dapat memuat Pre-Test. Periksa koneksi internet Anda.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  'Coba Lagi',
                  style: AppTextStyles.poppinsButton.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class _InstructionBulletItem extends StatelessWidget {
  const _InstructionBulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScaleLegendRow extends StatelessWidget {
  const _ScaleLegendRow({
    required this.emoji,
    required this.number,
    required this.text,
  });

  final String emoji;
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          number,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
