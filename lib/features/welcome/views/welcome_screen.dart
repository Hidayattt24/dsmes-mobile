import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../widgets/welcome_content.dart';
import '../widgets/welcome_illustration.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.16, 1.0, 0.3, 1.0),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeIn),
      ),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background mesh gradient
          const _BackgroundMesh(),
          // Decorative blurred circles
          ..._buildDecorativeCircles(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top illustration area
                const Expanded(
                  child: WelcomeIllustration(),
                ),
                // Bottom bento card
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: const _BottomCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return const [
      Positioned(
        top: 80,
        right: -40,
        width: 200,
        height: 200,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x1A286b33),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: 300,
        left: -60,
        width: 280,
        height: 280,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x1A00695c),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }
}

class _BackgroundMesh extends StatelessWidget {
  const _BackgroundMesh();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 0.8,
          colors: [
            Color(0xFFE6F7F4),
            Colors.transparent,
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 0.6,
            colors: [
              Color(0xFFF0FAF6),
              Colors.transparent,
            ],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.7,
              colors: [
                Color(0xFFEAF3EE),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A00695c),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: WelcomeContent(),
          ),
        ),
      ),
    );
  }
}
