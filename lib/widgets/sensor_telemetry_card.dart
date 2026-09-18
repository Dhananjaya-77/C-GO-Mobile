import 'package:flutter/material.dart';
import '../models/container_model.dart';
import '../utils/app_theme.dart';

class SensorTelemetryCard extends StatelessWidget {
  final ContainerInfo container;
  final VoidCallback? onTestTamperPressed;

  const SensorTelemetryCard({
    super.key,
    required this.container,
    this.onTestTamperPressed,
  });

  @override
  Widget build(BuildContext context) {
    final telemetry = container.telemetry;
    final isTampered = telemetry.isTampered;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTampered ? AppTheme.tamperRed : AppTheme.slate200,
          width: isTampered ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isTampered
                ? AppTheme.tamperRed.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isTampered ? AppTheme.tamperRedLight : AppTheme.slate100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  isTampered ? Icons.warning_rounded : Icons.verified_user_rounded,
                  size: 20,
                  color: isTampered ? AppTheme.tamperRed : AppTheme.securityGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IoT Sensor Anti-Theft Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isTampered ? AppTheme.tamperRed : AppTheme.slate800,
                        ),
                      ),
                      Text(
                        'Unit: ${container.iotDeviceId} • Lock: ${container.rfidLockId}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTampered ? AppTheme.tamperRed : AppTheme.securityGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isTampered ? 'TAMPER BREACH' : 'ALL SEALS SECURE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dual Sensor Indicators
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Sensor 1: Magnetic Reed Switch
                    Expanded(
                      child: _buildSensorTile(
                        icon: Icons.meeting_room_outlined,
                        title: 'Magnetic Reed Switch',
                        status: telemetry.isMagneticReedClosed ? 'DOOR CLOSED' : 'DOOR OPENED',
                        subtext: telemetry.isMagneticReedClosed ? 'Circuit Continuous' : 'Circuit Severed',
                        isSafe: telemetry.isMagneticReedClosed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sensor 2: RFID Smart Lock Sensor
                    Expanded(
                      child: _buildSensorTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'RFID Smart Lock',
                        status: isTampered ? 'LOCK BREACHED' : 'ARMED & LOCKED',
                        subtext: isTampered ? 'Tamper Detected' : 'E-Seal Clamped Intact',
                        isSafe: !isTampered,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hardware Telemetry Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStatus(
                        icon: Icons.battery_charging_full_rounded,
                        label: '${telemetry.batteryLevel}%',
                        sub: 'Li-ion Reserve',
                        color: telemetry.batteryLevel > 20 ? AppTheme.securityGreen : AppTheme.tamperRed,
                      ),
                      _buildDivider(),
                      _buildMiniStatus(
                        icon: Icons.satellite_alt_rounded,
                        label: '${telemetry.satelliteCount} Sats',
                        sub: telemetry.hasGpsLock ? 'GPS 3D Fix' : 'Searching',
                        color: telemetry.hasGpsLock ? AppTheme.customsBlue : AppTheme.warningAmber,
                      ),
                      _buildDivider(),
                      _buildMiniStatus(
                        icon: Icons.cell_tower_rounded,
                        label: 'SIM800L 4G',
                        sub: telemetry.isMqttConnected ? 'MQTT 5.0 Sync' : 'Offline Cache',
                        color: telemetry.isMqttConnected ? AppTheme.securityGreen : AppTheme.warningAmber,
                      ),
                    ],
                  ),
                ),

                if (onTestTamperPressed != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onTestTamperPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isTampered ? AppTheme.securityGreen : AppTheme.tamperRed,
                      side: BorderSide(
                        color: isTampered ? AppTheme.securityGreen : AppTheme.tamperRed,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    icon: Icon(
                      isTampered ? Icons.restore_rounded : Icons.crisis_alert_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isTampered ? 'Simulate Disarm & Restore Normal' : 'Simulate Door Tamper Breach (for Screenshot)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTile({
    required IconData icon,
    required String title,
    required String status,
    required String subtext,
    required bool isSafe,
  }) {
    final color = isSafe ? AppTheme.securityGreen : AppTheme.tamperRed;
    final bg = isSafe ? AppTheme.securityGreenLight : AppTheme.tamperRedLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatus({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate800),
        ),
        Text(
          sub,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: AppTheme.slate200,
    );
  }
}
