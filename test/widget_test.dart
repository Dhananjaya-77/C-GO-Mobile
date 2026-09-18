import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/main.dart';
import 'package:securetrack_mobile/screens/splash_screen.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecureTrackApp());

    // Verify that the splash screen is displayed with C GO app name.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('C GO'), findsOneWidget);

    // Allow splash timer to complete and transition to LoginScreen
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
