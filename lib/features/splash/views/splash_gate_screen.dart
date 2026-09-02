import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
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
    final sessionAsync = ref.watch(sessionRestoreProvider);

    final completedAsync = ref.watch(hasCompletedPreTestProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: sessionAsync.when(
        loading: () => const _SplashLoading(),
        error: (_, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted &&
                GoRouterState.of(context).matchedLocation ==
                    RouteNames.splash) {
              context.go(RouteNames.welcome);
            }
          });
          return const _SplashLoading();
        },
        data: (loggedIn) {
          if (!loggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted &&
                  GoRouterState.of(context).matchedLocation ==
                      RouteNames.splash) {
                context.go(RouteNames.welcome);
              }
            });
            return const _SplashLoading();
          }
          return completedAsync.when(
            loading: () => const _SplashLoading(),
            error: (_, _) {
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
                  context.go(
                    completed ? RouteNames.home : RouteNames.preTestIntro,
                  );
                }
              });
              return const _SplashLoading();
            },
          );
        },
      ),
    );
  }
}

final sessionRestoreProvider = FutureProvider<bool>((ref) {
  return ref.read(authRepositoryProvider).restoreSession();
});

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
