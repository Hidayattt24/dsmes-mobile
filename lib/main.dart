import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO: Log to Crashlytics in production
  };

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
