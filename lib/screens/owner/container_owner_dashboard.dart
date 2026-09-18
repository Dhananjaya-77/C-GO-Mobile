import 'package:flutter/material.dart';
import '../../models/container_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/corridor_map_widget.dart';
import '../../widgets/sensor_telemetry_card.dart';
import '../../widgets/srs_curved_header.dart';
import '../login_screen.dart';

class ContainerOwnerDashboardScreen extends StatefulWidget {
  const ContainerOwnerDashboardScreen({super.key});

  @override
  State<ContainerOwnerDashboardScreen> createState() =>
      _ContainerOwnerDashboardScreenState();
}

class _ContainerOwnerDashboardScreenState
    extends State<ContainerOwnerDashboardScreen> {
  int _currentTabIndex = 0;
  final List<ContainerInfo> _containers = ContainerInfo.mockContainerFleet;
  late ContainerInfo _selectedContainer;
  bool _isDeviated = false;

  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Route Deviation',
      'body': 'Container HLCU-902184-5 deviated from the optimized route 15 minutes ago.',
      'time': '15 min ago',
      'isUnread': true,
      'type': 'warning',
    },
    {
      'title': 'Weather Update',
      'body': 'Light rain expected on your route in 1 hour.',
      'time': '1 hour ago',
      'isUnread': true,
      'type': 'info',
    },
    {
      'title': 'Checkpoint Passed',
      'body': 'Container MSCU-742910-8 successfully passed checkpoint #3 (Ingurukade Flyover).',
      'time': '2 hours ago',
      'isUnread': false,
      'type': 'success',
    },
    {
      'title': 'Traffic Alert',
      'body': 'Heavy traffic detected ahead near Peliyagoda, adding 20 min to ETA.',
      'time': '3 hours ago',
      'isUnread': false,
      'type': 'warning',
    },
    {
      'title': 'Container Sealed & Departed',
      'body': 'CMAU-821904-2 sealed with RFID SL-RFID-98103 and departed Colombo Port JCT Terminal under Customs tracking.',
      'time': '4 hours ago',
      'isUnread': false,
      'type': 'info',
    },
    {
      'title': 'Shipment Initialized',
      'body': 'CusDec CD-2026-COL-0842 linked with IoT Tracker ST-ESP32-094 on MSCU-742910-8 by Customs Inspection Unit.',
      'time': '5 hours ago',
      'isUnread': false,
      'type': 'info',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedContainer = _containers.first;
  }

  void _toggleTamper() {
    setState(() {
      final isTampered = _selectedContainer.telemetry.isTampered;
      _selectedContainer = _selectedContainer.copyWith(
        securityStatus: isTampered
            ? ContainerSecurityStatus.secure
            : ContainerSecurityStatus.tamperBreach,
        telemetry: _selectedContainer.telemetry.copyWith(
          isMagneticReedClosed: isTampered,
        ),
      );

      if (!isTampered) {
        _alerts.insert(0, {
          'title': '🚨 TAMPER BREACH DETECTED',
          'body':
              'Container ${_selectedContainer.containerNumber} – Magnetic reed open and door breach detected. Customs alerted.',
          'time': 'Just now',
          'isUnread': true,
          'type': 'danger',
        });
      }
    });
  }

  void _toggleDeviation() {
    setState(() {
      _isDeviated = !_isDeviated;
      if (_isDeviated) {
        _alerts.insert(0, {
          'title': 'Route Deviation Alert',
          'body':
              'Container ${_selectedContainer.containerNumber} has deviated 72 m outside Corridor Alpha geofence.',
          'time': 'Just now',
          'isUnread': true,
          'type': 'warning',
        });
      }
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of the Container Owner Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── SRS Figures 10, 12, 13, 14: Curved Navy Top Header ─────────
          if (_currentTabIndex != 1) // In Navigate Tab (Figure 11), map is fullscreen
            _buildCurvedTopHeader(),

          // ── Active Tab View ───────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                // Tab 0: Figure 10 (Home Screen)
                _buildHomeTab(),

                // Tab 1: Figure 11 (Navigate / Live Track Screen)
                _buildNavigateTab(),

                // Tab 2: Figure 12 (Notifications / Alerts Page)
                _buildAlertsTab(),

                // Tab 3: Figure 13 (Trip / Consignment Details)
                _buildTripTab(),

                // Tab 4: Figure 14 (Profile Page)
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),

      // ── Figures 10-14: 5-Destination Bottom Navigation Bar ─────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.location_on_outlined,
                  selectedIcon: Icons.location_on_rounded,
                  label: 'Navigate',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.notifications_none_rounded,
                  selectedIcon: Icons.notifications_rounded,
                  label: 'Alerts',
                  badgeCount: _alerts.where((a) => a['isUnread'] == true).length,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description_rounded,
                  label: 'Trip',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurvedTopHeader() {
    String title;
    String? subtitle;

    switch (_currentTabIndex) {
      case 0:
        title = 'Container Owner Portal';
        subtitle = 'Cargo Fleet Monitoring • Active Consignments';
        break;
      case 2:
        title = 'Notifications';
        subtitle = 'Stay updated on your consignment';
        break;
      case 3:
        title = 'Trip Details';
        subtitle = 'Current journey information';
        break;
      case 4:
        title = 'Cargo Owner';
        subtitle = 'Licensed Importer / Exporter';
        break;
      default:
        title = 'Container Owner Portal';
        subtitle = 'Cargo Fleet Monitoring';
    }

    return SrsCurvedHeader(
      title: title,
      subtitle: subtitle,
      onProfileTap: () {
        setState(() => _currentTabIndex = 4);
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _currentTabIndex = 4),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 0: Figure 10 (Home Screen for Owner) ─────────────────────────
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fleet Container Selector
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _containers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final c = _containers[index];
                final isSelected = c.containerNumber == _selectedContainer.containerNumber;
                return ChoiceChip(
                  label: Text(c.containerNumber),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0E3352),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedContainer = c);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Figure 10: Current Trip / Consignment Card
          Container(
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
                        color: const Color(0xFFDCFCE7),
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
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
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
                          _selectedContainer.containerNumber,
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
                // Embedded Route Map
                GestureDetector(
                  onTap: () => setState(() => _currentTabIndex = 1),
                  child: CorridorMapWidget(
                    corridorTitle: 'Colombo Customs Corridor Alpha',
                    originTitle: 'Katunayake',
                    destinationTitle: 'Port of Colombo',
                    progress: 0.60,
                    isDeviated: _isDeviated,
                    deviationMeters: _isDeviated ? 72.0 : 0.0,
                    speedKmH: 42,
                    height: 180,
                    showSrsCallouts: true,
                    showTopStatusOverlay: false,
                    onToggleDeviation: _toggleDeviation,
                  ),
                ),
                const SizedBox(height: 14),
                // Distance Left & ETA (Figure 10)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Distance Left',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '142 km',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(color: Color(0xFFE2E8F0)),
                    ),
                    Column(
                      children: [
                        Text(
                          'ETA',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '2h 30m',
                          style: TextStyle(
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
          ),

          const SizedBox(height: 16),

          // Figure 10: Quick Stats Card
          Container(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '24',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total Trips',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '98%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'On-Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '3.2k',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'km Total',
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Figure 10: Emergency Alert / Tamper Warning Button
          InkWell(
            onTap: _toggleTamper,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF87171), width: 1.2),
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dual Sensor Telemetry
          SensorTelemetryCard(
            container: _selectedContainer,
            onTestTamperPressed: _toggleTamper,
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Figure 11 (Navigate / Live Track Screen) ───────────────────
  Widget _buildNavigateTab() {
    return Stack(
      children: [
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
            onToggleDeviation: _toggleDeviation,
          ),
        ),

        // Floating Top Destination Card (Figure 11)
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                        Text(
                          'ETA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '2h 30m',
                          style: TextStyle(
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

        // Floating Bottom Turn Card & Action Button (Figure 11)
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _toggleDeviation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDeviated
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF0E3352),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isDeviated ? 'Restore Approved Route' : 'Simulate Deviation',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Figure 12 (Notifications / Alerts Page) ───────────────────
  Widget _buildAlertsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final type = alert['type'] as String? ?? 'info';
        final isUnread = alert['isUnread'] as bool? ?? false;

        Color iconBg;
        Color iconColor;
        IconData icon;

        switch (type) {
          case 'danger':
            iconBg = const Color(0xFFFEE2E2);
            iconColor = const Color(0xFFEF4444);
            icon = Icons.warning_rounded;
            break;
          case 'warning':
            iconBg = const Color(0xFFFEF3C7);
            iconColor = const Color(0xFFF59E0B);
            icon = Icons.warning_amber_rounded;
            break;
          case 'success':
            iconBg = const Color(0xFFDCFCE7);
            iconColor = const Color(0xFF16A34A);
            icon = Icons.check_rounded;
            break;
          case 'info':
          default:
            iconBg = const Color(0xFFEFF6FF);
            iconColor = const Color(0xFF2563EB);
            icon = Icons.notifications_none_rounded;
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          alert['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['body'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alert['time'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  // ── Tab 3: Figure 13 (Trip / Consignment Details) ─────────────────────
  Widget _buildTripTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container Information Card (Figure 13)
          Container(
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
                        color: const Color(0xFFDCFCE7),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem('Container ID', _selectedContainer.containerNumber, const Color(0xFF0F172A)),
                    ),
                    Expanded(
                      child: _buildGridItem('Seal Status', 'Closed', const Color(0xFF16A34A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem('Weight', '18,500 kg', const Color(0xFF0F172A)),
                    ),
                    Expanded(
                      child: _buildGridItem('Type', '40ft HC', const Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem('Authorized Prime Mover', 'WP LY-9921', const Color(0xFF475569)),
                    ),
                    Expanded(
                      child: _buildGridItem('Assigned Smart Lock', _selectedContainer.rfidLockId, AppTheme.customsBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Route Information Card (Figure 13)
          Container(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: const Icon(Icons.location_on, color: Colors.white, size: 13),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Location',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Katunayake Export Processing Zone',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Started: Today at 6:00 AM',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Destination',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Port of Colombo',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Expected: Today at 11:30 AM',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Trip Progress Card (Figure 13)
          Container(
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProgressCircleWidget(
                      icon: Icons.navigation_rounded,
                      bgColor: Color(0xFFEFF6FF),
                      iconColor: Color(0xFF2563EB),
                      label: 'Distance',
                      value: '142 km left',
                    ),
                    _ProgressCircleWidget(
                      icon: Icons.access_time_rounded,
                      bgColor: Color(0xFFEFF6FF),
                      iconColor: Color(0xFF3B82F6),
                      label: 'ETA',
                      value: '2h 30m',
                    ),
                    _ProgressCircleWidget(
                      icon: Icons.inventory_2_outlined,
                      bgColor: Color(0xFFDCFCE7),
                      iconColor: Color(0xFF16A34A),
                      label: 'Status',
                      value: 'On Track',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Completed', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('60%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  // ── Tab 4: Figure 14 (Profile Page for Owner) ─────────────────────────
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF0E3352),
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  'Licensed Importer / Exporter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  'CGO-OWN-2026-99 • Lanka Global Logistics',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Information Card (Figure 14)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 16),
                _ContactRowWidget(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'cargo.owner@securetrack.lk',
                ),
                SizedBox(height: 14),
                _ContactRowWidget(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+94 11 987 6543',
                ),
                SizedBox(height: 14),
                _ContactRowWidget(
                  icon: Icons.apartment_rounded,
                  label: 'Registered Entity',
                  value: 'Lanka Global Logistics & Exports Ltd',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Performance Stats Card (Figure 14: 2x2 colored grid)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Stats',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TintedStatWidget(
                        value: '24',
                        label: 'Total Consignments',
                        bgColor: Color(0xFFF0F7FF),
                        valueColor: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _TintedStatWidget(
                        value: '98%',
                        label: 'On-Time Rate',
                        bgColor: Color(0xFFF0FDF4),
                        valueColor: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TintedStatWidget(
                        value: '3.2k',
                        label: 'km Monitored',
                        bgColor: Color(0xFFF0F7FF),
                        valueColor: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _TintedStatWidget(
                        value: '4.8',
                        label: 'Compliance Rating',
                        bgColor: Color(0xFFFFFBEB),
                        valueColor: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Login Session Details Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Login Session Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 14),
                _buildSessionRow(
                  icon: Icons.history_rounded,
                  label: 'Last Recorded Login',
                  value: AuthService.instance.lastLogin?.formattedTime ?? 'Active Session',
                  color: const Color(0xFF1565C0),
                ),
                const Divider(height: 20),
                _buildSessionRow(
                  icon: Icons.devices_rounded,
                  label: 'Device & Location',
                  value: AuthService.instance.lastLogin?.deviceInfo ?? 'Mobile App • Sri Lanka (Active)',
                  color: Colors.teal,
                ),
                const Divider(height: 20),
                _buildSessionRow(
                  icon: Icons.security_rounded,
                  label: 'Session State',
                  value: 'Authorized Cargo Consignee (Secure)',
                  color: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Red Logout Button (Figure 14)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutConfirmation(context),
              icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
              label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _currentTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                  size: 24,
                ),
                if (badgeCount != null && badgeCount > 0 && !isSelected)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCircleWidget extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String label;
  final String value;

  const _ProgressCircleWidget({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }
}

class _ContactRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRowWidget({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }
}

class _TintedStatWidget extends StatelessWidget {
  final String value;
  final String label;
  final Color bgColor;
  final Color valueColor;

  const _TintedStatWidget({
    required this.value,
    required this.label,
    required this.bgColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
