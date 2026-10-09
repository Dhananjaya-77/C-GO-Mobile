// Source: Google Maps Platform Code Assist
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip_model.dart';
import '../services/google_maps_navigation_service.dart';
import '../services/gps_tracking_service.dart';
import '../utils/cross_track_calculator.dart';

enum GoogleMapLayerType {
  standard,
  satellite,
  hybrid,
  terrain,
}

/// Official, interactive Google Map Widget for Sri Lanka Customs transit corridors.
/// Renders authentic Google Maps Platform tiles, approved transit corridor polylines,
/// real-time GPS vehicle position, geofence radius circles, cross-track deviation metrics,
/// and turn-by-turn navigation.
class ExactGoogleMapWidget extends StatefulWidget {
  final int routeIndex;
  final ApprovedRoute route;
  final double progress; // 0.0 to 1.0
  final bool isDeviated;
  final double deviationMeters;
  final int speedKmH;
  final VoidCallback? onToggleDeviation;
  final bool showControls;
  final bool enableLiveGps;

  const ExactGoogleMapWidget({
    super.key,
    required this.routeIndex,
    required this.route,
    required this.progress,
    this.isDeviated = false,
    this.deviationMeters = 0.0,
    this.speedKmH = 42,
    this.onToggleDeviation,
    this.showControls = true,
    this.enableLiveGps = false,
  });

  @override
  State<ExactGoogleMapWidget> createState() => _ExactGoogleMapWidgetState();
}

class _ExactGoogleMapWidgetState extends State<ExactGoogleMapWidget> {
  GoogleMapController? _googleMapController;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  GoogleMapLayerType _layerType = GoogleMapLayerType.standard;
  bool _isLaunchingNav = false;
  bool _useLiveDeviceGps = false;

  @override
  void initState() {
    super.initState();
    _useLiveDeviceGps = widget.enableLiveGps;
    GpsTrackingService.instance.addListener(_onGpsServiceUpdated);
    if (_useLiveDeviceGps) {
      GpsTrackingService.instance.startTracking(routeIndex: widget.routeIndex);
    }
  }

  @override
  void dispose() {
    GpsTrackingService.instance.removeListener(_onGpsServiceUpdated);
    super.dispose();
  }

  void _onGpsServiceUpdated() {
    if (mounted) setState(() {});
  }

  MapType get _currentMapType {
    switch (_layerType) {
      case GoogleMapLayerType.standard:
        return MapType.normal;
      case GoogleMapLayerType.satellite:
        return MapType.satellite;
      case GoogleMapLayerType.hybrid:
        return MapType.hybrid;
      case GoogleMapLayerType.terrain:
        return MapType.terrain;
    }
  }

  String get _layerTitle {
    switch (_layerType) {
      case GoogleMapLayerType.standard:
        return 'Google Road Map';
      case GoogleMapLayerType.satellite:
        return 'Google Satellite';
      case GoogleMapLayerType.hybrid:
        return 'Google Hybrid';
      case GoogleMapLayerType.terrain:
        return 'Google Terrain';
    }
  }

  void _cycleMapLayer() {
    setState(() {
      switch (_layerType) {
        case GoogleMapLayerType.standard:
          _layerType = GoogleMapLayerType.hybrid;
          break;
        case GoogleMapLayerType.hybrid:
          _layerType = GoogleMapLayerType.terrain;
          break;
        case GoogleMapLayerType.terrain:
          _layerType = GoogleMapLayerType.satellite;
          break;
        case GoogleMapLayerType.satellite:
          _layerType = GoogleMapLayerType.standard;
          break;
      }
    });
  }

  void _toggleLiveGpsTracking() async {
    setState(() => _useLiveDeviceGps = !_useLiveDeviceGps);
    if (_useLiveDeviceGps) {
      await GpsTrackingService.instance.startTracking(routeIndex: widget.routeIndex);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Real device GPS tracking activated (geolocator)'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await GpsTrackingService.instance.stopTracking();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched to simulated corridor GPS navigation'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant ExactGoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeIndex != widget.routeIndex ||
        oldWidget.progress != widget.progress ||
        oldWidget.isDeviated != widget.isDeviated) {
      _recenterOnVehicle();
    }
  }

