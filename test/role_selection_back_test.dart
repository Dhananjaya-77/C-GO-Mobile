import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/models/user_role.dart';
import 'package:securetrack_mobile/screens/login_screen.dart';
import 'package:securetrack_mobile/screens/welcome_screen.dart';

void main() {
  testWidgets('Back to Role Selection button navigates to WelcomeScreen when popped from stack', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify WelcomeScreen is displayed
    expect(find.text('Select your role to continue'), findsOneWidget);

    // Tap Truck Driver role card
    await tester.tap(find.text('Truck Driver'));
    await tester.pumpAndSettle();

    // Verify LoginScreen is displayed
    expect(find.text('Back to Role Selection'), findsOneWidget);

    // Tap Back to Role Selection button
    await tester.tap(find.text('Back to Role Selection'));
    await tester.pumpAndSettle();

    // Verify successfully returned to WelcomeScreen
    expect(find.text('Select your role to continue'), findsOneWidget);
  });

  testWidgets('Back to Role Selection button works even when LoginScreen is at root of navigation', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Launched directly at root (Navigator cannot pop)
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(selectedRole: UserRole.driver),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Back to Role Selection'), findsOneWidget);

    // Tap Back to Role Selection button
    await tester.tap(find.text('Back to Role Selection'));
    await tester.pumpAndSettle();

    // Verify fallback replaces route and navigates cleanly to WelcomeScreen
    expect(find.text('Select your role to continue'), findsOneWidget);
  });

  testWidgets('Top Role Selection back button navigates cleanly to WelcomeScreen', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(selectedRole: UserRole.inspector),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Role Selection'), findsOneWidget);

    // Tap top Role Selection button
    await tester.tap(find.text('Role Selection'));
    await tester.pumpAndSettle();

    expect(find.text('Select your role to continue'), findsOneWidget);
  });
}
