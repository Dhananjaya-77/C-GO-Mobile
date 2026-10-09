import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:securetrack_mobile/services/google_maps_navigation_service.dart';
import 'package:securetrack_mobile/services/gps_tracking_service.dart';
import 'package:securetrack_mobile/utils/cross_track_calculator.dart';

void main() {
  group('CrossTrackCalculator Unit Tests', () {
    test('Haversine distance calculation is accurate and handles identical coordinates', () {
      const p1 = LatLng(6.9442, 79.8453); // Colombo Port
      const p2 = LatLng(6.9442, 79.8453);

      expect(CrossTrackCalculator.haversineDistance(p1, p2), closeTo(0.0, 0.001));

      // 1 degree latitude difference is ~111,195 meters
      const p3 = LatLng(7.9442, 79.8453);
      final dist1Deg = CrossTrackCalculator.haversineDistance(p1, p3);
      expect(dist1Deg, closeTo(111195, 500));
    });

    test('Initial bearing calculation handles cardinal directions', () {
      const origin = LatLng(6.9000, 79.8000);
      const north = LatLng(7.0000, 79.8000);
      const east = LatLng(6.9000, 79.9000);

      final bearingNorth = CrossTrackCalculator.initialBearing(origin, north);
      expect(bearingNorth, closeTo(0.0, 0.01));

      final bearingEast = CrossTrackCalculator.initialBearing(origin, east);
      expect(bearingEast, closeTo(math.pi / 2, 0.01));
    });

    test('Distance to segment for point exactly on segment returns zero', () {
      const a = LatLng(6.9442, 79.8453);
      const b = LatLng(6.9542, 79.8453);
      // Midpoint
      const mid = LatLng(6.9492, 79.8453);

      final result = CrossTrackCalculator.distanceToSegment(mid, a, b);
      expect(result.distance, closeTo(0.0, 0.5));
      expect(result.closestPoint.latitude, closeTo(mid.latitude, 0.0001));
      expect(result.closestPoint.longitude, closeTo(mid.longitude, 0.0001));
    });

    test('Distance to segment before start point returns distance to start point', () {
      const a = LatLng(6.9442, 79.8453);
      const b = LatLng(6.9542, 79.8453);
      // Point 200m south of A (before segment start)
      const southOfA = LatLng(6.9424, 79.8453);

      final result = CrossTrackCalculator.distanceToSegment(southOfA, a, b);
      final directDist = CrossTrackCalculator.haversineDistance(southOfA, a);
      expect(result.distance, closeTo(directDist, 0.5));
      expect(result.closestPoint, a);
    });

    test('Distance to segment after end point returns distance to end point', () {
      const a = LatLng(6.9442, 79.8453);
      const b = LatLng(6.9542, 79.8453);
      // Point north of B (past segment end)
      const northOfB = LatLng(6.9560, 79.8453);

      final result = CrossTrackCalculator.distanceToSegment(northOfB, a, b);
      final directDist = CrossTrackCalculator.haversineDistance(northOfB, b);
      expect(result.distance, closeTo(directDist, 0.5));
      expect(result.closestPoint, b);
    });

    test('Perpendicular cross-track distance measures exact lateral displacement', () {
      // Segment along meridian
      const a = LatLng(6.9400, 79.8400);
      const b = LatLng(6.9600, 79.8400);

      // Point offset laterally to the east by ~0.00045 degrees (~50m)
      // At lat 6.95, 1 deg lon = 111195 * cos(6.95 deg) ≈ 110380 m
      // 50m / 110380m ≈ 0.000453 deg
      const offsetLat = 6.9500;
      const offsetLon = 79.8400 + 0.000453;
      const p = LatLng(offsetLat, offsetLon);

      final result = CrossTrackCalculator.distanceToSegment(p, a, b);
      expect(result.distance, closeTo(50.0, 1.5));
    });

    test('50-meter tolerance threshold correctly classifies on-corridor and deviated points', () {
      final corridor = GoogleMapsNavigationService.route1Coordinates;

      // 1. Vehicle directly on corridor waypoint (Colombo Port) -> distance = 0
      final onRouteResult = CrossTrackCalculator.measureDeviation(
        position: corridor[2],
        corridor: corridor,
        toleranceMeters: 50.0,
      );
      expect(onRouteResult.deviationMeters, closeTo(0.0, 0.1));
      expect(onRouteResult.isDeviated, isFalse);
      expect(onRouteResult.toleranceMeters, 50.0);

      // 2. Interpolated vehicle at progress = 0.5 on corridor
      final interpolatedVehicle = GoogleMapsNavigationService.instance.getVehiclePosition(0, 0.5);
      final midRouteResult = CrossTrackCalculator.measureDeviation(
        position: interpolatedVehicle,
        corridor: corridor,
        toleranceMeters: 50.0,
      );
      expect(midRouteResult.deviationMeters, lessThanOrEqualTo(10.0));
      expect(midRouteResult.isDeviated, isFalse);

      // 3. Small lateral displacement (25m < 50m tolerance) -> Not deviated
      // Point with ~25m offset from corridor[3]
      final smallOffsetPos = LatLng(corridor[3].latitude + 0.0002, corridor[3].longitude);
      final smallOffsetResult = CrossTrackCalculator.measureDeviation(
        position: smallOffsetPos,
        corridor: corridor,
        toleranceMeters: 50.0,
      );
      expect(smallOffsetResult.deviationMeters, lessThan(50.0));
      expect(smallOffsetResult.isDeviated, isFalse);

      // 4. Large unauthorized side street deviation (e.g. 75m - 200m off corridor) -> Deviated
      final unauthorizedSideStreet = GoogleMapsNavigationService.instance.getVehiclePosition(
        0,
        0.60,
        isDeviated: true,
      );
      final deviatedResult = CrossTrackCalculator.measureDeviation(
        position: unauthorizedSideStreet,
        corridor: corridor,
        toleranceMeters: 50.0,
      );
      expect(deviatedResult.deviationMeters, greaterThan(50.0));
      expect(deviatedResult.isDeviated, isTrue);
    });

    test('Corridor measurement handles empty and single-point corridor gracefully', () {
      const pos = LatLng(6.9442, 79.8453);
      final emptyResult = CrossTrackCalculator.measureDeviation(
        position: pos,
        corridor: const [],
        toleranceMeters: 50.0,
      );
      expect(emptyResult.deviationMeters, 0.0);
      expect(emptyResult.isDeviated, isFalse);

      final singleResult = CrossTrackCalculator.measureDeviation(
        position: const LatLng(6.9460, 79.8453),
        corridor: [pos],
        toleranceMeters: 50.0,
      );
      expect(singleResult.deviationMeters, greaterThan(0.0));
      expect(singleResult.isDeviated, isTrue);
    });
  });

  group('GpsTrackingService Unit Tests', () {
    test('Service initializes with default state and Sri Lanka customs origin', () {
      final service = GpsTrackingService.instance;
      expect(service.currentState.position, GoogleMapsNavigationService.colomboPortOrigin);
      expect(service.toleranceMeters, 50.0);
      expect(service.activeRouteIndex, 0);
    });

    test('Simulated deviation toggle accurately updates cross-track deviation state', () {
      final service = GpsTrackingService.instance;

      // Start simulated tracking on Route 1
      service.startTracking(routeIndex: 0, forceSimulation: true);
      expect(service.isTracking, isTrue);
      expect(service.currentState.deviation.isDeviated, isFalse);

      // Toggle deviation
      service.toggleSimulatedDeviation();
      expect(service.currentState.deviation.isDeviated, isTrue);
      expect(service.currentState.deviation.deviationMeters, greaterThan(50.0));

      // Restore deviation
      service.toggleSimulatedDeviation();
      expect(service.currentState.deviation.isDeviated, isFalse);
      expect(service.currentState.deviation.deviationMeters, lessThanOrEqualTo(50.0));
    });

    test('testPosition accurately evaluates custom coordinates against active corridor', () {
      final service = GpsTrackingService.instance;
      service.startTracking(routeIndex: 0, forceSimulation: true);

      // Coordinate directly on Route 1 Bloemendhal Junction
      service.testPosition(const LatLng(6.9535, 79.8654));
      expect(service.currentState.deviation.deviationMeters, closeTo(0.0, 0.1));
      expect(service.currentState.isDeviated, isFalse);

      // Coordinate deviated 150m away
      service.testPosition(const LatLng(6.9600, 79.8800));
      expect(service.currentState.deviation.deviationMeters, greaterThan(50.0));
      expect(service.currentState.isDeviated, isTrue);
    });
  });
}
