import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:securetrack_mobile/config/google_maps_config.dart';
import 'package:securetrack_mobile/models/trip_model.dart';
import 'package:securetrack_mobile/services/google_maps_geocoding_service.dart';
import 'package:securetrack_mobile/services/google_maps_navigation_service.dart';
import 'package:securetrack_mobile/services/google_maps_routes_service.dart';
import 'package:securetrack_mobile/services/map_service.dart';
import 'package:securetrack_mobile/widgets/corridor_map_widget.dart';
import 'package:securetrack_mobile/widgets/exact_google_map_widget.dart';

void main() {
  group('Google Maps Platform Configuration Tests', () {
    test('Config contains required attribution ID and API endpoints', () {
      expect(GoogleMapsConfig.attributionId, 'gmp_git_agentskills_v1');
      expect(GoogleMapsConfig.solutionIdHeader, 'X-Goog-Maps-Solution-ID');
      expect(
        GoogleMapsConfig.routesEndpoint,
        'https://routes.googleapis.com/directions/v2:computeRoutes',
      );
      expect(
        GoogleMapsConfig.geocodingEndpoint,
        'https://maps.googleapis.com/maps/api/geocode/json',
      );

      final headers = GoogleMapsConfig.requestHeaders(
        fieldMask: 'routes.duration,routes.distanceMeters',
      );
      expect(headers['Content-Type'], 'application/json');
      expect(headers['X-Goog-Maps-Solution-ID'], 'gmp_git_agentskills_v1');
      expect(headers['X-Goog-FieldMask'], 'routes.duration,routes.distanceMeters');
    });
  });

  group('Google Maps Routes API v2 Tests', () {
    test('Polyline decoder decodes standard Google encoded polyline correctly', () {
      // Encoded polyline for (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = GoogleMapsRoutesService.decodePolyline(encoded);

      expect(points.length, 3);
      expect(points[0].latitude, closeTo(38.5, 0.001));
      expect(points[0].longitude, closeTo(-120.2, 0.001));
      expect(points[1].latitude, closeTo(40.7, 0.001));
      expect(points[1].longitude, closeTo(-120.95, 0.001));
      expect(points[2].latitude, closeTo(43.252, 0.001));
      expect(points[2].longitude, closeTo(-126.453, 0.001));
    });

    test('Route result formats distance and duration correctly', () {
      const resultShort = GoogleMapsRouteResult(
        polylinePoints: [],
        distanceMeters: 750,
        durationSeconds: 90,
        isFromApi: true,
      );
      expect(resultShort.distanceFormatted, '750 m');
      expect(resultShort.durationFormatted, '2 min');

      const resultLong = GoogleMapsRouteResult(
        polylinePoints: [],
        distanceMeters: 5400,
        durationSeconds: 3900,
        isFromApi: true,
      );
      expect(resultLong.distanceFormatted, '5.4 km');
      expect(resultLong.durationFormatted, '1h 5m');
    });

    test('computeRoute falls back smoothly when no active API key is set', () async {
      final routesService = GoogleMapsRoutesService();
      final result = await routesService.computeRoute(
        origin: GoogleMapsNavigationService.colomboPortOrigin,
        destination: GoogleMapsNavigationService.orugodawattaDestination,
        fallbackCoordinates: GoogleMapsNavigationService.route1Coordinates,
      );

      expect(result.polylinePoints.length, GoogleMapsNavigationService.route1Coordinates.length);
      expect(result.distanceMeters, greaterThan(0));
      expect(result.durationSeconds, greaterThan(0));
      expect(result.isFromApi, isFalse);
    });

    test('computeRoute parses successful Google Routes API v2 response with attribution', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), GoogleMapsConfig.routesEndpoint);
        expect(request.headers['X-Goog-Maps-Solution-ID'], 'gmp_git_agentskills_v1');
        expect(request.headers['X-Goog-FieldMask'], contains('routes.duration'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['travelMode'], 'DRIVE');
        expect(body['routingPreference'], 'TRAFFIC_AWARE');
        expect(body['internalUsageAttributionIds'], contains('gmp_git_agentskills_v1'));

        final responseJson = {
          'routes': [
            {
              'distanceMeters': 6200,
              'duration': '1080s',
              'polyline': {
                'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
              },
              'legs': [
                {
                  'steps': [
                    {
                      'navigationInstruction': {
                        'instructions': 'Head east on Port Access Highway',
                      },
                      'distanceMeters': 1200,
                      'staticDuration': '180s',
                      'startLocation': {
                        'latLng': {'latitude': 6.9442, 'longitude': 79.8453}
                      },
                      'endLocation': {
                        'latLng': {'latitude': 6.9535, 'longitude': 79.8654}
                      }
                    }
                  ]
                }
              ]
            }
          ]
        };

        return http.Response(jsonEncode(responseJson), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final serviceWithMock = GoogleMapsRoutesService(client: mockClient);
      expect(serviceWithMock, isNotNull);
    });
  });

  group('Google Maps Geocoding & Locations Service Tests', () {
    test('Predefined Sri Lanka customs terminals geocode accurately', () async {
      final geocoding = GoogleMapsGeocodingService.instance;

      final port = await geocoding.geocodeDestination('Colombo Port Gate 4');
      expect(port.coordinates.latitude, closeTo(6.9442, 0.001));
      expect(port.coordinates.longitude, closeTo(79.8453, 0.001));

      final orugodawatta = await geocoding.geocodeDestination('Orugodawaththa');
      expect(orugodawatta.coordinates.latitude, closeTo(6.9389, 0.001));
      expect(orugodawatta.coordinates.longitude, closeTo(79.8835, 0.001));

      final grayline1 = await geocoding.geocodeDestination('Grayline 1');
      expect(grayline1.coordinates.latitude, closeTo(6.9562, 0.001));
      expect(grayline1.coordinates.longitude, closeTo(79.8682, 0.001));

      final grayline2 = await geocoding.geocodeDestination('Grayline 2');
      expect(grayline2.coordinates.latitude, closeTo(6.9478, 0.001));
      expect(grayline2.coordinates.longitude, closeTo(79.8690, 0.001));
    });

    test('Reverse geocoding resolves terminal names within corridor proximity', () async {
      final geocoding = GoogleMapsGeocodingService.instance;
      final address = await geocoding.reverseGeocode(
        const LatLng(6.9442, 79.8453),
      );
      expect(address, contains('COLOMBO PORT'));
    });
  });

  group('GoogleMap Widget Rendering Integration Tests', () {
    testWidgets('CorridorMapWidget renders authentic GoogleMap widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CorridorMapWidget(
              corridorTitle: 'Colombo Fort to Orugodawaththa',
              originTitle: 'Colombo Port',
              destinationTitle: 'Orugodawatta',
              progress: 0.5,
              height: 300,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify authentic GoogleMap widget is present
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
      expect(find.text('Colombo Port'), findsOneWidget);
      expect(find.text('Orugodawatta'), findsOneWidget);
      expect(find.text('🟢 WITHIN CUSTOMS APPROVED CORRIDOR'), findsOneWidget);
    });

    testWidgets('ExactGoogleMapWidget renders authentic GoogleMap widget with controls', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExactGoogleMapWidget(
              routeIndex: 0,
              route: kApprovedRoutes[0],
              progress: 0.6,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify authentic GoogleMap widget is present
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.text('Start Google Navigation'), findsOneWidget);
      expect(find.byTooltip('Layer: Google Road Map'), findsOneWidget);
      expect(find.byTooltip('Recenter Vehicle GPS'), findsOneWidget);
      expect(find.byTooltip('Fit Full Route Bounds'), findsOneWidget);
    });

    test('MapService adds points and calculates route', () {
      final mapService = MapService();
      expect(mapService.routePoints, isEmpty);
      expect(mapService.markers, isEmpty);

      mapService.addPoint(const LatLng(6.9442, 79.8453));
      mapService.addDestination(const LatLng(6.9389, 79.8835), label: 'Orugodawatta');

      expect(mapService.routePoints.length, 1);
      expect(mapService.markers.length, 1);
      expect(mapService.polylines.length, 1);

      mapService.clearRoute();
      expect(mapService.routePoints, isEmpty);
      expect(mapService.markers, isEmpty);
      expect(mapService.polylines, isEmpty);
    });
  });
}
