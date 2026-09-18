import 'package:flutter/material.dart';
import '../../../models/container_model.dart';
import '../../../models/trip_model.dart';
import '../../../models/vehicle_model.dart';
import '../../../utils/app_theme.dart';

class DriverTripTab extends StatelessWidget {
  final TripInfo? activeTrip;
  final VehicleInfo vehicle;
  final ContainerInfo container;

  const DriverTripTab({
    super.key,
    this.activeTrip,
    required this.vehicle,
    required this.container,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Figure 13: Container Information Card ─────────────────────
          _buildContainerInfoCard(context),

          const SizedBox(height: 16),

          // ─── Figure 13: Route Information Card ─────────────────────────
          _buildRouteInfoCard(context),

          const SizedBox(height: 16),

          // ─── Figure 13: Trip Progress Card ─────────────────────────────
          _buildTripProgressCard(context),
        ],
      ),
    );
  }

  // ── Figure 13: Container Information Card ──────────────────────────────
  Widget _buildContainerInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Container Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Light green
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 Grid from Figure 13
          Row(
            children: [
              Expanded(
                child: _buildGridInfoItem(
                  'Container ID',
                  activeTrip?.containerId ?? 'CTR-2024-8473',
                  const Color(0xFF0F172A),
                ),
              ),
              Expanded(
                child: _buildGridInfoItem(
                  'Seal Status',
                  'Closed',
                  const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGridInfoItem(
                  'Weight',
                  '18,500 kg',
                  const Color(0xFF0F172A),
                ),
              ),
              Expanded(
                child: _buildGridInfoItem(
                  'Type',
                  '40ft HC',
                  const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Truck & Smart Lock Integration
          Row(
            children: [
              Expanded(
                child: _buildGridInfoItem(
                  'Truck Model & Reg',
                  '${vehicle.modelName} • ${vehicle.plateNumber}',
                  const Color(0xFF475569),
                ),
              ),
              Expanded(
                child: _buildGridInfoItem(
                  'Assigned Smart Lock',
                  vehicle.assignedLockId,
                  AppTheme.customsBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridInfoItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Figure 13: Route Information Card ──────────────────────────────────
  Widget _buildRouteInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          // Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline vertical dots and line
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3352),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF94A3B8), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 48,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Location',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Katunayake Export Processing Zone',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Started: Today at 6:00 AM',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Port of Colombo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Expected: Today at 11:30 AM',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Figure 13: Trip Progress Card ──────────────────────────────────────
  Widget _buildTripProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),
          // 3 Circles from Figure 13
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressCircle(
                icon: Icons.navigation_rounded,
                bgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                label: 'Distance',
                value: '142 km left',
              ),
              _buildProgressCircle(
                icon: Icons.access_time_rounded,
                bgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'ETA',
                value: '2h 30m',
              ),
              _buildProgressCircle(
                icon: Icons.inventory_2_outlined,
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                label: 'Status',
                value: 'On Track',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Completed: 60%
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '60%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.60,
              minHeight: 8,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
