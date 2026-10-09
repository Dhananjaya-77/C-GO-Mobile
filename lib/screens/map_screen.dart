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

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.9442, 79.8453), // Colombo Port Origin
    zoom: 14,
  );

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
      appBar: AppBar(
        title: const Text('Map — Route Tracker'),
        actions: [
          if (_mapService.routePoints.length >= 2)
            IconButton(
              icon: _mapService.isLoadingRoute
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.alt_route_rounded),
              tooltip: 'Calculate Route via Google Routes API',
              onPressed: _mapService.isLoadingRoute
                  ? null
                  : () => _mapService.calculateRouteWithGoogleApi(),
            ),
        ],
      ),
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
          _mapService.addPoint(pos);
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_point',
            tooltip: 'Add current center as point',
            child: const Icon(Icons.add_location_alt),
            onPressed: () {
              _controller?.getVisibleRegion().then((bounds) {
                final center = LatLng(
                  (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                  (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
                );
                _mapService.addPoint(center);
              });
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'clear',
            backgroundColor: Colors.red,
            tooltip: 'Clear route and markers',
            onPressed: _mapService.clearRoute,
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
