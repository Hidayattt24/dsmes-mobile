import 'package:flutter/material.dart';

import '../../../core/navigation/app_bottom_navigation.dart';
import '../../../core/navigation/app_navigation_destinations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Main Shell screen for the DSMES Mobile application containing the custom Bottom Navigation Bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _PlaceholderTab(
        title: 'Beranda',
        icon: Icons.home_rounded,
        description: 'Pantau kesehatan dan rutinitas harian Anda di sini.',
      ),
      const _PlaceholderTab(
        title: 'Catat Kesehatan',
        icon: Icons.monitor_heart_rounded,
        description: 'Catat gula darah, makanan, dan aktivitas fisik Anda.',
      ),
      const _PlaceholderTab(
        title: 'Edukasi Diabetes',
        icon: Icons.menu_book_rounded,
        description: 'Pelajari tips dan artikel kesehatan terpercaya.',
      ),
      const _PlaceholderTab(
        title: 'Kuesioner Evaluasi',
        icon: Icons.quiz_rounded,
        description: 'Jawab evaluasi kesehatan untuk menyesuaikan saran medis.',
      ),
      const _PlaceholderTab(
        title: 'Profil Pengguna',
        icon: Icons.person_rounded,
        description: 'Kelola informasi pribadi dan pengaturan akun Anda.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeDestination = appNavigationDestinations[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          activeDestination.label,
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 56,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.poppinsHeadline.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                description,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
