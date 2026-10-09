/// Configuration for Google Maps Platform services in the C GO Mobile App.
/// Supports build-time `--dart-define=MAPS_API_KEY=...` or runtime configuration.
/// Incorporates official Google Maps Platform attribution and modern endpoints.
class GoogleMapsConfig {
  GoogleMapsConfig._();

  /// Default placeholder or active Google Maps Platform API key.
  /// Replace 'YOUR_GOOGLE_MAPS_API_KEY' with your key, or run with:
  /// `flutter run --dart-define=MAPS_API_KEY=YOUR_KEY`
  static const String apiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
  );

  /// Internal Usage Attribution ID as mandated by Google Maps Platform guidelines
  static const String attributionId = 'gmp_git_agentskills_v1';

  /// Solution ID header name for Google Maps Platform REST APIs
  static const String solutionIdHeader = 'X-Goog-Maps-Solution-ID';

  /// Official Google Maps Routes API v2 endpoint for computing routes, distances, and ETAs
  static const String routesEndpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  /// Official Google Maps Geocoding API endpoint for address/coordinates resolution
  static const String geocodingEndpoint =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Official Google Maps Places API (New) Text Search endpoint
  static const String placesTextSearchEndpoint =
      'https://places.googleapis.com/v1/places:searchText';

  /// Returns true if an actual API key is configured (not the default placeholder)
  static bool get hasValidApiKey {
    return apiKey.isNotEmpty &&
        apiKey != 'YOUR_GOOGLE_MAPS_API_KEY' &&
        !apiKey.startsWith('YOUR_');
  }

  /// Constructs common headers required by Google Maps Platform REST APIs
  static Map<String, String> requestHeaders({String? fieldMask}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      solutionIdHeader: attributionId,
    };
    if (fieldMask != null && fieldMask.isNotEmpty) {
      headers['X-Goog-FieldMask'] = fieldMask;
    }
    return headers;
  }
}
