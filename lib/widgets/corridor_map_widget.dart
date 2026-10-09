// Source: Google Maps Platform Code Assist
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_maps_navigation_service.dart';
import '../utils/app_theme.dart';
import '../utils/cross_track_calculator.dart';

/// Interactive Google Map Widget displaying approved customs corridor,
/// live vehicle GPS location, arrival geofence radiuses, and cross-track deviation alerts.
class CorridorMapWidget extends StatefulWidget {
  final String corridorTitle;
  final String originTitle;
  final String destinationTitle;
  final double progress; // 0.0 to 1.0
  final bool isDeviated;
  final double deviationMeters;
  final int speedKmH;
  final VoidCallback? onToggleDeviation;
  final double height;
  final bool showSrsCallouts;
  final bool showTopStatusOverlay;

  const CorridorMapWidget({
    super.key,
    required this.corridorTitle,
    required this.originTitle,
    required this.destinationTitle,
    required this.progress,
    this.isDeviated = false,
    this.deviationMeters = 0.0,
    this.speedKmH = 42,
    this.onToggleDeviation,
    this.height = 240,
    this.showSrsCallouts = true,
    this.showTopStatusOverlay = true,
  });

  @override
  State<CorridorMapWidget> createState() => _CorridorMapWidgetState();
}

class _CorridorMapWidgetState extends State<CorridorMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CorridorMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.isDeviated != widget.isDeviated ||
        oldWidget.destinationTitle != widget.destinationTitle) {
      _recenterOnVehicle();
    }
  }

  void _recenterOnVehicle() {
    final navService = GoogleMapsNavigationService.instance;
    final vPos = navService.getVehiclePosition(
      _routeIndex,
      widget.progress,
      isDeviated: widget.isDeviated,
    );
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: vPos, zoom: 13.5),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _routeIndex {
    final dest = widget.destinationTitle.toLowerCase();
    if (dest.contains('grayline 1')) return 1;
    if (dest.contains('grayline 2')) return 2;
    return 0;
  }

  Set<Marker> _buildMarkers(
    LatLng vehiclePos,
    LatLng originPos,
    LatLng destPos,
    CrossTrackDeviationResult deviation,
  ) {
    final isDev = widget.isDeviated || deviation.isDeviated;
    return {
      Marker(
        markerId: const MarkerId('corridor_origin'),
        position: originPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.originTitle,
          snippet: 'Authorized Port Origin',
        ),
      ),
      Marker(
        markerId: const MarkerId('corridor_destination'),
        position: destPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.destinationTitle,
          snippet: 'Customs Verification Yard',
        ),
      ),
      Marker(
        markerId: const MarkerId('corridor_vehicle'),
        position: vehiclePos,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isDev ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
        ),
        infoWindow: InfoWindow(
          title: 'Transport Vehicle',
          snippet:
              '${widget.speedKmH} km/h • Cross-track: ${deviation.deviationMeters.toStringAsFixed(1)}m ${isDev ? "[DEVIATED]" : "[IN CORRIDOR]"}',
        ),
      ),
    };
  }

  Set<Polyline> _buildPolylines(
    List<LatLng> routeCoords,
    LatLng vehiclePos,
    LatLng originPos,
    CrossTrackDeviationResult deviation,
  ) {
    final polylines = <Polyline>{
      // Geofence buffer corridor (50m buffer representation)
      Polyline(
        polylineId: const PolylineId('corridor_buffer'),
        points: routeCoords,
        width: 14,
        color: const Color(0xFF0284C7).withValues(alpha: 0.28),
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
      // Approved Route
      Polyline(
        polylineId: const PolylineId('corridor_route'),
        points: routeCoords,
        width: 4,
        color: const Color(0xFF1D4ED8),
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    if (widget.isDeviated || deviation.isDeviated) {
      final anchorPoint = deviation.nearestCorridorPoint;
      polylines.add(
        Polyline(
          polylineId: const PolylineId('corridor_deviation'),
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
        circleId: const CircleId('origin_geofence'),
        center: originPos,
        radius: 120,
        fillColor: const Color(0xFF10B981).withValues(alpha: 0.20),
        strokeColor: const Color(0xFF10B981),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('dest_geofence'),
        center: destPos,
        radius: 150,
        fillColor: const Color(0xFF1D4ED8).withValues(alpha: 0.20),
        strokeColor: const Color(0xFF1D4ED8),
        strokeWidth: 2,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final navService = GoogleMapsNavigationService.instance;
    final rIndex = _routeIndex;
    final routeCoords = navService.getCoordinatesForRoute(rIndex);
    final originPos = GoogleMapsNavigationService.colomboPortOrigin;
    final dest = navService.getDestinationCoords(rIndex);
    final vPos = navService.getVehiclePosition(
      rIndex,
      widget.progress,
      isDeviated: widget.isDeviated,
    );

    // Compute exact cross-track distance using CrossTrackCalculator
    final deviation = CrossTrackCalculator.measureDeviation(
      position: vPos,
      corridor: routeCoords,
      toleranceMeters: CrossTrackCalculator.defaultToleranceMeters,
    );

    final isDeviated = widget.isDeviated || deviation.isDeviated;
    final effectiveDeviationMeters = widget.deviationMeters > 0
        ? widget.deviationMeters
        : deviation.deviationMeters;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDeviated ? AppTheme.tamperRed : AppTheme.slate200,
          width: isDeviated ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Real Official Google Map ────────────────────────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: vPos,
                zoom: 13.5,
              ),
              mapType: MapType.normal,
              markers: _buildMarkers(vPos, originPos, dest, deviation),
              polylines: _buildPolylines(routeCoords, vPos, originPos, deviation),
              circles: _buildCircles(originPos, dest),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              gestureRecognizers: {
                Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                if (!_controllerCompleter.isCompleted) {
                  _controllerCompleter.complete(controller);
                }
              },
            ),
          ),

          // Google Maps Watermark badge
          Positioned(
            left: 10,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded, size: 12, color: Color(0xFF4285F4)),
                  SizedBox(width: 4),
                  Text(
                    'Google Maps',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Optional Top Status Overlay (Geofence Corridor compliance)
          if (widget.showTopStatusOverlay)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDeviated
                      ? AppTheme.tamperRed
                      : AppTheme.navyPrimary.withValues(alpha: 0.92),
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
                  children: [
                    Icon(
                      isDeviated
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isDeviated
                                ? '🚨 CORRIDOR DEVIATION ALERT (+${effectiveDeviationMeters.toStringAsFixed(0)}m)'
                                : '🟢 WITHIN CUSTOMS APPROVED CORRIDOR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '${widget.corridorTitle} • Cross-Track: ${effectiveDeviationMeters.toStringAsFixed(1)}m (Tolerance: 50m)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.onToggleDeviation != null)
                      InkWell(
                        onTap: widget.onToggleDeviation,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.isDeviated ? 'Restore Route' : 'Simulate Deviation',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Origin & Destination Labels (SRS styled)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.originTitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.securityGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.destinationTitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Speed Overlay Chip
          if (widget.showTopStatusOverlay)
            Positioned(
              right: 12,
              top: 54,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speed_rounded, size: 14, color: AppTheme.customsBlue),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.speedKmH} km/h',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
