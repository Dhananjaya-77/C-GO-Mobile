import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService extends ChangeNotifier {
  final List<LatLng> _routePoints = [];
  final Set<Marker> _markers = {};

  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  Set<Marker> get markers => Set.unmodifiable(_markers);

  Set<Polyline> get polylines {
    if (_routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: const Color(0xFF1565C0),
        width: 5,
      )
    };
  }

  void addPoint(LatLng point) {
    _routePoints.add(point);
    notifyListeners();
  }

  void clearRoute() {
    _routePoints.clear();
    notifyListeners();
  }

  void addDestination(LatLng pos, {String? id, String? label}) {
    final markerId = id ?? 'dest-${_markers.length + 1}';
    _markers.add(Marker(markerId: MarkerId(markerId), position: pos, infoWindow: InfoWindow(title: label)));
    notifyListeners();
  }
}
