import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Structured result of cross-track deviation analysis
class CrossTrackDeviationResult {
  /// Exact shortest distance from vehicle position to corridor polyline in meters
  final double deviationMeters;

  /// Whether vehicle exceeds the corridor tolerance threshold (default: 50.0 meters)
  final bool isDeviated;

  /// Corridor tolerance threshold in meters (SRS specified: 50.0m)
  final double toleranceMeters;

  /// Index of the closest polyline segment (from points[nearestSegmentIndex] to points[nearestSegmentIndex + 1])
  final int nearestSegmentIndex;

  /// Exact projected or closest coordinate on the approved transit corridor
  final LatLng nearestCorridorPoint;

  const CrossTrackDeviationResult({
    required this.deviationMeters,
    required this.isDeviated,
    this.toleranceMeters = CrossTrackCalculator.defaultToleranceMeters,
    required this.nearestSegmentIndex,
    required this.nearestCorridorPoint,
  });

  @override
  String toString() {
    return 'CrossTrackDeviationResult(distance: ${deviationMeters.toStringAsFixed(1)}m, deviated: $isDeviated, tolerance: ${toleranceMeters}m)';
  }
}

/// Geodesic Cross-Track Distance Calculator
/// Uses spherical trigonometry and great-circle navigation equations to compute
/// the exact perpendicular (cross-track) distance between any GPS coordinate and
/// an approved customs transit corridor polyline.
class CrossTrackCalculator {
  CrossTrackCalculator._();

  /// Mean radius of the Earth in meters (WGS84 / IUGG standard)
  static const double earthRadiusMeters = 6371000.0;

  /// Sri Lanka Customs SRS specified corridor boundary buffer tolerance (50.0 meters)
  static const double defaultToleranceMeters = 50.0;

  /// Converts degrees to radians
  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Computes the great-circle surface distance between two coordinates in meters
  /// using the numerically stable Haversine formula.
  static double haversineDistance(LatLng p1, LatLng p2) {
    final lat1 = _toRadians(p1.latitude);
    final lat2 = _toRadians(p2.latitude);
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLon = _toRadians(p2.longitude - p1.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt((1.0 - a).clamp(0.0, 1.0)));

    return earthRadiusMeters * c;
  }

  /// Computes the initial bearing (forward azimuth) from coordinate [from] to [to] in radians [-pi, pi]
  static double initialBearing(LatLng from, LatLng to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return math.atan2(y, x);
  }

  /// Calculates the exact shortest distance in meters from a point [p] to a line segment [a, b].
  /// Employs along-track (ATD) and cross-track (XTD) spherical geometry.
  ///
  /// Returns a record with:
  /// - `distance`: shortest distance in meters to segment
  /// - `closestPoint`: closest coordinate on segment [a, b]
  static ({double distance, LatLng closestPoint}) distanceToSegment(
    LatLng p,
    LatLng a,
    LatLng b,
  ) {
    final d12 = haversineDistance(a, b);
    if (d12 < 0.1) {
      // Degenerate segment: a and b are essentially the same point
      return (distance: haversineDistance(p, a), closestPoint: a);
    }

    final d13 = haversineDistance(a, p);
    if (d13 < 0.1) {
      return (distance: 0.0, closestPoint: a);
    }

    final delta13 = d13 / earthRadiusMeters;
    final delta12 = d12 / earthRadiusMeters;

    final theta13 = initialBearing(a, p);
    final theta12 = initialBearing(a, b);
    final deltaTheta = theta13 - theta12;

    // Cross-track angular distance
    final sinDeltaXt = math.sin(delta13) * math.sin(deltaTheta);
    final deltaXt = math.asin(sinDeltaXt.clamp(-1.0, 1.0));

    // Check projection along track
    final cosDeltaXt = math.cos(deltaXt);
    final cosDeltaAt = cosDeltaXt.abs() > 1e-12
        ? (math.cos(delta13) / cosDeltaXt).clamp(-1.0, 1.0)
        : 1.0;
    final deltaAt = math.acos(cosDeltaAt);

    // If cos(deltaTheta) < 0, projection is behind point A
    if (math.cos(deltaTheta) < 0) {
      return (distance: d13, closestPoint: a);
    }

    // If along-track distance exceeds segment length, projection is beyond point B
    if (deltaAt > delta12) {
      return (distance: haversineDistance(p, b), closestPoint: b);
    }

    // Perpendicular projection falls directly on segment [a, b]
    final xtDistance = (deltaXt.abs() * earthRadiusMeters);

    // Calculate the exact projected coordinate on segment [a, b]
    final fraction = (deltaAt / delta12).clamp(0.0, 1.0);
    final projLat = a.latitude + (b.latitude - a.latitude) * fraction;
    final projLng = a.longitude + (b.longitude - a.longitude) * fraction;

    return (distance: xtDistance, closestPoint: LatLng(projLat, projLng));
  }

  /// Calculates the exact cross-track deviation of point [position] from the [corridor] polyline.
  /// Iterates through all constituent segments and finds the global minimum distance.
  static CrossTrackDeviationResult measureDeviation({
    required LatLng position,
    required List<LatLng> corridor,
    double toleranceMeters = defaultToleranceMeters,
  }) {
    if (corridor.isEmpty) {
      return CrossTrackDeviationResult(
        deviationMeters: 0.0,
        isDeviated: false,
        toleranceMeters: toleranceMeters,
        nearestSegmentIndex: 0,
        nearestCorridorPoint: position,
      );
    }

    if (corridor.length == 1) {
      final d = haversineDistance(position, corridor.first);
      return CrossTrackDeviationResult(
        deviationMeters: d,
        isDeviated: d > toleranceMeters,
        toleranceMeters: toleranceMeters,
        nearestSegmentIndex: 0,
        nearestCorridorPoint: corridor.first,
      );
    }

    double minDistance = double.infinity;
    int bestSegmentIndex = 0;
    LatLng bestPoint = corridor.first;

    for (int i = 0; i < corridor.length - 1; i++) {
      final a = corridor[i];
      final b = corridor[i + 1];

      final result = distanceToSegment(position, a, b);
      if (result.distance < minDistance) {
        minDistance = result.distance;
        bestSegmentIndex = i;
        bestPoint = result.closestPoint;
      }
    }

    final isDeviated = minDistance > toleranceMeters;

    return CrossTrackDeviationResult(
      deviationMeters: minDistance,
      isDeviated: isDeviated,
      toleranceMeters: toleranceMeters,
      nearestSegmentIndex: bestSegmentIndex,
      nearestCorridorPoint: bestPoint,
    );
  }
}
