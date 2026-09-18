import 'package:flutter/material.dart';
import '../../models/container_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/corridor_map_widget.dart';

/// Detail screen showing a single container's live location on the corridor map
/// along with GPS coordinates, speed, and sensor status.
class ContainerLocationScreen extends StatelessWidget {
  final ContainerInfo container;

  const ContainerLocationScreen({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    final telemetry = container.telemetry;
    final isSecure =
        container.securityStatus == ContainerSecurityStatus.secure;

    return Scaffold(
      appBar: AppBar(
        title: Text(container.containerNumber),
        backgroundColor: AppTheme.customsBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Live Corridor Map ──
          CorridorMapWidget(
            corridorTitle: container.designatedCorridor,
            originTitle: container.originPort.split(' - ').first,
            destinationTitle: container.destinationDepot.split(' ').first,
            progress: 0.62,
            isDeviated: telemetry.isDeviated,
            deviationMeters: telemetry.routeDeviationMeters,
            speedKmH: telemetry.speedKmH,
            height: 260,
          ),
          const SizedBox(height: 16),

          // ── GPS Coordinates Card ──
          _infoCard(
            icon: Icons.gps_fixed_rounded,
            title: 'GPS Coordinates',
            children: [
              _row('Latitude', telemetry.latitude.toStringAsFixed(4)),
              _row('Longitude', telemetry.longitude.toStringAsFixed(4)),
              _row('GPS Lock', telemetry.hasGpsLock ? 'Active ✅' : 'No Lock ❌'),
              _row('Satellites', '${telemetry.satelliteCount}'),
            ],
          ),
          const SizedBox(height: 12),

          // ── Speed & Route Card ──
          _infoCard(
            icon: Icons.speed_rounded,
            title: 'Speed & Route',
            children: [
              _row('Current Speed', '${telemetry.speedKmH} km/h'),
              _row('Corridor', container.designatedCorridor),
              _row(
                'Route Deviation',
                telemetry.isDeviated
                    ? '⚠️ ${telemetry.routeDeviationMeters.toStringAsFixed(1)} m OFF corridor'
                    : '${telemetry.routeDeviationMeters.toStringAsFixed(1)} m (within limits)',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Security & Connectivity Card ──
          _infoCard(
            icon: Icons.security_rounded,
            title: 'Security & Connectivity',
            children: [
              _row(
                'Security Status',
                isSecure ? 'Secure ✅' : 'BREACH ⚠️',
                valueColor: isSecure ? AppTheme.securityGreen : AppTheme.tamperRed,
              ),
              _row('RFID Lock', container.rfidLockId),
              _row('IoT Device', container.iotDeviceId),
              _row('GSM Signal', '${'▉' * telemetry.gsmSignalBars}${'░' * (5 - telemetry.gsmSignalBars)} (${telemetry.gsmSignalBars}/5)'),
              _row('MQTT', telemetry.isMqttConnected ? 'Connected' : 'Disconnected'),
              _row('Battery', '${telemetry.batteryLevel}%'),
            ],
          ),
          const SizedBox(height: 12),

          // ── Origin / Destination Card ──
          _infoCard(
            icon: Icons.route_rounded,
            title: 'Transit Route',
            children: [
              _row('Origin', container.originPort),
              _row('Destination', container.destinationDepot),
              _row('Cargo', container.cargoDescription),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Helper: Info Card ──
  Widget _infoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.customsBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate800,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  // ── Helper: Row inside a card ──
  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
