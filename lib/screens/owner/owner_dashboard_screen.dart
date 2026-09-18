import 'package:flutter/material.dart';
import '../../models/container_model.dart';
import '../../models/shipment_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/corridor_map_widget.dart';
import '../../widgets/sensor_telemetry_card.dart';
import '../login_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentTabIndex = 0;
  int _selectedContainerIndex = 0;

  final List<ContainerInfo> _ownerContainers = [
    ContainerInfo.mockPrimaryContainer,
    ContainerInfo.mockContainerFleet[1],
  ];

  late ShipmentInfo _activeShipment;
  bool _isDeviated = false;

  final List<Map<String, String>> _ownerNotifications = [
    {
      'title': 'Corridor Geofence Checkpoint Cleared',
      'body': 'Your container MSCU-742910-8 passed Ingurukade Flyover checkpoint. ETA updated: 18 mins.',
      'time': '09:05 AM',
      'type': 'corridor',
    },
    {
      'title': 'Port Departure & Escort Armed',
      'body': 'Container sealed with RFID SL-RFID-99214 and departed Colombo Port Gate 4 under Customs tracking.',
      'time': '08:45 AM',
      'type': 'departure',
    },
    {
      'title': 'Shipment Initialization Confirmed',
      'body': 'CusDec CD-2026-COL-0842 linked with IoT Tracker ST-ESP32-094 by Customs Inspection Unit.',
      'time': '08:30 AM',
      'type': 'init',
    },
  ];

  @override
  void initState() {
    super.initState();
    _activeShipment = ShipmentInfo.mockActiveShipment;
  }

  void _toggleTamperSimulation() {
    setState(() {
      final current = _ownerContainers[_selectedContainerIndex];
      final isCurrentlyTampered = current.telemetry.isTampered;

      final updatedTelemetry = current.telemetry.copyWith(
        isMagneticReedClosed: isCurrentlyTampered,
        lightSensorLux: isCurrentlyTampered ? 0.0 : 380.0,
      );

      _ownerContainers[_selectedContainerIndex] = current.copyWith(
        securityStatus: isCurrentlyTampered
            ? ContainerSecurityStatus.secure
            : ContainerSecurityStatus.tamperBreach,
        telemetry: updatedTelemetry,
      );

      if (!isCurrentlyTampered) {
        _ownerNotifications.insert(0, {
          'title': '🚨 HIGH-PRIORITY TAMPER WARNING',
          'body': 'Door breach detected on MSCU-742910-8! Customs Operations Command notified.',
          'time': 'Just now',
          'type': 'alert',
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentContainer = _ownerContainers[_selectedContainerIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.corporate_fare_rounded,
                    size: 20, color: AppTheme.customsGoldLight),
                SizedBox(width: 8),
                Text(
                  'Cargo Owner Portal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              'Lanka Global Logistics & Exports • ID: CGO-OWN-2026-99',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildTrackingTab(currentContainer),
          _buildSecurityTab(currentContainer),
          _buildMilestonesTab(),
          _buildNotificationsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() => _currentTabIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Consignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security_rounded),
            label: 'Anti-Theft',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline_rounded),
            label: 'Milestones',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Arrival Alerts',
          ),
        ],
      ),
    );
  }

  // TAB 0: CONSIGNMENTS & TRACKING
  Widget _buildTrackingTab(ContainerInfo container) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Container Switcher Carousel
        _buildContainerSelector(),
        const SizedBox(height: 16),

        // Interactive GIS Corridor Map Widget
        CorridorMapWidget(
          corridorTitle: container.designatedCorridor,
          originTitle: 'Colombo Port SAGT',
          destinationTitle: 'Orugodawatta ICD',
          progress: _activeShipment.progressPercentage,
          isDeviated: _isDeviated,
          deviationMeters: _isDeviated ? 58.0 : 0.0,
          speedKmH: container.telemetry.speedKmH,
          onToggleDeviation: () {
            setState(() => _isDeviated = !_isDeviated);
          },
        ),
        const SizedBox(height: 16),

        // Live ETA & Progress Card
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transit Progress & ETA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.securityGreenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(_activeShipment.progressPercentage * 100).toStringAsFixed(0)}% Completed',
                      style: const TextStyle(
                        color: AppTheme.securityGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _activeShipment.progressPercentage,
                  backgroundColor: AppTheme.slate100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.customsBlue),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricItem('Covered Distance',
                      '${_activeShipment.coveredDistanceKm} km'),
                  _buildMetricItem('Remaining',
                      '${_activeShipment.remainingDistanceKm.toStringAsFixed(1)} km'),
                  _buildMetricItem(
                      'Estimated ETA', '${_activeShipment.etaMinutes} mins'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Consignment & Cargo Details Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customs Consignment Specification',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20),
              _buildCargoRow(
                  'Bill of Lading (BL)', _activeShipment.billOfLading),
              _buildCargoRow(
                  'Customs CusDec No', _activeShipment.cusDecNumber),
              _buildCargoRow('Cargo Commodity', container.cargoDescription),
              _buildCargoRow(
                  'Declared Consignment Value', _activeShipment.declaredValueLkr),
              _buildCargoRow('Authorized Prime Mover',
                  _activeShipment.vehiclePlate),
              _buildCargoRow('Supervising Division',
                  'Port Transit Unit Gate 4'),
              _buildCargoRow('Customs Escort Status',
                  'Active Transit • Corridors Compliant'),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContainerSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_ownerContainers.length, (index) {
          final c = _ownerContainers[index];
          final isSelected = _selectedContainerIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedContainerIndex = index),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.customsBlue : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppTheme.customsBlue : AppTheme.slate200,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.customsBlue.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 18,
                      color: isSelected ? Colors.white : AppTheme.customsBlue,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.containerNumber,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.slate800,
                          ),
                        ),
                        Text(
                          c.cargoDescription,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
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
            color: AppTheme.navyPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCargoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: ANTI-THEFT & SENSORS
  Widget _buildSecurityTab(ContainerInfo container) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SensorTelemetryCard(
          container: container,
          onTestTamperPressed: _toggleTamperSimulation,
        ),
        const SizedBox(height: 16),

        // Security Assurance Explanation Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 20, color: AppTheme.customsBlue),
                  SizedBox(width: 8),
                  Text(
                    'How SecureTrack SL Protects Your Cargo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProtectionPoint(
                'Electronic Tamper Verification',
                'Magnetic reed switches verify continuous physical closure and smart electronic RFID seals monitor for any unauthorized door access or tampering.',
              ),
              _buildProtectionPoint(
                'Instant Cloud & SMS Escalation',
                'Any breach triggers immediate MQTT alert transmission within 5 seconds to Customs HQ and dispatches automated SMS alerts to the cargo owner.',
              ),
              _buildProtectionPoint(
                'Fault-Tolerant Offline Sync',
                'If cellular signal is lost in dead zones, sensor state changes and GPS coordinates are stored in local flash memory and synced immediately upon reconnection.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionPoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle,
              size: 16, color: AppTheme.securityGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: MILESTONES
  Widget _buildMilestonesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consignment Milestones & Audit Trail',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Container: ${_ownerContainers[_selectedContainerIndex].containerNumber} • CusDec: ${_activeShipment.cusDecNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._activeShipment.milestones.map((milestone) {
          return _buildMilestoneTile(milestone);
        }),
      ],
    );
  }

  Widget _buildMilestoneTile(CheckpointMilestone milestone) {
    Color iconColor;
    if (milestone.isCompleted) {
      iconColor = AppTheme.securityGreen;
    } else if (milestone.isCurrent) {
      iconColor = AppTheme.customsBlue;
    } else {
      iconColor = Colors.grey.shade400;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
                border: Border.all(color: iconColor, width: 2),
              ),
              child: Icon(
                milestone.isCompleted
                    ? Icons.check
                    : milestone.isCurrent
                        ? Icons.my_location
                        : Icons.circle,
                size: 14,
                color: iconColor,
              ),
            ),
            Container(
              width: 2,
              height: 64,
              color: milestone.isCompleted
                  ? AppTheme.securityGreen
                  : Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: milestone.isCurrent
                    ? AppTheme.customsBlue
                    : AppTheme.slate200,
                width: milestone.isCurrent ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate800,
                        ),
                      ),
                    ),
                    Text(
                      milestone.time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: milestone.isCurrent
                            ? AppTheme.customsBlue
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  milestone.locationName,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                if (milestone.inspectorNote != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Note: ${milestone.inspectorNote}',
                    style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: NOTIFICATIONS
  Widget _buildNotificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automated Customs & Arrival Notifications',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Live notifications generated via Twilio SMS and SMTP gateways to keep cargo owners informed.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._ownerNotifications.map((notif) {
          final isAlert = notif['type'] == 'alert';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isAlert ? AppTheme.tamperRedLight : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAlert ? AppTheme.tamperRed : AppTheme.slate200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isAlert
                      ? AppTheme.tamperRed
                      : AppTheme.customsBlue.withValues(alpha: 0.1),
                  child: Icon(
                    isAlert
                        ? Icons.warning_rounded
                        : Icons.notifications_active_outlined,
                    size: 18,
                    color: isAlert ? Colors.white : AppTheme.customsBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isAlert
                                    ? AppTheme.tamperRed
                                    : AppTheme.slate800,
                              ),
                            ),
                          ),
                          Text(
                            notif['time']!,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['body']!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
