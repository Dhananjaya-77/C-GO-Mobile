import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/trip_model.dart';
import '../services/google_maps_navigation_service.dart';

enum GoogleMapLayerType {
  standard,
  satellite,
  hybrid,
  terrain,
}

/// Real, interactive Google Map Widget for Sri Lanka Customs transit corridors.
/// Renders authentic Google Maps tiles, approved transit corridor polylines,
/// real-time GPS vehicle position, geofence radius, and turn-by-turn navigation.
class ExactGoogleMapWidget extends StatefulWidget {
  final int routeIndex;
  final ApprovedRoute route;
  final double progress; // 0.0 to 1.0
  final bool isDeviated;
  final double deviationMeters;
  final int speedKmH;
  final VoidCallback? onToggleDeviation;
  final bool showControls;

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
  });

  @override
  State<ExactGoogleMapWidget> createState() => _ExactGoogleMapWidgetState();
}

class _ExactGoogleMapWidgetState extends State<ExactGoogleMapWidget> {
  MapController? _mapController;

  MapController get _controller => _mapController ??= MapController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  GoogleMapLayerType _layerType = GoogleMapLayerType.standard;
  bool _isLaunchingNav = false;

  /// Check if running in headless flutter_test environment
  bool get _isInTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  /// Get Google Maps tile URL template based on active layer
  String get _tileUrlTemplate {
    switch (_layerType) {
      case GoogleMapLayerType.satellite:
        return 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
      case GoogleMapLayerType.hybrid:
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
      case GoogleMapLayerType.terrain:
        return 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
      case GoogleMapLayerType.standard:
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
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
    final navService = GoogleMapsNavigationService.instance;
    final pos = navService.getVehiclePosition(
      widget.routeIndex,
      widget.progress,
      isDeviated: widget.isDeviated,
    );
    _controller.move(ll.LatLng(pos.latitude, pos.longitude), 14.5);
  }

  void _fitRouteBounds() {
    final navService = GoogleMapsNavigationService.instance;
    final coords = navService.getCoordinatesForRoute(widget.routeIndex);
    if (coords.isEmpty) return;

    final center = navService.getVehiclePosition(widget.routeIndex, 0.5);
    _controller.move(ll.LatLng(center.latitude, center.longitude), 13.2);
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

  List<ll.LatLng> _getRoutePoints() {
    final navService = GoogleMapsNavigationService.instance;
    final coords = navService.getCoordinatesForRoute(widget.routeIndex);
    return coords.map((c) => ll.LatLng(c.latitude, c.longitude)).toList();
  }

  ll.LatLng _getVehicleLatLng() {
    final navService = GoogleMapsNavigationService.instance;
    final pos = navService.getVehiclePosition(
      widget.routeIndex,
      widget.progress,
      isDeviated: widget.isDeviated,
    );
    return ll.LatLng(pos.latitude, pos.longitude);
  }

  ll.LatLng _getOriginLatLng() {
    return const ll.LatLng(6.9442, 79.8453);
  }

  ll.LatLng _getDestinationLatLng() {
    final navService = GoogleMapsNavigationService.instance;
    final dest = navService.getDestinationCoords(widget.routeIndex);
    return ll.LatLng(dest.latitude, dest.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final vehiclePos = _getVehicleLatLng();
    final originPos = _getOriginLatLng();
    final destPos = _getDestinationLatLng();
    final routePoints = _getRoutePoints();

    return Stack(
      children: [
        // ── Real Interactive Google Map ──────────────────────────────────
        Positioned.fill(
          child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: vehiclePos,
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // 1. Google Maps Real Raster Tile Layer
              if (!_isInTestEnvironment)
                TileLayer(
                  urlTemplate: _tileUrlTemplate,
                  userAgentPackageName: 'com.example.securetrack_mobile',
                  maxZoom: 19,
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                )
              else
                // Clean background for widget tests
                Container(color: const Color(0xFFE2E8F0)),

              // 2. Geofence Arrival Radius Circles
              CircleLayer(
                circles: [
                  // Origin Port Gate Radius (120m)
                  CircleMarker(
                    point: originPos,
                    radius: 40,
                    color: const Color(0xFF10B981).withValues(alpha: 0.20),
                    borderColor: const Color(0xFF10B981),
                    borderStrokeWidth: 2,
                  ),
                  // Destination Terminal Radius (150m)
                  CircleMarker(
                    point: destPos,
                    radius: 48,
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.20),
                    borderColor: const Color(0xFF1D4ED8),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

              // 3. Approved Transit Corridor Polylines
              PolylineLayer(
                polylines: [
                  // Translucent Geofence Buffer Corridor (Width 16)
                  Polyline(
                    points: routePoints,
                    strokeWidth: 16.0,
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                  // Solid Approved Route Line (Customs Blue, Width 5)
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5.0,
                    color: const Color(0xFF1D4ED8),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                  // Deviated route segment (Tamper Red)
                  if (widget.isDeviated)
                    Polyline(
                      points: [
                        routePoints.length > 3 ? routePoints[3] : originPos,
                        vehiclePos,
                      ],
                      strokeWidth: 4.5,
                      color: const Color(0xFFDC2626),
                      pattern: StrokePattern.dashed(segments: const [6, 4]),
                    ),
                ],
              ),

              // 4. Exact Map Markers
              MarkerLayer(
                markers: [
                  // Origin Gate Marker
                  Marker(
                    point: originPos,
                    width: 44,
                    height: 44,
                    child: _buildLocationPin(
                      color: const Color(0xFF10B981),
                      icon: Icons.anchor_rounded,
                      label: 'Port Gate',
                    ),
                  ),

                  // Destination Terminal Marker
                  Marker(
                    point: destPos,
                    width: 44,
                    height: 44,
                    child: _buildLocationPin(
                      color: const Color(0xFFDC2626),
                      icon: Icons.warehouse_rounded,
                      label: widget.route.destination,
                    ),
                  ),

                  // Real-time Vehicle GPS Marker
                  Marker(
                    point: vehiclePos,
                    width: 52,
                    height: 52,
                    child: _buildVehicleMarker(),
                  ),
                ],
              ),
            ],
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
        if (widget.showControls) _buildMapOverlayControls(vehiclePos),
      ],
    );
  }

  Widget _buildLocationPin({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildVehicleMarker() {
    final isDev = widget.isDeviated;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDev ? const Color(0xFFDC2626) : const Color(0xFF0E3352),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: (isDev ? const Color(0xFFDC2626) : const Color(0xFF0E3352))
                    .withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isDev ? Icons.warning_rounded : Icons.local_shipping_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildMapOverlayControls(ll.LatLng vehiclePos) {
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

          // 3. Recenter on Vehicle GPS
          FloatingActionButton.small(
            heroTag: 'recenter_vehicle_gps',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1D4ED8),
            tooltip: 'Recenter Vehicle GPS',
            onPressed: _recenterOnVehicle,
            child: const Icon(Icons.my_location_rounded, size: 20),
          ),

          const SizedBox(height: 8),

          // 4. Fit Full Route Bounds
          FloatingActionButton.small(
            heroTag: 'fit_full_route',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF334155),
            tooltip: 'Fit Full Route Bounds',
            onPressed: _fitRouteBounds,
            child: const Icon(Icons.zoom_out_map_rounded, size: 20),
          ),

          const SizedBox(height: 10),

          // Live GPS Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${vehiclePos.latitude.toStringAsFixed(4)}° N, ${vehiclePos.longitude.toStringAsFixed(4)}° E',
              style: const TextStyle(
                fontSize: 10.5,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
