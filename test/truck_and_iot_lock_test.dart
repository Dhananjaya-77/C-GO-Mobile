import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/models/container_model.dart';
import 'package:securetrack_mobile/models/driver_model.dart';
import 'package:securetrack_mobile/models/trip_model.dart';
import 'package:securetrack_mobile/models/vehicle_model.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_home_tab.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_vehicle_tab.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DriverVehicleTab - Truck Model & Registration with Assigned IoT Lock Details', () {
    testWidgets('Displays only truck model and registration, removing old truck diagnostics', (tester) async {
      setScreenSize(tester);

      final vehicle = VehicleInfo.mockVehicle;
      final container = ContainerInfo.mockPrimaryContainer;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverVehicleTab(
              vehicle: vehicle,
              container: container,
            ),
          ),
        ),
      );

      // Verify Truck Model and Registration Number are displayed
      expect(find.text(vehicle.plateNumber), findsOneWidget);
      expect(find.text(vehicle.modelName), findsOneWidget);
      expect(find.text('TRUCK REGISTRATION'), findsOneWidget);

      // Verify removed truck details are NOT displayed
      expect(find.textContaining('Fuel Tank Level'), findsNothing);
      expect(find.textContaining('Engine Coolant Temp'), findsNothing);
      expect(find.textContaining('Tire Pressure (Avg)'), findsNothing);
      expect(find.textContaining('Fleet Documents & Compliance'), findsNothing);
      expect(find.textContaining('Speed Governor Certificate'), findsNothing);
      expect(find.textContaining('Comprehensive Insurance'), findsNothing);

      // Verify assigned IoT lock details are displayed
      expect(find.text('Assigned IoT Lock Details'), findsOneWidget);
      expect(find.text(container.rfidLockId), findsWidgets);
      expect(find.text(container.iotDeviceId), findsOneWidget);
      expect(find.text(container.containerNumber), findsOneWidget);
      expect(find.text(container.physicalSealNumber), findsOneWidget);
      expect(find.text('IoT Smart Lock Armed'), findsOneWidget);
      expect(find.text('Lock Shackle / Door Bar'), findsOneWidget);
      expect(find.text('Customs Bolt Seal Integrity'), findsOneWidget);
      expect(find.text('IoT Lock Battery'), findsOneWidget);
      expect(find.text('GPS Geofence Lock'), findsOneWidget);

      // Verify light sensor details are NOT displayed
      expect(find.textContaining('Optical Anti-Tamper Sensor'), findsNothing);
      expect(find.textContaining('Ambient Light Sensor'), findsNothing);
      expect(find.textContaining('LUX'), findsNothing);
    });
  });

  group('DriverHomeTab - Truck & Assigned IoT Lock Card', () {
    testWidgets('Displays truck model and registration along with assigned IoT lock', (tester) async {
      setScreenSize(tester);

      final vehicle = VehicleInfo.mockVehicle;
      final driver = DriverProfile.mockDriver;
      final trip = TripInfo.mockActiveTrip;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverHomeTab(
              driver: driver,
              vehicle: vehicle,
              activeTrip: trip,
              isOnDuty: true,
              onDutyChanged: (_) {},
              onSosPressed: () {},
              onInspectionPressed: () {},
              onIncidentReportPressed: () {},
              onTripActionPressed: () {},
              onViewRoutesPressed: () {},
              onNextStopReached: () {},
              recentAlerts: const ['Clearance ok'],
            ),
          ),
        ),
      );

      // Verify section header
      expect(find.text('Truck & Assigned IoT Lock'), findsOneWidget);

      // Verify Truck Model and Registration Number
      expect(find.text(vehicle.modelName), findsOneWidget);
      expect(find.text('Truck Reg: ${vehicle.plateNumber}'), findsOneWidget);

      // Verify assigned IoT lock info is shown
      expect(find.textContaining('Assigned Smart Lock: ${vehicle.assignedLockId}'), findsOneWidget);
      expect(find.text('LOCK ARMED'), findsOneWidget);

      // Verify removed truck diagnostics are NOT present
      expect(find.text('Fuel Level'), findsNothing);
      expect(find.text('Engine Temp'), findsNothing);
      expect(find.text('Tire Pressure'), findsNothing);
    });
  });
}
