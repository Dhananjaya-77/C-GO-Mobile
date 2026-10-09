import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/google_maps_config.dart';

/// Step maneuver information returned by Google Maps Routes API
class GoogleRouteStep {
  final String instruction;
  final int distanceMeters;
  final String durationText;
  final LatLng startLocation;
  final LatLng endLocation;

  const GoogleRouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationText,
    required this.startLocation,
    required this.endLocation,
  });
}

/// Result returned from Google Maps Routes API v2 computeRoutes
class GoogleMapsRouteResult {
  final List<LatLng> polylinePoints;
  final int distanceMeters;
  final int durationSeconds;
  final String? encodedPolyline;
  final List<GoogleRouteStep> steps;
  final bool isFromApi;
  final String? errorMessage;

  const GoogleMapsRouteResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    this.encodedPolyline,
    this.steps = const [],
    required this.isFromApi,
    this.errorMessage,
  });

  String get distanceFormatted {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }

  String get durationFormatted {
    final minutes = (durationSeconds / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return '${hours}h ${remainingMins}m';
    }
    return '$minutes min';
  }
}

/// Official Google Maps Routes API v2 Service
/// Connects to https://routes.googleapis.com/directions/v2:computeRoutes
/// incorporating mandatory solution attribution and field masks.
class GoogleMapsRoutesService {
  final http.Client _client;

  GoogleMapsRoutesService({http.Client? client})
      : _client = client ?? http.Client();

  static final GoogleMapsRoutesService instance = GoogleMapsRoutesService();

  /// Decodes Google Maps Encoded Polyline into LatLng coordinates
  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  /// Computes a route using official Google Maps Routes API v2
  Future<GoogleMapsRouteResult> computeRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? intermediates,
    List<LatLng>? fallbackCoordinates,
  }) async {
    final hasValidKey = GoogleMapsConfig.hasValidApiKey;

    if (!hasValidKey) {
      return _fallbackResult(
        fallbackCoordinates: fallbackCoordinates,
        origin: origin,
        destination: destination,
        message: 'No active Google Maps API key provided. Using corridor geometry.',
      );
    }

    final url = Uri.parse(GoogleMapsConfig.routesEndpoint);
    final headers = GoogleMapsConfig.requestHeaders(
      fieldMask:
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs.steps',
    );

    final intermediateList = (intermediates != null && intermediates.isNotEmpty)
        ? intermediates.map((pt) {
            return {
              'location': {
                'latLng': {
                  'latitude': pt.latitude,
                  'longitude': pt.longitude,
                }
              }
            };
          }).toList()
        : null;

    final requestBody = <String, dynamic>{
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          }
        }
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      'polylineQuality': 'HIGH_QUALITY',
      'internalUsageAttributionIds': [GoogleMapsConfig.attributionId],
    };

    if (intermediateList != null) {
      requestBody['intermediates'] = intermediateList;
    }

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes[0] as Map<String, dynamic>;
          final distanceMeters = firstRoute['distanceMeters'] as int? ?? 0;
          final durationStr = firstRoute['duration'] as String? ?? '0s';
          final durationSec = int.tryParse(durationStr.replaceAll('s', '')) ?? 0;

          final polylineObj = firstRoute['polyline'] as Map<String, dynamic>?;
          final encoded = polylineObj?['encodedPolyline'] as String?;

          List<LatLng> points = [];
          if (encoded != null && encoded.isNotEmpty) {
            points = decodePolyline(encoded);
          } else if (fallbackCoordinates != null && fallbackCoordinates.isNotEmpty) {
            points = fallbackCoordinates;
          } else {
            points = [origin, destination];
          }

          final steps = <GoogleRouteStep>[];
          final legs = firstRoute['legs'] as List<dynamic>?;
          if (legs != null && legs.isNotEmpty) {
            for (final leg in legs) {
              final rawSteps = leg['steps'] as List<dynamic>?;
              if (rawSteps != null) {
                for (final s in rawSteps) {
                  final instr = s['navigationInstruction']?['instructions'] ?? '';
                  final dMeters = s['distanceMeters'] as int? ?? 0;
                  final durText = s['staticDuration'] as String? ?? '';
                  final startLat = s['startLocation']?['latLng']?['latitude'] as double? ?? 0.0;
                  final startLng = s['startLocation']?['latLng']?['longitude'] as double? ?? 0.0;
                  final endLat = s['endLocation']?['latLng']?['latitude'] as double? ?? 0.0;
                  final endLng = s['endLocation']?['latLng']?['longitude'] as double? ?? 0.0;
                  steps.add(GoogleRouteStep(
                    instruction: instr,
                    distanceMeters: dMeters,
                    durationText: durText,
                    startLocation: LatLng(startLat, startLng),
                    endLocation: LatLng(endLat, endLng),
                  ));
                }
              }
            }
          }

          return GoogleMapsRouteResult(
            polylinePoints: points,
            distanceMeters: distanceMeters,
            durationSeconds: durationSec,
            encodedPolyline: encoded,
            steps: steps,
            isFromApi: true,
          );
        }
      }

      debugPrint('Google Maps Routes API error: ${response.statusCode} - ${response.body}');
      return _fallbackResult(
        fallbackCoordinates: fallbackCoordinates,
        origin: origin,
        destination: destination,
        message: 'Google Routes API status: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Google Maps Routes API exception: $e');
      return _fallbackResult(
        fallbackCoordinates: fallbackCoordinates,
        origin: origin,
        destination: destination,
        message: e.toString(),
      );
    }
  }

  GoogleMapsRouteResult _fallbackResult({
    List<LatLng>? fallbackCoordinates,
    required LatLng origin,
    required LatLng destination,
    String? message,
  }) {
    final points = (fallbackCoordinates != null && fallbackCoordinates.isNotEmpty)
        ? fallbackCoordinates
        : [origin, destination];

    // Estimate ~42 km/h transit speed over points
    double totalDistKm = 0;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final dLat = (p2.latitude - p1.latitude).abs() * 111.0;
      final dLng = (p2.longitude - p1.longitude).abs() * 111.0;
      totalDistKm += (dLat + dLng);
    }
    final meters = (totalDistKm * 1000).round();
    final durationSec = ((totalDistKm / 42.0) * 3600).round().clamp(600, 3600);

    return GoogleMapsRouteResult(
      polylinePoints: points,
      distanceMeters: meters > 0 ? meters : 5600,
      durationSeconds: durationSec > 0 ? durationSec : 1080,
      isFromApi: false,
      errorMessage: message,
    );
  }
}
