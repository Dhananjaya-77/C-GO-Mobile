/// Configuration for Google Maps Platform services in the C GO Mobile App.
/// Supports both build-time `--dart-define=MAPS_API_KEY=...` and configuration files.
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

  /// Returns true if an actual API key is configured (not the default placeholder)
  static bool get hasValidApiKey {
    return apiKey.isNotEmpty &&
        apiKey != 'YOUR_GOOGLE_MAPS_API_KEY' &&
        !apiKey.startsWith('YOUR_');
  }
}