  void _recenterOnVehicle() {
    final pos = _getVehicleLatLng();
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: 14.5),
      ),
    );
  }

  void _fitRouteBounds() {
    final navService = GoogleMapsNavigationService.instance;
    final coords = navService.getCoordinatesForRoute(widget.routeIndex);
    if (coords.isEmpty || _googleMapController == null) return;

    double minLat = coords.first.latitude;
    double maxLat = coords.first.latitude;
    double minLng = coords.first.longitude;
    double maxLng = coords.first.longitude;

    for (final pt in coords) {
      if (pt.latitude < minLat) minLat = pt.latitude;
      if (pt.latitude > maxLat) maxLat = pt.latitude;
      if (pt.longitude < minLng) minLng = pt.longitude;
      if (pt.longitude > maxLng) maxLng = pt.longitude;
    }

    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.003, minLng - 0.003),
          northeast: LatLng(maxLat + 0.003, maxLng + 0.003),
        ),
        48.0,
      ),
    );
  }

  Future<void> _handleStartTurnByTurn() async {
    setState(() => _isLaunchingNav = true);
    final navService = GoogleMapsNavigationService.instance;

    final success = await navService.launchTurnByTurnNavigation(
      route: widget.route,
      routeIndex: widget.routeIndex,
      fromCurrentVehicle: true,
      progress: widget.progress,
    );

    if (mounted) {
      setState(() => _isLaunchingNav = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Opening Google Maps turn-by-turn navigation to ${widget.route.destination}...',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0E3352),
          ),
        );
      }
    }
  }

  List<LatLng> _getRoutePoints() {
    final navService = GoogleMapsNavigationService.instance;
    return navService.getCoordinatesForRoute(widget.routeIndex);
  }

  LatLng _getVehicleLatLng() {
    if (_useLiveDeviceGps && GpsTrackingService.instance.isTracking) {
      return GpsTrackingService.instance.currentState.position;
    }
    final navService = GoogleMapsNavigationService.instance;
    return navService.getVehiclePosition(
      widget.routeIndex,
      widget.progress,
      isDeviated: widget.isDeviated,
    );
  }

  LatLng _getOriginLatLng() {
    return GoogleMapsNavigationService.colomboPortOrigin;
  }

  LatLng _getDestinationLatLng() {
    final navService = GoogleMapsNavigationService.instance;
    return navService.getDestinationCoords(widget.routeIndex);
  }

  CrossTrackDeviationResult _getCrossTrackDeviation(LatLng vehiclePos, List<LatLng> routePoints) {
    return CrossTrackCalculator.measureDeviation(
      position: vehiclePos,
      corridor: routePoints,
      toleranceMeters: CrossTrackCalculator.defaultToleranceMeters,
    );
  }

  Set<Marker> _buildMarkers(
    LatLng vehiclePos,
    LatLng originPos,
    LatLng destPos,
    CrossTrackDeviationResult deviation,
  ) {
    final isDev = widget.isDeviated || deviation.isDeviated;
    final speed = _useLiveDeviceGps && GpsTrackingService.instance.isTracking
        ? GpsTrackingService.instance.currentState.speedKmH
        : widget.speedKmH;

    return {
      Marker(
        markerId: const MarkerId('origin_gate'),
        position: originPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Port Gate',
          snippet: 'Colombo Fort Gate 4 (Origin)',
        ),
      ),
      Marker(
        markerId: const MarkerId('destination_terminal'),
        position: destPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.route.destination,
          snippet: 'Customs Verification Yard',
        ),
      ),
      Marker(
        markerId: const MarkerId('vehicle_gps'),
        position: vehiclePos,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isDev ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
        ),
        infoWindow: InfoWindow(
          title: _useLiveDeviceGps ? 'Live Vehicle GPS (Device)' : 'Container Vehicle',
          snippet:
              '$speed km/h • Cross-Track: ${deviation.deviationMeters.toStringAsFixed(1)}m ${isDev ? "[DEVIATED]" : "[ON CORRIDOR]"}',
        ),
      ),
    };
  }

  Set<Polyline> _buildPolylines(
    List<LatLng> routePoints,
    LatLng vehiclePos,
    LatLng originPos,
    CrossTrackDeviationResult deviation,
  ) {
    final polylines = <Polyline>{
      // Translucent Geofence Buffer Corridor (50m boundary buffer representation)
      Polyline(
        polylineId: const PolylineId('corridor_buffer'),
        points: routePoints,
        width: 14,
        color: const Color(0xFF0284C7).withValues(alpha: 0.28),
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
      // Solid Approved Route Line (Customs Blue, Width 5)
      Polyline(
        polylineId: const PolylineId('approved_route'),
        points: routePoints,
        width: 5,
        color: const Color(0xFF1D4ED8),
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    if (widget.isDeviated || deviation.isDeviated) {
      // Connect vehicle coordinate to closest point on the approved corridor to highlight cross-track error
      final anchorPoint = deviation.nearestCorridorPoint;
      polylines.add(
        Polyline(
          polylineId: const PolylineId('cross_track_vector'),
          points: [anchorPoint, vehiclePos],
          width: 4,
          color: const Color(0xFFDC2626),
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    return polylines;
  }

  Set<Circle> _buildCircles(LatLng originPos, LatLng destPos) {
    return {
      Circle(
        circleId: const CircleId('origin_radius'),
        center: originPos,
        radius: 120, // 120m radius
        fillColor: const Color(0xFF10B981).withValues(alpha: 0.20),
        strokeColor: const Color(0xFF10B981),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('dest_radius'),
        center: destPos,
        radius: 150, // 150m radius
        fillColor: const Color(0xFF1D4ED8).withValues(alpha: 0.20),
        strokeColor: const Color(0xFF1D4ED8),
        strokeWidth: 2,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final vehiclePos = _getVehicleLatLng();
    final originPos = _getOriginLatLng();
    final destPos = _getDestinationLatLng();
    final routePoints = _getRoutePoints();
    final deviation = _getCrossTrackDeviation(vehiclePos, routePoints);

    return Stack(
      children: [
        // ── Real Interactive Official Google Map ──────────────────────────
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: vehiclePos,
              zoom: 14.0,
            ),
            mapType: _currentMapType,
            markers: _buildMarkers(vehiclePos, originPos, destPos, deviation),
            polylines: _buildPolylines(routePoints, vehiclePos, originPos, deviation),
            circles: _buildCircles(originPos, destPos),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            gestureRecognizers: {
              Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
            },
            onMapCreated: (controller) {
              _googleMapController = controller;
              if (!_controllerCompleter.isCompleted) {
                _controllerCompleter.complete(controller);
              }
            },
          ),
        ),

        // ── Cross-Track Deviation Status Badge ───────────────────────────
        Positioned(
          left: 14,
          bottom: 185,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: deviation.isDeviated || widget.isDeviated
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  deviation.isDeviated || widget.isDeviated
                      ? Icons.warning_amber_rounded
                      : Icons.verified_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  deviation.isDeviated || widget.isDeviated
                      ? 'CROSS-TRACK ERROR: +${deviation.deviationMeters.toStringAsFixed(1)}m (>50m tolerance)'
                      : 'WITHIN CORRIDOR: ${deviation.deviationMeters.toStringAsFixed(1)}m (≤50m tolerance)',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Google Maps Attribution & Watermark ──────────────────────────
        Positioned(
          left: 14,
          bottom: 150,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_rounded, size: 14, color: Color(0xFF4285F4)),
                const SizedBox(width: 4),
                Text(
                  'Google Maps • $_layerTitle',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Floating Controls & Navigation Launch Button ─────────────────
        if (widget.showControls) _buildMapOverlayControls(vehiclePos, deviation),
      ],
    );
  }

  Widget _buildMapOverlayControls(LatLng vehiclePos, CrossTrackDeviationResult deviation) {
    return Positioned(
      right: 16,
      top: 170, // Below top destination card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. One-Tap Google Maps Turn-by-Turn Navigation Launch Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLaunchingNav ? null : _handleStartTurnByTurn,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E), // Customs Emerald Accent
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLaunchingNav)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Start Google Navigation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. Cycle Google Map Layers (Road, Satellite, Hybrid, Terrain)
          FloatingActionButton.small(
            heroTag: 'cycle_google_layer',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0E3352),
            tooltip: 'Layer: $_layerTitle',
            onPressed: _cycleMapLayer,
            child: Icon(
              _layerType == GoogleMapLayerType.standard
                  ? Icons.satellite_alt_rounded
                  : _layerType == GoogleMapLayerType.hybrid
                      ? Icons.terrain_rounded
                      : Icons.map_rounded,
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // 3. Toggle Device GPS (geolocator) vs Simulation
          FloatingActionButton.small(
            heroTag: 'toggle_device_gps',
            backgroundColor: _useLiveDeviceGps ? const Color(0xFF0F766E) : Colors.white,
            foregroundColor: _useLiveDeviceGps ? Colors.white : const Color(0xFF0E3352),
            tooltip: _useLiveDeviceGps ? 'Using Real Device GPS' : 'Enable Real Device GPS',
            onPressed: _toggleLiveGpsTracking,
            child: Icon(
              _useLiveDeviceGps ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // 4. Recenter on Vehicle GPS
          FloatingActionButton.small(
            heroTag: 'recenter_vehicle_gps',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1D4ED8),
            tooltip: 'Recenter Vehicle GPS',
            onPressed: _recenterOnVehicle,
            child: const Icon(Icons.my_location_rounded, size: 20),
          ),

          const SizedBox(height: 8),

          // 5. Fit Full Route Bounds
          FloatingActionButton.small(
            heroTag: 'fit_full_route',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF334155),
            tooltip: 'Fit Full Route Bounds',
            onPressed: _fitRouteBounds,
            child: const Icon(Icons.zoom_out_map_rounded, size: 20),
          ),

          const SizedBox(height: 10),

          // Live GPS & Cross-Track Distance Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${vehiclePos.latitude.toStringAsFixed(4)}° N, ${vehiclePos.longitude.toStringAsFixed(4)}° E',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Δxt: ${deviation.deviationMeters.toStringAsFixed(1)}m',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: deviation.isDeviated ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
