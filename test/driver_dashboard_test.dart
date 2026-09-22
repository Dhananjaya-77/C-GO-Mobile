import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/screens/driver/driver_dashboard_screen.dart';
import 'package:securetrack_mobile/screens/inspector/inspector_dashboard_screen.dart';
import 'package:securetrack_mobile/screens/owner/container_owner_dashboard.dart';
import 'package:securetrack_mobile/screens/owner/owner_dashboard_screen.dart';
import 'package:securetrack_mobile/screens/driver/widgets/sos_dialog.dart';
import 'package:securetrack_mobile/screens/login_screen.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('dhananjaya1@gmail.com navigates to DriverDashboardScreen', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, 'dhananjaya1@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DriverDashboardScreen), findsOneWidget);
    expect(find.byTooltip('Switch Dashboard Role'), findsNothing);
    expect(find.text('Switch Role Dashboard'), findsNothing);
  });

  testWidgets('dhananjaya2@gmail.com navigates to InspectorDashboardScreen', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, 'dhananjaya2@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(InspectorDashboardScreen), findsOneWidget);
    expect(find.text('Customs Inspector Portal'), findsOneWidget);
    expect(find.byTooltip('Switch Dashboard Role'), findsNothing);
  });

  testWidgets('dhananjaya3@gmail.com navigates to ContainerOwnerDashboardScreen', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, 'dhananjaya3@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ContainerOwnerDashboardScreen), findsOneWidget);
    expect(find.text('Container Owner Portal'), findsOneWidget);
    expect(find.byTooltip('Switch Dashboard Role'), findsNothing);
  });

  testWidgets('Unauthorized email is blocked from accessing dashboards', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, 'unauthorized@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DriverDashboardScreen), findsNothing);
    expect(find.byType(InspectorDashboardScreen), findsNothing);
    expect(find.byType(ContainerOwnerDashboardScreen), findsNothing);
    expect(find.text('Access restricted. Unauthorized account.'), findsOneWidget);
  });

  testWidgets('DriverDashboardScreen does not contain switch dashboard role button', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('Switch Dashboard Role'), findsNothing);
    expect(find.text('Switch Role Dashboard'), findsNothing);
  });

  testWidgets('InspectorDashboardScreen does not contain switch dashboard role button', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: InspectorDashboardScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('Switch Dashboard Role'), findsNothing);
  });

  testWidgets('OwnerDashboardScreen does not contain switch dashboard role button', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: OwnerDashboardScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('Switch Dashboard Role'), findsNothing);
  });

  testWidgets('Emergency SOS Dialog can be opened from AppBar in DriverDashboardScreen', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Emergency SOS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SosDialog), findsOneWidget);
    expect(find.text('EMERGENCY SOS ALERT'), findsOneWidget);
  });

  testWidgets('Quick Logout button is present in top right corner of DriverDashboardScreen and opens confirmation dialog', (tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('Logout'), findsOneWidget);
    await tester.tap(find.byTooltip('Logout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Confirm Sign Out'), findsOneWidget);
    expect(find.text('Are you sure you want to sign out of the Driver Dashboard?'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
