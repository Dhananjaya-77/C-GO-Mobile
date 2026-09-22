import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetrack_mobile/models/container_model.dart';
import 'package:securetrack_mobile/models/driver_model.dart';
import 'package:securetrack_mobile/models/trip_model.dart';
import 'package:securetrack_mobile/models/vehicle_model.dart';
import 'package:securetrack_mobile/screens/driver/tabs/driver_home_tab.dart';
import 'package:securetrack_mobile/widgets/sensor_telemetry_card.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('DriverHomeTab - Automated IoT Sensor Tamper Monitoring', () {
    testWidgets('Driver dashboard does not show manual simulate door tamper breach button', (tester) async {
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

      // Verify manual simulate door tamper buttons are completely removed
      expect(find.text('Simulate Door Tamper Breach (for Screenshot)'), findsNothing);
      expect(find.text('Simulate Disarm & Restore Normal'), findsNothing);

      // Verify automated IoT monitoring badge is displayed instead
      expect(find.textContaining('Hardware IoT Sensors Active'), findsOneWidget);
    });

    testWidgets('Security breach auto-generates with incoming IoT sensor telemetry signals', (tester) async {
      setScreenSize(tester);

      final vehicle = VehicleInfo.mockVehicle;
      final driver = DriverProfile.mockDriver;
      final trip = TripInfo.mockActiveTrip;

      final telemetryStreamController = StreamController<SensorTelemetry>.broadcast();
      addTearDown(() => telemetryStreamController.close());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverHomeTab(
              driver: driver,
              vehicle: vehicle,
              activeTrip: trip,
              telemetryStream: telemetryStreamController.stream,
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

      // Initial state: secure
      expect(find.text('ALL SEALS SECURE'), findsOneWidget);
      expect(find.text('DOOR CLOSED'), findsOneWidget);

      // Send automated IoT sensor signal: reed switch opened
      final breachedTelemetry = ContainerInfo.mockPrimaryContainer.telemetry.copyWith(
        isMagneticReedClosed: false,
        lightSensorLux: 120.0,
      );

      telemetryStreamController.add(breachedTelemetry);
      await tester.pump();

      // Tamper breach is auto-generated strictly from sensor signals
      expect(find.text('TAMPER BREACH'), findsOneWidget);
      expect(find.text('DOOR OPENED'), findsOneWidget);
      expect(find.text('Security Breach Auto-Detected via IoT Lock Telemetry'), findsOneWidget);

      // Send automated IoT sensor signal: seals restored & door closed
      final restoredTelemetry = ContainerInfo.mockPrimaryContainer.telemetry.copyWith(
        isMagneticReedClosed: true,
        lightSensorLux: 0.0,
      );

      telemetryStreamController.add(restoredTelemetry);
      await tester.pump();

      expect(find.text('ALL SEALS SECURE'), findsOneWidget);
      expect(find.text('DOOR CLOSED'), findsOneWidget);
    });

    testWidgets('SensorTelemetryCard alone displays hardware monitoring badge when onTestTamperPressed is null', (tester) async {
      final container = ContainerInfo.mockPrimaryContainer;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorTelemetryCard(
              container: container,
            ),
          ),
        ),
      );

      expect(find.text('Simulate Door Tamper Breach (for Screenshot)'), findsNothing);
      expect(find.textContaining('Hardware IoT Sensors Active'), findsOneWidget);
    });
  });
}
