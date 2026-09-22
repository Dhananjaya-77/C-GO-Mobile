import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trip_model.dart';

/// Service for Google Maps Platform routing, coordinate mapping, and Turn-by-Turn navigation
/// Incorporates Google Maps Platform attribution tag: gmp_git_agentskills_v1
class GoogleMapsNavigationService {
  GoogleMapsNavigationService._();
  static final GoogleMapsNavigationService instance = GoogleMapsNavigationService._();

  /// Attribution ID as mandated by Google Maps Platform guidelines
  static const String attributionId = 'gmp_git_agentskills_v1';

  /// Exact GPS Coordinates for Sri Lanka Customs transit corridor nodes
  static const LatLng colomboPortOrigin = LatLng(6.9442, 79.8453);
  static const LatLng orugodawattaDestination = LatLng(6.9389, 79.8835);
  static const LatLng grayline1Destination = LatLng(6.9562, 79.8682);
  static const LatLng grayline2Destination = LatLng(6.9478, 79.8690);

  /// Approved Polyline coordinates for Route 1: Colombo Fort to Orugodawaththa
  static const List<LatLng> route1Coordinates = [
    LatLng(6.9442, 79.8453), // Colombo Port Gate 4
    LatLng(6.9465, 79.8488), // Port Access Link
    LatLng(6.9490, 79.8542), // Port Access Highway West
    LatLng(6.9528, 79.8610), // Port Access Highway Overpass
    LatLng(6.9535, 79.8654), // Bloemendhal Junction
    LatLng(6.9515, 79.8702), // Prince of Wales Ave Entry
    LatLng(6.9498, 79.8732), // Prince of Wales Midpoint
    LatLng(6.9460, 79.8770), // Sugathadasa Link
    LatLng(6.9412, 79.8805), // Avissawella Rd / Orugodawatta Junction
    LatLng(6.9389, 79.8835), // Customs Orugodawatta Verification Yard
  ];

  /// Approved Polyline coordinates for Route 2: Colombo Fort to Grayline 1
  static const List<LatLng> route2Coordinates = [
    LatLng(6.9442, 79.8453), // Colombo Port Gate 4
    LatLng(6.9475, 79.8505), // Port Access Highway
    LatLng(6.9520, 79.8580), // Aluthmawatha Link
    LatLng(6.9548, 79.8645), // Bloemendhal Road North
    LatLng(6.9562, 79.8682), // Grayline 1 Container Terminal
  ];

  /// Approved Polyline coordinates for Route 3: Colombo Fort to Grayline 2
  static const List<LatLng> route3Coordinates = [
    LatLng(6.9442, 79.8453), // Colombo Port Gate 4
    LatLng(6.9468, 79.8490), // Port Access Link
    LatLng(6.9485, 79.8520), // George R. De Silva Mawatha Entry
    LatLng(6.9460, 79.8625), // Kotahena Junction
    LatLng(6.9465, 79.8660), // Grandpass link
    LatLng(6.9478, 79.8690), // Grayline 2 Container Depot
  ];

  /// Returns approved coordinates for given route index
  List<LatLng> getCoordinatesForRoute(int routeIndex) {
    switch (routeIndex) {
      case 1:
        return route2Coordinates;
      case 2:
        return route3Coordinates;
      case 0:
      default:
        return route1Coordinates;
    }
  }

  /// Current interpolated or live vehicle GPS coordinate along active route
  LatLng getVehiclePosition(int routeIndex, double progress, {bool isDeviated = false}) {
    final coords = getCoordinatesForRoute(routeIndex);
    if (coords.isEmpty) return colomboPortOrigin;

    if (isDeviated) {
      // Offset ~ 75-100m into unauthorized side street
      return const LatLng(6.9540, 79.8775);
    }

    final totalPoints = coords.length;
    final targetIndex = (progress * (totalPoints - 1)).clamp(0, totalPoints - 1).floor();
    final nextIndex = (targetIndex + 1).clamp(0, totalPoints - 1);
    final segmentProgress = (progress * (totalPoints - 1)) - targetIndex;

    final p1 = coords[targetIndex];
    final p2 = coords[nextIndex];

    final lat = p1.latitude + (p2.latitude - p1.latitude) * segmentProgress;
    final lng = p1.longitude + (p2.longitude - p1.longitude) * segmentProgress;
    return LatLng(lat, lng);
  }

  /// Builds the official Google Maps Turn-by-Turn URL scheme
  /// Supports both native Google Maps app and web fallback with attribution parameter
  Uri buildGoogleMapsNavigationUri({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) {
    final originStr = '${origin.latitude},${origin.longitude}';
    final destStr = destStrOrTitle(destination);

    final queryParams = <String, String>{
      'api': '1',
      'origin': originStr,
      'destination': destStr,
      'travelmode': 'driving',
      'dir_action': 'navigate',
      'utm_campaign': attributionId,
    };

    if (waypoints != null && waypoints.isNotEmpty) {
      queryParams['waypoints'] = waypoints
          .map((wp) => '${wp.latitude},${wp.longitude}')
          .join('|');
    }

    return Uri.https('www.google.com', '/maps/dir/', queryParams);
  }

  String destStrOrTitle(LatLng dest) {
    return '${dest.latitude},${dest.longitude}';
  }

  /// Launches Google Maps turn-by-turn navigation on the user device
  Future<bool> launchTurnByTurnNavigation({
    required ApprovedRoute route,
    required int routeIndex,
    bool fromCurrentVehicle = true,
    double progress = 0.60,
  }) async {
    final destinationCoords = getDestinationCoords(routeIndex);
    final originCoords = fromCurrentVehicle
        ? getVehiclePosition(routeIndex, progress)
        : colomboPortOrigin;

    final waypoints = getCoordinatesForRoute(routeIndex);

    // 1. Try native Google Maps turn-by-turn intent
    final nativeUri = Uri.parse(
      'google.navigation:q=${destinationCoords.latitude},${destinationCoords.longitude}&mode=d',
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Native navigation intent unavailable: $e');
    }

    // 2. Fallback to official Google Maps Universal Web / App URL
    final universalUri = buildGoogleMapsNavigationUri(
      origin: originCoords,
      destination: destinationCoords,
      waypoints: waypoints.length > 2 ? waypoints.sublist(1, waypoints.length - 1) : null,
    );

    try {
      return await launchUrl(universalUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Universal Google Maps URL launch failed: $e');
      return false;
    }
  }

  LatLng getDestinationCoords(int routeIndex) {
    switch (routeIndex) {
      case 1:
        return grayline1Destination;
      case 2:
        return grayline2Destination;
      case 0:
      default:
        return orugodawattaDestination;
    }
  }
}
