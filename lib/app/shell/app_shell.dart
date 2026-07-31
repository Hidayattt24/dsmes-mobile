import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/education/views/education_screen.dart';
import '../../features/questionnaire/views/questionnaire_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/home/views/home_view.dart';
import '../../features/record/views/record_view.dart';
import '../../features/home/history/widgets/calendar_history_bottom_sheet.dart';
import '../../features/notifications/viewmodels/notifications_notifier.dart';
import '../../features/home/viewmodels/home_dashboard_notifier.dart';
import '../../features/ai_chat/widgets/floating_ai_chat_button.dart';
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

  Widget _buildScreen(int index) {
    return switch (index) {
      0 => HomeView(key: const ValueKey('home'), nowOverride: widget.nowOverride),
      1 => const RecordView(key: ValueKey('record')),
      2 => const EducationScreen(key: ValueKey('education')),
      3 => const QuestionnaireScreen(key: ValueKey('questionnaire')),
      4 => const SettingsScreen(key: ValueKey('settings')),
      _ => const SizedBox(),
    };
  }

  @override
  void initState() {
    super.initState();
  }

  void _openCalendarHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarHistoryBottomSheet(
        initialDate: widget.nowOverride ?? DateTime.now(),
        onDateSelected: (date) {
          // Calendar date selected callback
        },
      ),
    );
  }

  String? _getSubtitleForIndex(int index) {
    return switch (index) {
      0 => null,
      1 => 'Catat gula darah & aktivitas harian Anda',
      2 => 'Pelajari tips & informasi kesehatan diabetes',
      3 => 'Evaluasi kesehatan berkala DSMES',
      4 => 'Informasi profil & pengaturan akun',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotificationCount = ref.watch(
      notificationsProvider.select((list) => list.where((n) => n.isUnread).length),
    );
    final dashboardData = ref.watch(homeDashboardProvider).value?.dashboardData;
    final patientName = dashboardData?.displayName ?? 'Pasien';
    final avatarUrl = dashboardData?.profilePhotoUrl;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                    userName: patientName,
                    avatarUrl: avatarUrl,
                    showGreeting: false,
                    subtitle: _getSubtitleForIndex(_selectedIndex),
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
                      child: _buildScreen(_selectedIndex),
                    ),
                  ),
                ),
              ],
            ),

            // Global Floating AI Chat Assistant Widget (Consistent Bottom Right on all pages)
            const Positioned(
              right: AppSpacing.page,
              bottom: AppSpacing.md,
              child: FloatingAiChatButton(),
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
