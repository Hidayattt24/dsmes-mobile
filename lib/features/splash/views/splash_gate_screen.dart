import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../questionnaire/viewmodels/questionnaire_notifier.dart';

/// Transient gate shown while the mandatory Pre-Test completion status is being
/// resolved. Once resolved it routes the user to Home (if the Pre-Test is done)
/// or to the Pre-Test intro (if it is still required).
///
/// This removes the previous "loading window" where a user could reach a
/// protected route (e.g. /home) before `hasCompletedPreTestProvider` resolved,
/// bypassing the mandatory Pre-Test.
class SplashGateScreen extends ConsumerWidget {
  const SplashGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(hasCompletedPreTestProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: completedAsync.when(
        loading: () => const _SplashLoading(),
        error: (_, _) {
          // Cannot determine the status — fall back to the Pre-Test gate.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted &&
                GoRouterState.of(context).matchedLocation ==
                    RouteNames.splash) {
              context.go(RouteNames.preTestIntro);
            }
          });
          return const _SplashLoading();
        },
        data: (completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted &&
                GoRouterState.of(context).matchedLocation ==
                    RouteNames.splash) {
              context.go(completed ? RouteNames.home : RouteNames.preTestIntro);
            }
          });
          return const _SplashLoading();
        },
      ),
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
