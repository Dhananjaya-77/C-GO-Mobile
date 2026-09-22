import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/models/trip_model.dart';
import 'package:securetrack_mobile/models/container_model.dart';
import 'package:securetrack_mobile/models/shipment_model.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_navigate_tab.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_trip_tab.dart';
import 'package:securetrack_mobile/models/vehicle_model.dart';

void main() {
  group('3 Approved Routes Integration Tests', () {
    test('Exactly 3 approved routes are configured', () {
      expect(kApprovedRoutes.length, 3);

      expect(kApprovedRoutes[0].name, 'Colombo Fort to Orugodawaththa');
      expect(kApprovedRoutes[0].origin, 'Colombo Fort');
      expect(kApprovedRoutes[0].destination, 'Orugodawaththa');

      expect(kApprovedRoutes[1].name, 'Colombo Fort to Grayline 1');
      expect(kApprovedRoutes[1].origin, 'Colombo Fort');
      expect(kApprovedRoutes[1].destination, 'Grayline 1');

      expect(kApprovedRoutes[2].name, 'Colombo Fort to Grayline 2');
      expect(kApprovedRoutes[2].origin, 'Colombo Fort');
      expect(kApprovedRoutes[2].destination, 'Grayline 2');
    });

    test('Mock trips strictly use approved 3 routes', () {
      final active = TripInfo.mockActiveTrip;
      expect(active.origin, 'Colombo Fort');
      expect(active.destination, 'Orugodawaththa');
      expect(active.routeName, contains('Colombo Fort ➔ Orugodawaththa'));

      final completed = TripInfo.mockCompletedTrips;
      expect(completed.length, 2);
      expect(completed[0].routeName, contains('Colombo Fort ➔ Grayline 1'));
      expect(completed[0].origin, 'Colombo Fort');
      expect(completed[0].destination, 'Grayline 1');

      expect(completed[1].routeName, contains('Colombo Fort ➔ Grayline 2'));
      expect(completed[1].origin, 'Colombo Fort');
      expect(completed[1].destination, 'Grayline 2');
    });

    test('Mock containers fleet strictly use approved 3 routes', () {
      for (final container in ContainerInfo.mockContainerFleet) {
        expect(container.originPort, 'Colombo Fort');
        expect(
          ['Orugodawaththa', 'Grayline 1', 'Grayline 2'],
          contains(container.destinationDepot),
        );
        expect(
          [
            'Colombo Fort to Orugodawaththa',
            'Colombo Fort to Grayline 1',
            'Colombo Fort to Grayline 2',
          ],
          contains(container.designatedCorridor),
        );
      }
    });

    test('Mock shipment strictly uses approved route', () {
      final shipment = ShipmentInfo.mockActiveShipment;
      expect(shipment.origin, 'Colombo Fort');
      expect(shipment.destination, 'Orugodawaththa');
      expect(shipment.corridorName, 'Colombo Fort to Orugodawaththa');
    });

    testWidgets('DriverNavigateTab renders only driver own registered transport details for the single active route', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverNavigateTab(),
          ),
        ),
      );

      // Verify driver own registered transport details appear
      expect(find.text('REGISTERED TRANSPORT'), findsOneWidget);
      expect(find.text('COR-2026-0842'), findsOneWidget);
      expect(find.text('MSCU-742910-8'), findsOneWidget);
      expect(find.text('SL-RFID-99214'), findsOneWidget);
      expect(find.text('Route 1'), findsOneWidget);
      expect(find.textContaining('Orugodawaththa'), findsAtLeast(1));
      expect(find.text('18 min'), findsOneWidget);

      // Driver cannot see or switch to other routes at that time
      expect(find.text('Grayline 1'), findsNothing);
      expect(find.text('Grayline 2'), findsNothing);
    });

    testWidgets('DriverTripTab displays Colombo Fort and Orugodawaththa without obsolete locations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverTripTab(
              activeTrip: TripInfo.mockActiveTrip,
              vehicle: VehicleInfo.mockVehicle,
              container: ContainerInfo.mockPrimaryContainer,
            ),
          ),
        ),
      );

      expect(find.text('Colombo Fort'), findsOneWidget);
      expect(find.text('Orugodawaththa'), findsOneWidget);
      expect(find.textContaining('Katunayake'), findsNothing);
      expect(find.textContaining('Peliyagoda'), findsNothing);
    });
  });
}
