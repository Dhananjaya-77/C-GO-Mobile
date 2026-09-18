import 'package:flutter/material.dart';
import '../../../models/container_model.dart';
import '../../../models/driver_model.dart';
import '../../../models/trip_model.dart';
import '../../../models/vehicle_model.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/corridor_map_widget.dart';
import '../../../widgets/sensor_telemetry_card.dart';

class DriverHomeTab extends StatefulWidget {
  final DriverProfile driver;
  final VehicleInfo vehicle;
  final TripInfo? activeTrip;
  final bool isOnDuty;
  final ValueChanged<bool> onDutyChanged;
  final VoidCallback onSosPressed;
  final VoidCallback onInspectionPressed;
  final VoidCallback onIncidentReportPressed;
  final VoidCallback onTripActionPressed;
  final VoidCallback onViewRoutesPressed;
  final VoidCallback onNextStopReached;
  final List<String> recentAlerts;

  const DriverHomeTab({
    super.key,
    required this.driver,
    required this.vehicle,
    required this.activeTrip,
    required this.isOnDuty,
    required this.onDutyChanged,
    required this.onSosPressed,
    required this.onInspectionPressed,
    required this.onIncidentReportPressed,
    required this.onTripActionPressed,
    required this.onViewRoutesPressed,
    required this.onNextStopReached,
    required this.recentAlerts,
  });

  @override
  State<DriverHomeTab> createState() => _DriverHomeTabState();
}

class _DriverHomeTabState extends State<DriverHomeTab> {
  bool _isDeviated = false;
  ContainerInfo _container = ContainerInfo.mockPrimaryContainer;

  void _toggleTamper() {
    setState(() {
      final isTampered = _container.telemetry.isTampered;
      _container = _container.copyWith(
        securityStatus: isTampered
            ? ContainerSecurityStatus.secure
            : ContainerSecurityStatus.tamperBreach,
        telemetry: _container.telemetry.copyWith(
          isMagneticReedClosed: isTampered,
        ),
      );
    });
  }

  void _toggleDeviation() {
    setState(() {
      _isDeviated = !_isDeviated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.activeTrip;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Figure 10: Current Trip Card ──────────────────────────────
          _buildCurrentTripCard(context, trip),

          const SizedBox(height: 16),

          // ─── Figure 10: Quick Stats Card ──────────────────────────────
          _buildQuickStatsCard(context),

          const SizedBox(height: 16),

          // ─── Figure 10: Emergency Alert Button ────────────────────────
          _buildEmergencyAlertButton(context),

          const SizedBox(height: 16),

          // ─── Truck & Assigned IoT Lock Card (Preserved from requirements) ──
          _buildTruckAndIotLockCard(context),

          const SizedBox(height: 16),

          // ─── Sensor Telemetry & Tamper Test Card ──────────────────────
          SensorTelemetryCard(
            container: _container,
            onTestTamperPressed: _toggleTamper,
          ),
        ],
      ),
    );
  }

  // ── Figure 10: Current Trip Card ──────────────────────────────────────
  Widget _buildCurrentTripCard(BuildContext context, TripInfo? trip) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Current Trip title + On Route Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Trip',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Light green pill
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'On Route',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Container ID Row (Figure 10)
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Soft light blue
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Container ID',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    trip?.containerId ?? 'CTR-2024-8473',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Embedded Route Map (Figure 10: with route line & time badges)
          GestureDetector(
            onTap: widget.onViewRoutesPressed,
            child: CorridorMapWidget(
              corridorTitle: 'Customs Corridor Alpha (Peliyagoda Bypass)',
              originTitle: 'Katunayake',
              destinationTitle: 'Port of Colombo',
              progress: 0.60,
              isDeviated: _isDeviated,
              deviationMeters: _isDeviated ? 68.0 : 0.0,
              speedKmH: 42,
              height: 180,
              showSrsCallouts: true,
              showTopStatusOverlay: false,
              onToggleDeviation: _toggleDeviation,
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Stats: Distance Left & ETA (Figure 10)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Distance Left',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip != null
                        ? '${(trip.totalDistanceKm - trip.coveredDistanceKm).toStringAsFixed(0)} km'
                        : '142 km',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 1,
                color: const Color(0xFFE2E8F0),
              ),
              Column(
                children: [
                  const Text(
                    'ETA',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip != null
                        ? '${trip.nextStopEtaMinutes * 3}m'
                        : '2h 30m',
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
        ],
      ),
    );
  }

  // ── Figure 10: Quick Stats Card ───────────────────────────────────────
  Widget _buildQuickStatsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('24', 'Total Trips', const Color(0xFF0F172A)),
              _buildStatItem('98%', 'On-Time', const Color(0xFF10B981)),
              _buildStatItem('3.2k', 'km Total', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Figure 10: Emergency Alert Button ─────────────────────────────────
  Widget _buildEmergencyAlertButton(BuildContext context) {
    return InkWell(
      onTap: widget.onSosPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8E8), // Light pink/red
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF87171), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFEF4444),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Emergency Alert',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Truck & Assigned IoT Lock Card (Preserved for tests) ───────────────
  Widget _buildTruckAndIotLockCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.customsBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline,
                    color: AppTheme.customsBlue, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Truck & Assigned IoT Lock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LOCK ARMED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRUCK MODEL',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.vehicle.modelName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRUCK REGISTRATION',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Truck Reg: ${widget.vehicle.plateNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.nfc_rounded, size: 18, color: AppTheme.customsBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assigned Smart Lock: ${widget.vehicle.assignedLockId}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
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
