import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dsmes_mobile/features/auth/views/login_screen.dart';
import 'package:dsmes_mobile/features/home/views/home_screen.dart';
import 'package:dsmes_mobile/features/home/widgets/weekly_calendar_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('LoginScreen renders all redesigned elements', (WidgetTester tester) async {
    // Set screen size to a standard mobile width with enough headroom for test fonts
    tester.view.physicalSize = const Size(1800, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header components are rendered
    expect(find.text('DSMES ACEH'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);

    // Verify text fields are present
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Verify modern options row is present
    expect(find.text('Ingat saya'), findsOneWidget);
    expect(find.text('Lupa kata sandi?'), findsOneWidget);

    // Verify login button and register link are present
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Belum punya akun? '), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('HomeScreen renders new Beranda layout and sections', (WidgetTester tester) async {
    // Set screen size to a standard mobile width with enough headroom for test fonts
    tester.view.physicalSize = const Size(1800, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: HomeScreen(nowOverride: DateTime(2026, 7, 23)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Tab navigation Beranda is active and shows the HomeView components
    expect(find.text('DSMES Aceh'), findsOneWidget);
    expect(find.text('Halo, Budi'), findsOneWidget);
    expect(find.text('Hari ini'), findsOneWidget); // weekly calendar title

    // Blood Sugar Card
    expect(find.text('GULA DARAH'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Catat Gula Darah'), findsOneWidget);

    // Calories Card
    expect(find.text('Kalori Harian'), findsOneWidget);
    expect(find.text('Catat Makanan'), findsOneWidget);

    // Reminders
    expect(find.text('Pengingat Hari Ini'), findsOneWidget);
    expect(find.text('Minum Metformin'), findsOneWidget);
    expect(find.text('Gula Darah Puasa'), findsOneWidget);

    // Weekly Summary
    expect(find.text('Ringkasan Mingguan'), findsOneWidget);
    expect(find.text('Stabil'), findsOneWidget);
    expect(find.text('5/7'), findsOneWidget);
  });

  testWidgets('HomeScreen timeline selection updates views between completed, empty, and editable states', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1800, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: HomeScreen(nowOverride: DateTime(2026, 7, 23)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. By default, Today (Thursday/K) is selected, editable, showing progress data
    expect(find.text('Catat Gula Darah'), findsOneWidget);
    expect(find.text('Catat Makanan'), findsOneWidget);

    // 2. Tap Monday (Index 0 in weekly calendar) which is Completed & Read-Only
    await tester.tap(find.byType(WeeklyCalendarDay).at(0));
    await tester.pumpAndSettle();

    // Verify Monday's completed reading values are shown
    expect(find.text('112'), findsOneWidget);
    expect(find.text('1850'), findsOneWidget);
    // Verify historical banner is shown and record buttons are gone/hidden
    expect(find.text('Viewing completed history.'), findsWidgets);
    expect(find.text('Catat Gula Darah'), findsNothing);
    expect(find.text('Catat Makanan'), findsNothing);

    // 3. Tap Friday (Index 4 in weekly calendar) which has No Record & is Read-Only
    await tester.tap(find.byType(WeeklyCalendarDay).at(4));
    await tester.pumpAndSettle();

    // Verify empty state illustrations/text are displayed
    expect(find.text('No blood sugar has been recorded.'), findsOneWidget);
    expect(find.text('No meals have been recorded.'), findsOneWidget);
    expect(find.text('No medication record.'), findsOneWidget);
  });
}
