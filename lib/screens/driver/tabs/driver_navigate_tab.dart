import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import '../../../widgets/exact_google_map_widget.dart';

class DriverNavigateTab extends StatefulWidget {
  final TripInfo? activeTrip;
  final VoidCallback? onSimulateDeviation;

  const DriverNavigateTab({
    super.key,
    this.activeTrip,
    this.onSimulateDeviation,
  });

  @override
  State<DriverNavigateTab> createState() => _DriverNavigateTabState();
}

class _DriverNavigateTabState extends State<DriverNavigateTab> {
  TripInfo get _trip => widget.activeTrip ?? TripInfo.mockActiveTrip;

  /// Index of the single approved route assigned to this driver's registered transport
  int get _registeredRouteIndex {
    final rNum = _trip.routeNumber.toLowerCase();
    final dest = _trip.destination.toLowerCase();
    if (rNum.contains('2') || dest.contains('grayline 1')) return 1;
    if (rNum.contains('3') || dest.contains('grayline 2')) return 2;
    return 0; // Route 1: Orugodawaththa
  }

  ApprovedRoute get _registeredRoute {
    final idx = _registeredRouteIndex;
    if (idx >= 0 && idx < kApprovedRoutes.length) {
      return kApprovedRoutes[idx];
    }
    return kApprovedRoutes[0];
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final registeredRoute = _registeredRoute;

    return Stack(
      children: [
        // ── Fullscreen Interactive Google Map & Corridor ──────────────────
        Positioned.fill(
          child: ExactGoogleMapWidget(
            routeIndex: _registeredRouteIndex,
            route: registeredRoute,
            progress: trip.progressPercentage > 0 ? trip.progressPercentage : 0.60,
            isDeviated: false,
            deviationMeters: 0.0,
            speedKmH: trip.currentSpeedKmH > 0 ? trip.currentSpeedKmH : 42,
            showControls: true,
          ),
        ),

        // ── Top Floating Card: Driver's Registered Transport Details ──
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Registered Transport Badge & Route Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            size: 16,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REGISTERED TRANSPORT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            Text(
                              trip.id,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E3352),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        registeredRoute.routeNumber,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Transport Specs: Container & E-Lock
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 15, color: Color(0xFF475569)),
                      const SizedBox(width: 6),
                      Text(
                        trip.containerNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        trip.rfidLockId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Origin -> Destination & ETA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transit Corridor',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${trip.origin} ➔ ${trip.destination}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Est. Arrival',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${registeredRoute.defaultEtaMinutes} min',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress Bar with distance
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: trip.progressPercentage > 0 ? trip.progressPercentage : 0.60,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${trip.coveredDistanceKm.toStringAsFixed(1)} / ${trip.totalDistanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Figure 11: Bottom Floating Turn Card ─────────
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4ED8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.turn_right_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Turn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          registeredRoute.nextTurnDistance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  registeredRoute.nextTurnInstruction,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
