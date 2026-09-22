import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../services/google_maps_navigation_service.dart';
import '../utils/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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

  @override
  Widget build(BuildContext context) {
    final navService = GoogleMapsNavigationService.instance;
    final rIndex = _routeIndex;
    final routeCoords = navService
        .getCoordinatesForRoute(rIndex)
        .map((c) => ll.LatLng(c.latitude, c.longitude))
        .toList();
    final originPos = const ll.LatLng(6.9442, 79.8453);
    final dest = navService.getDestinationCoords(rIndex);
    final destPos = ll.LatLng(dest.latitude, dest.longitude);
    final vPos = navService.getVehiclePosition(
      rIndex,
      widget.progress,
      isDeviated: widget.isDeviated,
    );
    final vehiclePos = ll.LatLng(vPos.latitude, vPos.longitude);
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDeviated ? AppTheme.tamperRed : AppTheme.slate200,
          width: widget.isDeviated ? 2 : 1,
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
          // Real Google Map
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: vehiclePos,
                initialZoom: 13.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                if (!isTest)
                  TileLayer(
                    urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    userAgentPackageName: 'com.example.securetrack_mobile',
                    maxZoom: 19,
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                  )
                else
                  Container(color: const Color(0xFFE2E8F0)),

                // Geofence buffer corridor
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeCoords,
                      strokeWidth: 14.0,
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      strokeCap: StrokeCap.round,
                    ),
                    Polyline(
                      points: routeCoords,
                      strokeWidth: 4.5,
                      color: const Color(0xFF1D4ED8),
                      strokeCap: StrokeCap.round,
                    ),
                    if (widget.isDeviated)
                      Polyline(
                        points: [
                          routeCoords.length > 2 ? routeCoords[2] : originPos,
                          vehiclePos,
                        ],
                        strokeWidth: 4.0,
                        color: const Color(0xFFDC2626),
                        pattern: StrokePattern.dashed(segments: const [6, 4]),
                      ),
                  ],
                ),

                // Markers
                MarkerLayer(
                  markers: [
                    Marker(
                      point: originPos,
                      width: 34,
                      height: 34,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.anchor_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                    Marker(
                      point: destPos,
                      width: 34,
                      height: 34,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.warehouse_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                    Marker(
                      point: vehiclePos,
                      width: 44,
                      height: 44,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.isDeviated ? const Color(0xFFDC2626) : const Color(0xFF0E3352),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: (widget.isDeviated ? const Color(0xFFDC2626) : const Color(0xFF0E3352))
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isDeviated ? Icons.warning_rounded : Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                  color: widget.isDeviated
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
                      widget.isDeviated
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
                            widget.isDeviated
                                ? '🚨 CORRIDOR DEVIATION ALERT (+${widget.deviationMeters.toStringAsFixed(0)}m)'
                                : '🟢 WITHIN CUSTOMS APPROVED CORRIDOR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            widget.corridorTitle,
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
