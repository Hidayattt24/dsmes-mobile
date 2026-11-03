import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

abstract final class SafeBackNavigation {
  static void popOrGoHome(BuildContext context, {bool education = false}) {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.of(context).maybePop();
    } else if (router.canPop()) {
      router.pop();
    } else {
      router.go(
        education ? '${RouteNames.home}?tab=education' : RouteNames.home,
      );
    }
  }
}

class SafeBackScope extends StatelessWidget {
  const SafeBackScope({super.key, required this.child, this.education = false});

  final Widget child;
  final bool education;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop:
        GoRouter.maybeOf(context)?.canPop() ?? Navigator.of(context).canPop(),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        SafeBackNavigation.popOrGoHome(context, education: education);
      }
    },
    child: child,
  );
}
