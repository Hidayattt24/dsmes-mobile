import 'dart:async';

import 'package:dsmes_mobile/core/router/route_names.dart';
import 'package:dsmes_mobile/features/education/views/education_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  GoRouter router({required String initialLocation}) => GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder:
            (_, state) => Scaffold(
              body: Text('Tab ${state.uri.queryParameters['tab'] ?? 'home'}'),
            ),
      ),
      GoRoute(
        path: RouteNames.allArticles,
        builder: (_, _) => const Scaffold(body: Text('Daftar Edukasi')),
      ),
      GoRoute(
        path: '${RouteNames.educationDetail}/:id',
        builder:
            (_, state) =>
                EducationDetailScreen(articleId: state.pathParameters['id']!),
      ),
    ],
  );

  testWidgets('Back button from notification-root detail opens education tab', (
    tester,
  ) async {
    final appRouter = router(
      initialLocation: '${RouteNames.educationDetail}/test',
    );
    addTearDown(appRouter.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Tab education'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Android Back from notification-root detail opens education tab',
    (tester) async {
      final appRouter = router(
        initialLocation: '${RouteNames.educationDetail}/test',
      );
      addTearDown(appRouter.dispose);
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
      );
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Tab education'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Back button from pushed detail returns to previous page', (
    tester,
  ) async {
    final appRouter = router(initialLocation: RouteNames.allArticles);
    addTearDown(appRouter.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
    );
    unawaited(appRouter.push('${RouteNames.educationDetail}/test'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Daftar Edukasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android Back from pushed detail returns to previous page', (
    tester,
  ) async {
    final appRouter = router(initialLocation: RouteNames.allArticles);
    addTearDown(appRouter.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
    );
    unawaited(appRouter.push('${RouteNames.educationDetail}/test'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Daftar Edukasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
