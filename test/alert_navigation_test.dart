import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_alerts_tab.dart';
import 'package:securetrack_mobile/utils/alert_navigation_helper.dart';

void main() {
  group('AlertNavigationHelper Unit Tests', () {
    test('Route Deviation alert maps to Navigate section (Tab 1)', () {
      final target = AlertNavigationHelper.resolveAlertOrigin(
        'Route Deviation',
        'You deviated from the optimized route 15 minutes ago',
      );
      expect(target.tabIndex, 1);
      expect(target.sectionName, 'Live Route Navigation');
    });

    test('Traffic and Weather alerts map to Navigate section (Tab 1)', () {
      final weatherTarget = AlertNavigationHelper.resolveAlertOrigin(
        'Weather Update',
        'Light rain expected on your route in 1 hour',
      );
      expect(weatherTarget.tabIndex, 1);

      final trafficTarget = AlertNavigationHelper.resolveAlertOrigin(
        'Traffic Alert',
        'Heavy traffic detected ahead, adding 20 min to ETA',
      );
      expect(trafficTarget.tabIndex, 1);
    });

    test('Checkpoint Passed alert maps to Trip Details section (Tab 3)', () {
      final target = AlertNavigationHelper.resolveAlertOrigin(
        'Checkpoint Passed',
        'You successfully passed checkpoint #3 (Ingurukade Flyover)',
      );
      expect(target.tabIndex, 3);
      expect(target.sectionName, 'Trip Details & Security');
    });

    test('Smart Lock & Seal alerts map to Trip Details section (Tab 3)', () {
      final target = AlertNavigationHelper.resolveAlertOrigin(
        'Smart Lock Armed',
        'Electronic Smart Lock RFID SL-RFID-99214 armed for container',
      );
      expect(target.tabIndex, 3);
    });

    test('Emergency SOS alerts map to Home section (Tab 0)', () {
      final target = AlertNavigationHelper.resolveAlertOrigin(
        'Customs Emergency Notice',
        'Patrol unit dispatched for emergency inspection',
      );
      expect(target.tabIndex, 0);
    });

    test('Profile & rating alerts map to Profile section (Tab 4)', () {
      final target = AlertNavigationHelper.resolveAlertOrigin(
        'Driver Safety Score',
        'Driver rating updated to 4.96 for current shift',
      );
      expect(target.tabIndex, 4);
    });
  });

  group('DriverAlertsTab Widget Interaction Tests', () {
    testWidgets('Tapping Route Deviation alert invokes onNavigateToSection with Tab 1',
        (WidgetTester tester) async {
      int? navigatedTab;
      String? alertName;
      String? targetSection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverAlertsTab(
              onNavigateToSection: (tabIndex, title, sectionName) {
                navigatedTab = tabIndex;
                alertName = title;
                targetSection = sectionName;
              },
            ),
          ),
        ),
      );

      // Verify that Route Deviation card is present
      expect(find.text('Route Deviation'), findsOneWidget);
      expect(find.text('View in Live Navigate'), findsWidgets);

      // Tap the Route Deviation notification card
      await tester.tap(find.text('Route Deviation'));
      await tester.pumpAndSettle();

      expect(navigatedTab, 1);
      expect(alertName, 'Route Deviation');
      expect(targetSection, 'Live Route Navigation');
    });

    testWidgets('Tapping Checkpoint Passed alert invokes onNavigateToSection with Tab 3',
        (WidgetTester tester) async {
      int? navigatedTab;
      String? alertName;
      String? targetSection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverAlertsTab(
              onNavigateToSection: (tabIndex, title, sectionName) {
                navigatedTab = tabIndex;
                alertName = title;
                targetSection = sectionName;
              },
            ),
          ),
        ),
      );

      // Scroll and tap Checkpoint Passed
      final checkpointFinder = find.text('Checkpoint Passed');
      expect(checkpointFinder, findsOneWidget);

      await tester.tap(checkpointFinder);
      await tester.pumpAndSettle();

      expect(navigatedTab, 3);
      expect(alertName, 'Checkpoint Passed');
      expect(targetSection, 'Trip Details & Security');
    });
  });
}
