import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  GoogleMapController? _controller;

  static const CameraPosition _initialPosition = CameraPosition(target: LatLng(37.4219999, -122.0840575), zoom: 14);

  @override
  void initState() {
    super.initState();
    _mapService.addListener(_onMapServiceChanged);
  }

  @override
  void dispose() {
    _mapService.removeListener(_onMapServiceChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _onMapServiceChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map — Route Tracker')),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _mapService.markers,
        polylines: _mapService.polylines,
        onMapCreated: (c) => _controller = c,
        onTap: (pos) {
          // Add destination marker on tap
          _mapService.addDestination(pos, label: 'Destination');
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_point',
            child: const Icon(Icons.add_location_alt),
            onPressed: () {
              // For demo: add current center as a route point
              _controller?.getVisibleRegion().then((bounds) {
                final center = LatLng((bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                    (bounds.northeast.longitude + bounds.southwest.longitude) / 2);
                _mapService.addPoint(center);
              });
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'clear',
            backgroundColor: Colors.red,
            onPressed: _mapService.clearRoute,
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
