import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_navigate_tab.dart';
import 'package:securetrack_mobile/services/google_maps_navigation_service.dart';
import 'package:securetrack_mobile/widgets/exact_google_map_widget.dart';

void main() {
  group('Google Maps Navigation Service Tests', () {
    final navService = GoogleMapsNavigationService.instance;

    test('Coordinates and destinations configured for all 3 approved routes', () {
      expect(GoogleMapsNavigationService.colomboPortOrigin.latitude, closeTo(6.9442, 0.001));
      expect(GoogleMapsNavigationService.colomboPortOrigin.longitude, closeTo(79.8453, 0.001));

      // Route 1 Destination: Orugodawatta
      final dest1 = navService.getDestinationCoords(0);
      expect(dest1.latitude, closeTo(6.9389, 0.001));
      expect(dest1.longitude, closeTo(79.8835, 0.001));

      // Route 2 Destination: Grayline 1
      final dest2 = navService.getDestinationCoords(1);
      expect(dest2.latitude, closeTo(6.9562, 0.001));
      expect(dest2.longitude, closeTo(79.8682, 0.001));

      // Route 3 Destination: Grayline 2
      final dest3 = navService.getDestinationCoords(2);
      expect(dest3.latitude, closeTo(6.9478, 0.001));
      expect(dest3.longitude, closeTo(79.8690, 0.001));
    });

    test('Polyline coordinate lists contain approved transit corridor waypoints', () {
      final r1Coords = navService.getCoordinatesForRoute(0);
      final r2Coords = navService.getCoordinatesForRoute(1);
      final r3Coords = navService.getCoordinatesForRoute(2);

      expect(r1Coords.length, greaterThanOrEqualTo(5));
      expect(r2Coords.length, greaterThanOrEqualTo(4));
      expect(r3Coords.length, greaterThanOrEqualTo(4));

      // All routes start from Colombo Port Origin
      expect(r1Coords.first, GoogleMapsNavigationService.colomboPortOrigin);
      expect(r2Coords.first, GoogleMapsNavigationService.colomboPortOrigin);
      expect(r3Coords.first, GoogleMapsNavigationService.colomboPortOrigin);

      // End at their respective destination terminal
      expect(r1Coords.last, navService.getDestinationCoords(0));
      expect(r2Coords.last, navService.getDestinationCoords(1));
      expect(r3Coords.last, navService.getDestinationCoords(2));
    });

    test('Vehicle GPS interpolation and deviation calculation', () {
      // At progress = 0.0, vehicle is at Colombo Port
      final startPos = navService.getVehiclePosition(0, 0.0);
      expect(startPos.latitude, closeTo(6.9442, 0.001));
      expect(startPos.longitude, closeTo(79.8453, 0.001));

      // At progress = 1.0, vehicle is at Orugodawatta
      final endPos = navService.getVehiclePosition(0, 1.0);
      expect(endPos.latitude, closeTo(6.9389, 0.001));
      expect(endPos.longitude, closeTo(79.8835, 0.001));

      // When deviated, returns unauthorized side coordinate
      final devPos = navService.getVehiclePosition(0, 0.60, isDeviated: true);
      expect(devPos.latitude, closeTo(6.9540, 0.001));
      expect(devPos.longitude, closeTo(79.8775, 0.001));
    });

    test('Google Maps Navigation Universal URL contains mandatory attribution and coordinates', () {
      final uri = navService.buildGoogleMapsNavigationUri(
        origin: GoogleMapsNavigationService.colomboPortOrigin,
        destination: navService.getDestinationCoords(0),
        waypoints: [const LatLng(6.9535, 79.8654)],
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['travelmode'], 'driving');
      expect(uri.queryParameters['origin'], contains('6.9442,79.8453'));
      expect(uri.queryParameters['destination'], contains('6.9389,79.8835'));
      expect(uri.queryParameters['waypoints'], contains('6.9535,79.8654'));
      expect(uri.queryParameters['utm_campaign'], GoogleMapsNavigationService.attributionId);
    });
  });

  group('ExactGoogleMapWidget and DriverNavigateTab Integration Tests', () {
    testWidgets('DriverNavigateTab renders ExactGoogleMapWidget with navigation action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverNavigateTab(),
          ),
        ),
      );
      await tester.pump();

      // Verify ExactGoogleMapWidget exists in widget tree
      expect(find.byType(ExactGoogleMapWidget), findsOneWidget);

      // Verify Turn-by-Turn Navigation Launch Button is rendered
      expect(find.text('Start Google Navigation'), findsOneWidget);
      expect(find.byIcon(Icons.navigation_rounded), findsOneWidget);

      // Verify Map controls: cycle map layers, recenter GPS, and fit bounds
      expect(find.byTooltip('Layer: Google Road Map'), findsOneWidget);
      expect(find.byTooltip('Recenter Vehicle GPS'), findsOneWidget);
      expect(find.byTooltip('Fit Full Route Bounds'), findsOneWidget);
    });

    testWidgets('DriverNavigateTab renders only the registered transport corridor without route switcher', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverNavigateTab(),
          ),
        ),
      );
      await tester.pump();

      // Initially Route 1: Orugodawaththa registered transport
      expect(find.text('REGISTERED TRANSPORT'), findsOneWidget);
      expect(find.text('Route 1'), findsOneWidget);
      expect(find.textContaining('Orugodawaththa'), findsAtLeast(1));
      expect(find.text('18 min'), findsOneWidget);

      // Other routes are not selectable
      expect(find.text('Grayline 1'), findsNothing);
      expect(find.text('Grayline 2'), findsNothing);
    });
  });
}
