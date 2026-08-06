import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation — all layouts are designed for
  // portrait widths and would break in landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize System Local Notifications (Android Status Bar / Pop-up)
  await LocalNotificationService.instance.initialize();

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
