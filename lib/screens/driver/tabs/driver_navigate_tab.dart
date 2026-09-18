import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import '../../../widgets/corridor_map_widget.dart';

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
  bool _isDeviated = false;

  void _handleToggleDeviation() {
    setState(() {
      _isDeviated = !_isDeviated;
    });
    if (widget.onSimulateDeviation != null) {
      widget.onSimulateDeviation!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Fullscreen Interactive Corridor Map ──────────────────────────
        Positioned.fill(
          child: CorridorMapWidget(
            corridorTitle: 'Customs Corridor Alpha (Peliyagoda Bypass)',
            originTitle: 'Katunayake',
            destinationTitle: 'Port of Colombo',
            progress: 0.60,
            isDeviated: _isDeviated,
            deviationMeters: _isDeviated ? 72.0 : 0.0,
            speedKmH: 42,
            height: double.infinity,
            showSrsCallouts: true,
            showTopStatusOverlay: false,
            onToggleDeviation: _handleToggleDeviation,
          ),
        ),

        // ── Figure 11: Top Floating Destination & ETA Card ───────────────
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Port of Colombo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ETA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.activeTrip != null ? '2h 30m' : '2h 30m',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress Bar with 142 km
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0.60,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '142 km',
                      style: TextStyle(
                        fontSize: 12,
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

        // ── Figure 11: Bottom Floating Turn Card & Action Button ─────────
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Next Turn Card
              Container(
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
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Turn',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'In 2.3 km',
                              style: TextStyle(
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
                    const Text(
                      'Turn right onto A1 Highway',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Figure 11: Simulate Deviation Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleToggleDeviation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDeviated
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF0E3352), // Dark Navy
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    _isDeviated ? 'Restore Approved Route' : 'Simulate Deviation',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
