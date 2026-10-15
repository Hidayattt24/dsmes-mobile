import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/server_status_notifier.dart';
import '../../core/router/route_names.dart';
import '../../core/security/app_lock_manager.dart';
import '../../core/services/firebase_messaging_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/sync/sync_queue_manager.dart';
import '../../core/services/app_usage_tracker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/server_status_banner.dart';
import '../../data/repositories/device_token_repository.dart';
import '../../features/education/views/education_screen.dart';
import '../../features/home/history/viewmodels/history_provider.dart';
import '../../features/home/reminders/viewmodels/reminder_provider.dart';
import '../../features/questionnaire/views/questionnaire_screen.dart';
import '../../features/record/models/record_provider.dart';
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

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int get _selectedIndex => ref.watch(appShellTabIndexProvider);

  Widget _buildScreen(int index) {
    return switch (index) {
      0 => HomeView(
        key: const ValueKey('home'),
        nowOverride: widget.nowOverride,
      ),
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
      // 1. Sync inbox notifications from backend
      ref.read(notificationsProvider.notifier).loadFromBackend();
      // 2. Register/update FCM device token with backend
      firebaseMessagingService.registerCurrentToken(
        ref.read(deviceTokenRepositoryProvider),
      );
      // 3. Sync local alarms for active reminders
      ref.read(reminderListProvider);
      // 4. Check any pending notifications that launched the app from terminated state
      firebaseMessagingService.checkInitialMessage();
      LocalNotificationService.instance.checkAppLaunchNotification();
      // 5. Initialize app foreground duration usage tracking
      ref.read(appUsageTrackerProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _triggerAutoSync() {
    final dio = ref.read(dioClientProvider);
    ref.read(syncQueueManagerProvider.notifier).processQueue(dio).then((count) {
      if (count > 0 && mounted) {
        ref.read(homeDashboardProvider.notifier).refresh();
        ref.read(historyProvider.notifier).refresh();
        ref.read(reminderListProvider.notifier).refresh();
        ref.read(recordProvider.notifier).loadData();
      }
    }).catchError((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(appLockProvider.notifier).onAppResumed();
      ref.read(notificationsProvider.notifier).loadFromBackend();
      ref.read(reminderListProvider.notifier).refresh();
      _triggerAutoSync();
    }
  }

  void _openCalendarHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CalendarHistoryBottomSheet(
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
      3 => 'Evaluasi kesehatan berkala DIBA',
      4 => 'Informasi profil & pengaturan akun',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Auto-sync listener: when connection changes from offline/serverDown to online, flush queue
    ref.listen<ServerStatusState>(serverStatusProvider, (previous, next) {
      if (previous?.health != ServerHealth.online &&
          next.health == ServerHealth.online) {
        _triggerAutoSync();
      }
    });

    final isLocked = ref.watch(appLockProvider.select((s) => s.isLocked));
    if (isLocked) {
      return const AppLockScreen();
    }

    final unreadNotificationCount = ref.watch(
      notificationsProvider.select(
        (list) => list.where((n) => n.isUnread).length,
      ),
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
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width < 360
                        ? AppSpacing.md
                        : AppSpacing.page,
                    AppSpacing.page,
                    MediaQuery.sizeOf(context).width < 360
                        ? AppSpacing.md
                        : AppSpacing.page,
                    0,
                  ),
                  child: AppHeader(
                    userName: patientName,
                    avatarUrl: avatarUrl,
                    showGreeting: false,
                    subtitle: _getSubtitleForIndex(_selectedIndex),
                    notificationCount: unreadNotificationCount,
                    onCalendarTap: _openCalendarHistoryBottomSheet,
                    onNotificationTap:
                        () => context.push(RouteNames.notifications),
                    onProfileTap: () {
                      ref.read(appShellTabIndexProvider.notifier).state = 4;
                    },
                  ),
                ),
                // Global Non-blocking Server / Offline Status Banner
                ServerStatusBanner(
                  onRetry: () {
                    _triggerAutoSync();
                    ref.read(homeDashboardProvider.notifier).refresh();
                    ref.read(notificationsProvider.notifier).loadFromBackend();
                    ref.read(reminderListProvider.notifier).refresh();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
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
