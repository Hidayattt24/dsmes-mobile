import 'package:dsmes_mobile/core/router/notification_action_router.dart';
import 'package:dsmes_mobile/core/router/route_names.dart';
import 'package:dsmes_mobile/core/router/safe_back_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  GoRouter makeRouter() => GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) NotificationActionRouter.flushIfReady(context);
          });
          return Scaffold(
            body: Text('Home ${state.uri.queryParameters['tab'] ?? 'main'}'),
          );
        },
      ),
      for (final path in [
        RouteNames.educationDetail + '/:id',
        RouteNames.bloodSugarEntry,
        RouteNames.mealEntry,
        RouteNames.reminders,
      ])
        GoRoute(
          path: path,
          builder:
              (context, _) => Scaffold(
                body: Column(
                  children: [
                    Text('Target $path'),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
        ),
    ],
  );

  for (final scenario in <
    ({
      String name,
      String action,
      String? articleId,
      String target,
      String home,
    })
  >[
    (
      name: 'education',
      action: 'education_detail',
      articleId: 'article-1',
      target: RouteNames.educationDetail,
      home: 'Home education',
    ),
    (
      name: 'blood sugar',
      action: 'blood_sugar_entry',
      articleId: null,
      target: RouteNames.bloodSugarEntry,
      home: 'Home home',
    ),
    (
      name: 'meal',
      action: 'meal_entry',
      articleId: null,
      target: RouteNames.mealEntry,
      home: 'Home home',
    ),
    (
      name: 'fallback reminder',
      action: 'unknown',
      articleId: null,
      target: RouteNames.reminders,
      home: 'Home home',
    ),
  ]) {
    testWidgets('${scenario.name} has a safe home underneath', (tester) async {
      final router = makeRouter();
      addTearDown(router.dispose);
      addTearDown(NotificationActionRouter.clearPending);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      NotificationActionRouter.open(
        tester.element(find.text('Home main')),
        actionType: scenario.action,
        articleId: scenario.articleId,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Target ${scenario.target}'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text(scenario.home), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final action in ['activity_entry', 'medication_entry']) {
    testWidgets('$action opens record tab without an empty route stack', (
      tester,
    ) async {
      final router = makeRouter();
      addTearDown(router.dispose);
      addTearDown(NotificationActionRouter.clearPending);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      NotificationActionRouter.open(
        tester.element(find.text('Home main')),
        actionType: action,
      );
      await tester.pumpAndSettle();
      expect(find.text('Home record'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.queryParameters['action'],
        action,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('education without article falls back to education tab', (
    tester,
  ) async {
    final router = makeRouter();
    addTearDown(router.dispose);
    addTearDown(NotificationActionRouter.clearPending);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    NotificationActionRouter.open(
      tester.element(find.text('Home main')),
      actionType: NotificationActions.educationDetail,
    );
    await tester.pumpAndSettle();
    expect(find.text('Home education'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final education in [false, true]) {
    testWidgets(
      'legacy root Back falls back to ${education ? 'education' : 'home'}',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/legacy',
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder:
                  (_, state) => Scaffold(
                    body: Text(
                      'Home ${state.uri.queryParameters['tab'] ?? 'main'}',
                    ),
                  ),
            ),
            GoRoute(
              path: '/legacy',
              builder:
                  (context, _) => SafeBackScope(
                    education: education,
                    child: Scaffold(
                      body: TextButton(
                        onPressed:
                            () => SafeBackNavigation.popOrGoHome(
                              context,
                              education: education,
                            ),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(
          find.text(education ? 'Home education' : 'Home main'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Android Back on a root page falls back to ${education ? 'education' : 'home'}',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/legacy',
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder:
                  (_, state) => Scaffold(
                    body: Text(
                      'Home ${state.uri.queryParameters['tab'] ?? 'main'}',
                    ),
                  ),
            ),
            GoRoute(
              path: '/legacy',
              builder:
                  (context, _) => SafeBackScope(
                    education: education,
                    child: const Scaffold(body: Text('Legacy')),
                  ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(
          find.text(education ? 'Home education' : 'Home main'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
