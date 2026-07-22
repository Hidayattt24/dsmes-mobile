import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/education/views/education_screen.dart';
import '../../features/home/views/home_view.dart';
import '../../features/record/views/record_view.dart';
import '../../features/home/history/widgets/calendar_history_bottom_sheet.dart';
import '../../features/notifications/viewmodels/notifications_notifier.dart';
import 'app_bottom_navigation.dart';
import 'app_header.dart';

/// Main Shell screen for the DSMES Mobile application containing the shared AppHeader and AppBottomNavigation.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, this.nowOverride});

  final DateTime? nowOverride;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeView(nowOverride: widget.nowOverride),
      const RecordView(),
      const EducationScreen(),
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

  void _openCalendarHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarHistoryBottomSheet(
        initialDate: widget.nowOverride ?? DateTime(2026, 7, 23),
        onDateSelected: (date) {
          // Calendar date selected callback
        },
      ),
    );
  }

  String _getSubtitleForIndex(int index) {
    return switch (index) {
      0 => 'Bagaimana perasaan Anda hari ini?',
      1 => 'Catat gula darah & aktivitas harian Anda',
      2 => 'Pelajari tips & informasi kesehatan diabetes',
      3 => 'Evaluasi kesehatan berkala DSMES',
      4 => 'Informasi profil & pengaturan akun',
      _ => 'Selamat datang di DSMES Aceh',
    };
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotificationCount = ref.watch(
      notificationsProvider.select((list) => list.where((n) => n.isUnread).length),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Shared Top Header (Persistent across primary navigation destinations)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.page,
                AppSpacing.page,
                0,
              ),
              child: AppHeader(
                userName: 'Budi',
                showGreeting: _selectedIndex == 0,
                subtitle: _selectedIndex == 0 ? _getSubtitleForIndex(_selectedIndex) : null,
                notificationCount: unreadNotificationCount,
                onCalendarTap: _openCalendarHistoryBottomSheet,
                onNotificationTap: () => context.push(RouteNames.notifications),
                onProfileTap: () {
                  setState(() {
                    _selectedIndex = 4; // Switch to Profil tab
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Active Tab Page View
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
          ],
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
