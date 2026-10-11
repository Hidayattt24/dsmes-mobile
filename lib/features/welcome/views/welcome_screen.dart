import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/welcome_content.dart';
import '../widgets/welcome_illustration.dart';

const _slides = <WelcomeSlide>[
  WelcomeSlide(
    icon: Icons.water_drop_rounded,
    color: Color(0xFF00695C),
    title: 'Pantau Gula Darah\nLebih Mudah',
    description:
        'Catat hasil cek gula darah kapan saja dan lihat tren harian Anda dalam grafik yang jelas.',
    chips: [
      (Icons.show_chart_rounded, '115 mg/dL'),
      (Icons.check_circle_rounded, 'Normal'),
      (Icons.schedule_rounded, 'Sebelum Makan'),
    ],
  ),
  WelcomeSlide(
    icon: Icons.restaurant_rounded,
    color: Color(0xFFD97706),
    title: 'Atur Pola Makan\nSesuai Target',
    description:
        'Catat asupan makanan dan pantau kalori serta nutrisi harian agar tetap dalam batas aman.',
    chips: [
      (Icons.local_fire_department_rounded, '572 kcal'),
      (Icons.eco_rounded, 'Serat 5g'),
      (Icons.rice_bowl_rounded, 'Sarapan'),
    ],
  ),
  WelcomeSlide(
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF286B33),
    title: 'Aktif Bergerak,\nMinum Obat Teratur',
    description:
        'Pengingat obat dan catatan aktivitas fisik membantu Anda tetap konsisten setiap hari.',
    chips: [
      (Icons.medication_rounded, 'Metformin'),
      (Icons.notifications_active_rounded, '07.00'),
      (Icons.timer_rounded, '30 menit'),
    ],
  ),
  WelcomeSlide(
    icon: Icons.menu_book_rounded,
    color: Color(0xFF0284C7),
    title: 'Belajar & Konsultasi\nBersama DIBA',
    description:
        'Materi edukasi diabetes dan kuesioner siap mendampingi perjalanan sehat Anda.',
    chips: [
      (Icons.article_rounded, 'Edukasi'),
      (Icons.health_and_safety_rounded, 'Didampingi Nakes'),
    ],
  ),
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar: brand + skip
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 32),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: _isLast
                            ? null
                            : () => _pageController.animateToPage(
                                  _slides.length - 1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                ),
                        child: Text(
                          'Lewati',
                          style: AppTextStyles.labelLg.copyWith(
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => _SlideView(
                    slide: _slides[i],
                    controller: _pageController,
                    index: i,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: WelcomeContent(
                  count: _slides.length,
                  current: _page,
                  isLast: _isLast,
                  onNext: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.controller,
    required this.index,
  });

  final WelcomeSlide slide;
  final PageController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Parallax/fade based on scroll position for a smooth transition.
        double delta = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? 0) - index;
        }
        final opacity = (1 - delta.abs()).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(delta * 40, 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Expanded(child: WelcomeIllustration(slide: slide)),
            const SizedBox(height: 16),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 24,
                height: 1.3,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: const Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
