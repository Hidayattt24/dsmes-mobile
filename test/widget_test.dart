import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dsmes_mobile/features/auth/views/login_screen.dart';

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
}
