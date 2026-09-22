import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.locationWhenInUse.request();
      if (!result.isGranted) {
        // show a simple dialog explaining why location is needed
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Location permission'),
              content: const Text('Location permission is required to track routes.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ),
          );
        }
      }
    }
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
