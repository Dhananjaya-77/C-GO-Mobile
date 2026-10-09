import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'google_maps_routes_service.dart';

class MapService extends ChangeNotifier {
  final List<LatLng> _routePoints = [];
  final Set<Marker> _markers = {};
  bool _isLoadingRoute = false;

  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  Set<Marker> get markers => Set.unmodifiable(_markers);
  bool get isLoadingRoute => _isLoadingRoute;

  Set<Polyline> get polylines {
    if (_routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: const Color(0xFF1565C0),
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      )
    };
  }

  void addPoint(LatLng point) {
    _routePoints.add(point);
    notifyListeners();
  }

  void clearRoute() {
    _routePoints.clear();
    _markers.clear();
    notifyListeners();
  }

  void addDestination(LatLng pos, {String? id, String? label}) {
    final markerId = id ?? 'dest-${_markers.length + 1}';
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: pos,
        infoWindow: InfoWindow(title: label ?? 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    notifyListeners();
  }

  /// Calculates route between the first and last point using official Google Maps Routes API v2
  Future<void> calculateRouteWithGoogleApi() async {
    if (_routePoints.length < 2) return;
    _isLoadingRoute = true;
    notifyListeners();

    try {
      final origin = _routePoints.first;
      final destination = _routePoints.last;
      final result = await GoogleMapsRoutesService.instance.computeRoute(
        origin: origin,
        destination: destination,
      );

      if (result.polylinePoints.isNotEmpty) {
        _routePoints.clear();
        _routePoints.addAll(result.polylinePoints);
      }
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }
}
