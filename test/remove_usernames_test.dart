import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/screens/driver/driver_dashboard_screen.dart';
import 'package:securetrack_mobile/screens/inspector/inspector_dashboard_screen.dart';
import 'package:securetrack_mobile/screens/owner/container_owner_dashboard.dart';
import 'package:securetrack_mobile/screens/owner/owner_dashboard_screen.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('Username Removal from Dashboards', () {
    testWidgets('Driver Dashboard does not display driver or inspector personal names', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure personal names are removed
      expect(find.textContaining('Kasun Perera'), findsNothing);
      expect(find.textContaining('Inspector Kamal'), findsNothing);

      // Verify header title is present and greeting/customs transport words are removed from top
      expect(find.text('Driver Navigation Module'), findsOneWidget);
      expect(find.textContaining('Good Morning'), findsNothing);
      expect(find.textContaining('Customs Transport'), findsNothing);
    });

    testWidgets('Inspector Dashboard does not display inspector personal name or hauler driver name', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(const MaterialApp(home: InspectorDashboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure personal names are removed
      expect(find.textContaining('Kamal Wickramasinghe'), findsNothing);
      expect(find.textContaining('Dhammika Bandara'), findsNothing);

      // Verify department / role title is present
      expect(find.textContaining('Customs Enforcement Division'), findsOneWidget);
    });

    testWidgets('Container Owner Dashboard does not display personal username/email in app bar', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(const MaterialApp(home: ContainerOwnerDashboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure username email and inspector name are removed
      expect(find.text('dhananjaya3@gmail.com'), findsNothing);
      expect(find.textContaining('Insp. Kamal'), findsNothing);

      // Verify role title is present
      expect(find.textContaining('Cargo Fleet Monitoring'), findsOneWidget);
    });

    testWidgets('Owner Dashboard Screen does not display personal driver or inspector names in cargo details', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(const MaterialApp(home: OwnerDashboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure personal names are removed
      expect(find.textContaining('Kasun Perera'), findsNothing);
      expect(find.textContaining('Insp. Kamal'), findsNothing);
      expect(find.textContaining('Kamal Wickramasinghe'), findsNothing);

      // Verify generalized division / mover labels are present
      expect(find.text('Authorized Prime Mover'), findsOneWidget);
      expect(find.text('Supervising Division'), findsOneWidget);
    });
  });
}
