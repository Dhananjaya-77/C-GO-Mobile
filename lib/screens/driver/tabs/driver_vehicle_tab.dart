import 'package:flutter/material.dart';
import '../../../models/container_model.dart';
import '../../../models/vehicle_model.dart';
import '../../../utils/app_theme.dart';

class DriverVehicleTab extends StatefulWidget {
  final VehicleInfo vehicle;
  final ContainerInfo? container;
  final VoidCallback? onRunInspection;
  final VoidCallback? onVerifyLock;

  const DriverVehicleTab({
    super.key,
    required this.vehicle,
    this.container,
    this.onRunInspection,
    this.onVerifyLock,
  });

  @override
  State<DriverVehicleTab> createState() => _DriverVehicleTabState();
}

class _DriverVehicleTabState extends State<DriverVehicleTab> {
  bool _isPinging = false;
  DateTime _lastPingTime = DateTime.now().subtract(const Duration(seconds: 12));

  void _handlePingLock() async {
    setState(() {
      _isPinging = true;
    });

    await Future.delayed(const Duration(milliseconds: 750));

    if (!mounted) return;

    setState(() {
      _isPinging = false;
      _lastPingTime = DateTime.now();
    });

    if (widget.onVerifyLock != null) {
      widget.onVerifyLock!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'IoT Smart Lock ${widget.vehicle.assignedLockId} telemetry refreshed (Heartbeat ACK received)',
          ),
          backgroundColor: AppTheme.securityGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = widget.container ?? ContainerInfo.mockPrimaryContainer;
    final telemetry = container.telemetry;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Assigned Truck Card (ONLY Truck Model and Registration Number)
          _buildTruckCard(context),
          const SizedBox(height: 16),

          // Section 2: Assigned IoT Lock Status Banner
          _buildLockStatusBanner(context, container),
          const SizedBox(height: 20),

          // Section 3: Assigned IoT Lock Details & Hardware Specs
          _buildLockHardwareSection(context, container),
          const SizedBox(height: 20),

          // Section 4: Live IoT Lock Telemetry & Security Sensors
          _buildLockTelemetrySection(context, telemetry),
          const SizedBox(height: 20),

          // Section 5: Customs Clearance & Verification Action
          _buildLockVerificationSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Truck Card: Retains ONLY Truck Model and Truck Registration Number
  Widget _buildTruckCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.customsBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppTheme.customsBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRUCK REGISTRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.securityGreenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ASSIGNED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.securityGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  widget.vehicle.plateNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 15,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.vehicle.modelName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Assigned IoT Lock Status Banner
  Widget _buildLockStatusBanner(BuildContext context, ContainerInfo container) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.securityGreenLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.securityGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.securityGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'IoT Smart Lock Armed',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.securityGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SECURE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Lock ID: ${container.rfidLockId} • E-Seal Latched',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.slate700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Assigned IoT Lock Hardware and Pairing Information
  Widget _buildLockHardwareSection(BuildContext context, ContainerInfo container) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned IoT Lock Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLockDetailRow(
                icon: Icons.lock_outline_rounded,
                iconColor: AppTheme.customsBlue,
                label: 'RFID Smart Lock Serial',
                value: container.rfidLockId,
                badge: 'Active E-Lock',
              ),
              const Divider(height: 20),
              _buildLockDetailRow(
                icon: Icons.memory,
                iconColor: Colors.deepPurple,
                label: 'IoT Telemetry Unit ID',
                value: container.iotDeviceId,
                badge: 'Master Controller',
              ),
              const Divider(height: 20),
              _buildLockDetailRow(
                icon: Icons.inventory_2_outlined,
                iconColor: Colors.teal,
                label: 'Paired Container',
                value: container.containerNumber,
                badge: container.containerType,
              ),
              const Divider(height: 20),
              _buildLockDetailRow(
                icon: Icons.pin_outlined,
                iconColor: AppTheme.customsGold,
                label: 'Customs Bolt Seal No.',
                value: container.physicalSealNumber,
                badge: 'SL Customs Verified',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String badge,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// Live Telemetry & Security Sensors of the Assigned Smart Lock
  Widget _buildLockTelemetrySection(BuildContext context, SensorTelemetry telemetry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lock Telemetry & Sensors',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
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
                  'Live Transmitting',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSensorRow(
                icon: Icons.shield_outlined,
                title: 'Lock Shackle / Door Bar',
                statusText: telemetry.isMagneticReedClosed ? 'Armed & Closed' : 'Door Open',
                detailText: 'Magnetic Reed Sensor Engaged',
                color: telemetry.isMagneticReedClosed ? AppTheme.securityGreen : AppTheme.tamperRed,
                isOk: telemetry.isMagneticReedClosed,
              ),
              const Divider(height: 20),
              _buildSensorRow(
                icon: Icons.security_rounded,
                title: 'Customs Bolt Seal Integrity',
                statusText: 'CUS-SL-778219 • Intact',
                detailText: 'Physical barrier seal verified intact & clamped',
                color: AppTheme.securityGreen,
                isOk: true,
              ),
              const Divider(height: 20),
              _buildSensorRow(
                icon: Icons.battery_charging_full,
                title: 'IoT Lock Battery',
                statusText: '${telemetry.batteryLevel}% (Li-Ion Pack)',
                detailText: 'Estimated ~48 hours battery life remaining',
                color: telemetry.batteryLevel > 20 ? AppTheme.securityGreen : AppTheme.warningAmber,
                isOk: telemetry.batteryLevel > 20,
              ),
              const Divider(height: 20),
              _buildSensorRow(
                icon: Icons.gps_fixed,
                title: 'GPS Geofence Lock',
                statusText: telemetry.hasGpsLock ? 'GPS Locked (${telemetry.satelliteCount} Sats)' : 'Searching...',
                detailText: 'Corridor coordinate tracking active',
                color: telemetry.hasGpsLock ? AppTheme.customsBlue : AppTheme.warningAmber,
                isOk: telemetry.hasGpsLock,
              ),
              const Divider(height: 20),
              _buildSensorRow(
                icon: Icons.cell_tower,
                title: 'Cellular & MQTT Stream',
                statusText: telemetry.isMqttConnected ? '4G LTE Online' : 'Offline Cache',
                detailText: 'SSL/TLS encrypted link to SL Customs Command',
                color: telemetry.isMqttConnected ? AppTheme.customsBlue : AppTheme.warningAmber,
                isOk: telemetry.isMqttConnected,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSensorRow({
    required IconData icon,
    required String title,
    required String statusText,
    required String detailText,
    required Color color,
    required bool isOk,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                detailText,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Lock Verification and Audit Information Card
  Widget _buildLockVerificationSection(BuildContext context) {
    final secondsAgo = DateTime.now().difference(_lastPingTime).inSeconds;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppTheme.securityGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Customs Lock Clearance',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Pinged ${secondsAgo < 5 ? 'Just now' : '${secondsAgo}s ago'}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart Lock SL-RFID-99214 armed at Colombo Port SAGT Gate 4. Electronic release authorized exclusively at destination ICD.',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isPinging ? null : _handlePingLock,
              icon: _isPinging
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                _isPinging ? 'Pinging Lock Telemetry...' : 'Verify Smart Lock Status',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.customsBlue,
                side: const BorderSide(color: AppTheme.customsBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
