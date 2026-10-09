import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/google_maps_config.dart';

/// Geocoded location model from Google Maps Geocoding API
class GoogleGeocodedLocation {
  final String formattedAddress;
  final LatLng coordinates;
  final String? placeId;
  final List<String> types;
  final bool isFromApi;

  const GoogleGeocodedLocation({
    required this.formattedAddress,
    required this.coordinates,
    this.placeId,
    this.types = const [],
    required this.isFromApi,
  });
}

/// Official Google Maps Geocoding and Location Service
/// Provides forward and reverse geocoding for maps, locations, and destinations
/// with full attribution compliance (gmp_git_agentskills_v1).
class GoogleMapsGeocodingService {
  final http.Client _client;

  GoogleMapsGeocodingService({http.Client? client})
      : _client = client ?? http.Client();

  static final GoogleMapsGeocodingService instance = GoogleMapsGeocodingService();

  /// Known predefined customs transit terminals in Colombo, Sri Lanka
  static const Map<String, LatLng> _customsCorridorDestinations = {
    'colombo port': LatLng(6.9442, 79.8453),
    'colombo port gate 4': LatLng(6.9442, 79.8453),
    'orugodawatta': LatLng(6.9389, 79.8835),
    'orugodawaththa': LatLng(6.9389, 79.8835),
    'customs orugodawatta verification yard': LatLng(6.9389, 79.8835),
    'grayline 1': LatLng(6.9562, 79.8682),
    'grayline 1 container terminal': LatLng(6.9562, 79.8682),
    'grayline 2': LatLng(6.9478, 79.8690),
    'grayline 2 container depot': LatLng(6.9478, 79.8690),
  };

  /// Geocodes an address or destination name to LatLng using Google Geocoding API
  Future<GoogleGeocodedLocation> geocodeDestination(String query) async {
    final lower = query.trim().toLowerCase();

    // Check predefined approved customs locations first
    for (final entry in _customsCorridorDestinations.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return GoogleGeocodedLocation(
          formattedAddress: query,
          coordinates: entry.value,
          placeId: 'customs-${entry.key.replaceAll(' ', '-')}',
          types: ['transit_station', 'establishment'],
          isFromApi: false,
        );
      }
    }

    if (!GoogleMapsConfig.hasValidApiKey) {
      return GoogleGeocodedLocation(
        formattedAddress: query,
        coordinates: const LatLng(6.9442, 79.8453),
        placeId: 'default-colombo-port',
        isFromApi: false,
      );
    }

    final uri = Uri.parse(GoogleMapsConfig.geocodingEndpoint).replace(
      queryParameters: {
        'address': query,
        'key': GoogleMapsConfig.apiKey,
        'utm_campaign': GoogleMapsConfig.attributionId,
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          final formatted = first['formatted_address'] as String? ?? query;
          final placeId = first['place_id'] as String?;
          final geom = first['geometry']?['location'] as Map<String, dynamic>?;
          final lat = (geom?['lat'] as num?)?.toDouble() ?? 6.9442;
          final lng = (geom?['lng'] as num?)?.toDouble() ?? 79.8453;
          final types = (first['types'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [];

          return GoogleGeocodedLocation(
            formattedAddress: formatted,
            coordinates: LatLng(lat, lng),
            placeId: placeId,
            types: types,
            isFromApi: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Google Geocoding API exception: $e');
    }

    return GoogleGeocodedLocation(
      formattedAddress: query,
      coordinates: const LatLng(6.9442, 79.8453),
      isFromApi: false,
    );
  }

  /// Reverse geocodes a GPS coordinate to a street address using Google Geocoding API
  Future<String> reverseGeocode(LatLng coordinates) async {
    // Check known proximity
    for (final entry in _customsCorridorDestinations.entries) {
      final dLat = (coordinates.latitude - entry.value.latitude).abs();
      final dLng = (coordinates.longitude - entry.value.longitude).abs();
      if (dLat < 0.003 && dLng < 0.003) {
        return entry.key.toUpperCase();
      }
    }

    if (!GoogleMapsConfig.hasValidApiKey) {
      return '${coordinates.latitude.toStringAsFixed(4)}° N, ${coordinates.longitude.toStringAsFixed(4)}° E (Colombo Corridor)';
    }

    final uri = Uri.parse(GoogleMapsConfig.geocodingEndpoint).replace(
      queryParameters: {
        'latlng': '${coordinates.latitude},${coordinates.longitude}',
        'key': GoogleMapsConfig.apiKey,
        'utm_campaign': GoogleMapsConfig.attributionId,
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          final formatted = first['formatted_address'] as String?;
          if (formatted != null && formatted.isNotEmpty) {
            return formatted;
          }
        }
      }
    } catch (e) {
      debugPrint('Google Reverse Geocoding API exception: $e');
    }

    return '${coordinates.latitude.toStringAsFixed(4)}° N, ${coordinates.longitude.toStringAsFixed(4)}° E';
  }
}
