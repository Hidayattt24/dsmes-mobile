import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/education/views/education_screen.dart';
import '../../features/questionnaire/views/questionnaire_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/home/views/home_view.dart';
import '../../features/record/views/record_view.dart';
import '../../features/home/history/widgets/calendar_history_bottom_sheet.dart';
import '../../features/notifications/viewmodels/notifications_notifier.dart';
import '../../features/home/viewmodels/home_dashboard_notifier.dart';
import 'app_bottom_navigation.dart';
import 'app_header.dart';

final appShellTabIndexProvider = StateProvider<int>((ref) => 0);

/// Main Shell screen for the DSMES Mobile application containing the shared AppHeader and AppBottomNavigation.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, this.nowOverride});

  final DateTime? nowOverride;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  int get _selectedIndex => ref.watch(appShellTabIndexProvider);

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
    WidgetsBinding.instance.addObserver(this);
    // Best-effort initial sync with the backend once the shell is shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadFromBackend();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsProvider.notifier).loadFromBackend();
    }
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
                      ref.read(appShellTabIndexProvider.notifier).state = 4;
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

            // Global Floating AI Chat Assistant Widget (Disabled for now)
            // const Positioned(
            //   right: AppSpacing.page,
            //   bottom: AppSpacing.md,
            //   child: FloatingAiChatButton(),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          ref.read(appShellTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
