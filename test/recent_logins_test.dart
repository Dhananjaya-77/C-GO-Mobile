import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/screens/login_screen.dart';
import 'package:securetrack_mobile/services/auth_service.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('AuthService - Recent Logins Tracking', () {
    test('Records recent logins and preserves ordering and timestamps', () {
      final auth = AuthService.instance;
      auth.clearRecentLogins();
      expect(auth.recentLogins, isEmpty);
      expect(auth.lastLogin, isNull);

      auth.recordLogin('dhananjaya1@gmail.com');
      expect(auth.recentLogins.length, 1);
      expect(auth.lastLogin?.email, 'dhananjaya1@gmail.com');
      expect(auth.lastLogin?.roleName, 'Truck Driver');
      expect(auth.lastLogin?.userName, 'Kasun Perera');

      auth.recordLogin('dhananjaya2@gmail.com');
      expect(auth.recentLogins.length, 2);
      expect(auth.lastLogin?.email, 'dhananjaya2@gmail.com');
      expect(auth.lastLogin?.roleName, 'Customs Inspector');

      // Removing a specific recent login
      auth.removeRecentLogin('dhananjaya1@gmail.com');
      expect(auth.recentLogins.length, 1);
      expect(auth.lastLogin?.email, 'dhananjaya2@gmail.com');

      auth.clearRecentLogins();
      expect(auth.recentLogins, isEmpty);
    });
  });

  group('LoginScreen - Recent Logins UI', () {
    testWidgets('Displays saved recent logins and tapping auto-fills credentials', (tester) async {
      setScreenSize(tester);

      final auth = AuthService.instance;
      auth.clearRecentLogins();
      auth.recordLogin('dhananjaya1@gmail.com');

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      // Verify Recent Logins header and card are visible
      expect(find.text('Recent Logins'), findsOneWidget);
      expect(find.text('Kasun Perera'), findsOneWidget);
      expect(find.textContaining('dhananjaya1@gmail.com'), findsWidgets);
      expect(find.text('Save recent login details'), findsOneWidget);

      // Tap on the recent login card to auto-fill
      await tester.tap(find.text('Kasun Perera'));
      await tester.pump();

      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(emailField.controller?.text, 'dhananjaya1@gmail.com');

      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.controller?.text, isEmpty);
    });

    testWidgets('Removing recent login clears it from the list', (tester) async {
      setScreenSize(tester);

      final auth = AuthService.instance;
      auth.clearRecentLogins();
      auth.recordLogin('dhananjaya1@gmail.com');

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      expect(find.text('Kasun Perera'), findsOneWidget);

      // Tap remove icon
      await tester.tap(find.byTooltip('Remove recent login'));
      await tester.pump();

      expect(find.text('Kasun Perera'), findsNothing);
    });
  });
}
