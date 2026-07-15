import 'package:flutter_test/flutter_test.dart';

import 'package:dsmes_mobile/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('DSMES Mobile'), findsWidgets);
    expect(find.text('Welcome to DSMES Mobile'), findsOneWidget);
  });
}
