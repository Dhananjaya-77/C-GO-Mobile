import 'package:flutter/material.dart';
import '../../models/shipment_model.dart';
import '../../models/trip_model.dart';
import '../../services/auth_service.dart';
import '../../utils/alert_navigation_helper.dart';
import '../../utils/app_theme.dart';
import '../../widgets/corridor_map_widget.dart';
import '../../widgets/srs_curved_header.dart';
import '../welcome_screen.dart';

class InspectorDashboardScreen extends StatefulWidget {
  const InspectorDashboardScreen({super.key});

  @override
  State<InspectorDashboardScreen> createState() =>
      _InspectorDashboardScreenState();
}

class _InspectorDashboardScreenState extends State<InspectorDashboardScreen> {
  int _currentTabIndex = 0;
  int _selectedNavigateRouteIndex = 0;

  final ShipmentInfo _activeShipment = ShipmentInfo.mockActiveShipment;

  // Stage 1 Initialization Form Controllers
  final _initFormKey = GlobalKey<FormState>();
  final _containerIdController = TextEditingController(text: 'CMAU-652918-4');
  final _iotDeviceIdController = TextEditingController(text: 'ST-ESP32-124');
  final _rfidLockController = TextEditingController(text: 'SL-RFID-99480');
  final _cusDecController = TextEditingController(text: 'CD-2026-COL-0914');
  String _selectedCorridor = 'Colombo Fort to Orugodawaththa';
  bool _isArming = false;

  // Stage 4 Disarm Form Controllers
  final _authCodeController = TextEditingController(text: '884921');
  bool _isDisarming = false;
  bool _isDisarmSuccess = false;
  bool _isDeviated = false;

  // 8-Point Inspection Checklist
  final Map<String, bool> _inspectionChecklist = {
    '1. Physical High-Security Bolt Seal intact & unbent': true,
    '2. Electronic Smart Lock RFID clamped securely on door bar': true,
    '3. Magnetic Reed Switch: Continuous closed circuit': true,
    '4. Electronic Smart Seal Shackle verified & engaged': true,
    '5. ESP32 Tracker battery level above 80%': true,
    '6. GPS Receiver locked with > 8 satellites': true,
    '7. SIM800L GSM connected & MQTT 5.0 heartbeat acknowledged': true,
    '8. CusDec declaration matches container & cargo manifest': true,
  };

  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Route Deviation',
      'body': 'Container HLCU-902184-5 deviated from Colombo Fort to Grayline 2 corridor 15 minutes ago.',
      'time': '15 min ago',
      'isUnread': true,
      'type': 'warning',
    },
    {
      'title': 'Weather Update',
      'body': 'Light rain expected on route in 1 hour. Wet weather driving limits enforced.',
      'time': '1 hour ago',
      'isUnread': true,
      'type': 'info',
    },
    {
      'title': 'Checkpoint Passed',
      'body': 'Container MSCU-742910-8 cleared Checkpoint #3 (Ingurukade Junction).',
      'time': '2 hours ago',
      'isUnread': false,
      'type': 'success',
    },
    {
      'title': 'Traffic Alert',
      'body': 'Moderate traffic detected near Orugodawaththa junction, adding 5 min to ETA.',
      'time': '3 hours ago',
      'isUnread': false,
      'type': 'warning',
    },
  ];

  @override
  void dispose() {
    _containerIdController.dispose();
    _iotDeviceIdController.dispose();
    _rfidLockController.dispose();
    _cusDecController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  void _toggleDeviation() {
    setState(() {
      _isDeviated = !_isDeviated;
      if (_isDeviated) {
        _alerts.insert(0, {
          'title': '🚨 GEOPATH VIOLATION',
          'body': 'Vehicle deviated 72 m from Colombo Fort to Orugodawaththa! Customs Patrol Unit dispatched.',
          'time': 'Just now',
          'isUnread': true,
          'type': 'danger',
        });
      }
    });
  }

  void _handleStage1Arm() {
    if (!_initFormKey.currentState!.validate()) return;

    setState(() => _isArming = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isArming = false;
        _alerts.insert(0, {
          'title': 'Seal Armed & Dispatched',
          'body':
              'Container ${_containerIdController.text} sealed with ${_rfidLockController.text} and departed Gate 4.',
          'time': 'Just now',
          'isUnread': true,
          'type': 'success',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Smart Lock ${_rfidLockController.text} ARMED for container ${_containerIdController.text}. Tracking active.',
          ),
          backgroundColor: AppTheme.securityGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _handleStage4Disarm() {
    if (_authCodeController.text.trim() != '884921') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid master disarm authentication PIN!'),
          backgroundColor: AppTheme.tamperRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isDisarming = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isDisarming = false;
        _isDisarmSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Container electronically disarmed and arrival confirmed.'),
          backgroundColor: AppTheme.securityGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of the Customs Inspector Portal?'),
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
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
                // Tab 0: Figure 10 (Home Screen for Inspector)
                _buildHomeTab(),

                // Tab 1: Figure 11 (Corridor Monitor Screen)
                _buildNavigateTab(),

                // Tab 2: Figure 12 (Alerts & Notifications Page)
                _buildAlertsTab(),

                // Tab 3: Figure 13 (Manifest & Verification)
                _buildManifestTab(),

                // Tab 4: Figure 14 (Inspector Profile Page)
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
        title = 'Customs Inspector Portal';
        subtitle = 'Customs Enforcement Division • Station: Colombo Port Gate 4 / ICD';
        break;
      case 2:
        title = 'Notifications';
        subtitle = 'Stay updated on your trip';
        break;
      case 3:
        title = 'Trip Details';
        subtitle = 'Current journey information';
        break;
      case 4:
        title = 'Inspector Officer';
        subtitle = 'Customs Enforcement Division';
        break;
      default:
        title = 'Customs Inspector Portal';
        subtitle = 'Customs Enforcement Division';
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
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorStatTile({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 0: Figure 10 (Home Screen for Inspector) ─────────────────────
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Figure 10: Current Trip / Consignment Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
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
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 20, color: Color(0xFF0E3352)),
                        SizedBox(width: 8),
                        Text(
                          'Current Trip',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'On Route',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Container ID',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _activeShipment.containerNumber,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text(
                            'Seal Active',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Embedded Route Map with callouts (Figure 10)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTabIndex = 1),
                    child: CorridorMapWidget(
                      corridorTitle: 'Colombo Fort to Orugodawaththa',
                      originTitle: 'Colombo Fort',
                      destinationTitle: 'Orugodawaththa',
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
                ),
                const SizedBox(height: 14),
                // Distance Left & ETA (Figure 10)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.near_me_rounded, color: Color(0xFF2563EB), size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Distance Left',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '3.3 km',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706), size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ETA',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '18 min',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Patrol Shift',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInspectorStatTile(
                      value: '24',
                      label: 'Total Trips',
                      icon: Icons.local_shipping_outlined,
                      color: const Color(0xFF0F2537),
                      bg: const Color(0xFFF1F5F9),
                    ),
                    const SizedBox(width: 10),
                    _buildInspectorStatTile(
                      value: '98%',
                      label: 'On-Time',
                      icon: Icons.verified_outlined,
                      color: const Color(0xFF10B981),
                      bg: const Color(0xFFECFDF5),
                    ),
                    const SizedBox(width: 10),
                    _buildInspectorStatTile(
                      value: '3.2k',
                      label: 'km Total',
                      icon: Icons.route_outlined,
                      color: const Color(0xFF3B82F6),
                      bg: const Color(0xFFEFF6FF),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Figure 10: Emergency Alert Action
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customs Escort Emergency Broadcasted to Patrol Units.'),
                  backgroundColor: Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF1F2), Color(0xFFFEE2E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Emergency Alert',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Inspection Field App Action Card (Section 3.1 & UC-01)
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
                  'Inspector Field Operations (UC-01)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _currentTabIndex = 3),
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: const Text('Scan & Arm Seal'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1D4ED8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _currentTabIndex = 3),
                        icon: const Icon(Icons.lock_open_rounded, size: 18),
                        label: const Text('ICD Disarm'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0E3352),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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

  // ── Tab 1: Figure 11 (Corridor Monitor Screen) ───────────────────────
  Widget _buildNavigateTab() {
    final activeRoute = kApprovedRoutes[_selectedNavigateRouteIndex];

    return Stack(
      children: [
        Positioned.fill(
          child: CorridorMapWidget(
            corridorTitle: activeRoute.name,
            originTitle: activeRoute.origin,
            destinationTitle: activeRoute.destination,
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

        // Floating Top Destination Card with 3 Routes Selector (Figure 11)
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                // 3 Routes Segmented Selector
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: List.generate(kApprovedRoutes.length, (index) {
                      final r = kApprovedRoutes[index];
                      final isSelected = index == _selectedNavigateRouteIndex;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedNavigateRouteIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0E3352) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              r.destination,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeRoute.destination,
                          style: const TextStyle(
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
                          '${activeRoute.defaultEtaMinutes} min',
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
                const SizedBox(height: 10),
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
                    Text(
                      '${activeRoute.totalDistanceKm} km',
                      style: const TextStyle(
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

        // Floating Bottom Turn Card & Simulate Deviation Button (Figure 11)
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Next Checkpoint',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeRoute.nextTurnDistance,
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
                      activeRoute.nextTurnInstruction,
                      style: const TextStyle(
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _isDeviated ? 'Clear Deviation Alert' : 'Simulate Deviation',
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

  void _handleAlertTap(Map<String, dynamic> alert) {
    setState(() {
      alert['isUnread'] = false;
    });

    final title = alert['title'] as String;
    final body = alert['body'] as String;
    final target = AlertNavigationHelper.resolveAlertOrigin(title, body, role: 'inspector');

    AlertNavigationHelper.navigateToOriginSection(
      context: context,
      target: target,
      alertTitle: title,
      onTabSelected: (idx) {
        setState(() => _currentTabIndex = idx);
      },
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
        final title = alert['title'] as String;
        final body = alert['body'] as String;

        final target = AlertNavigationHelper.resolveAlertOrigin(title, body, role: 'inspector');

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
              width: isUnread ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? const Color(0xFF2563EB).withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _handleAlertTap(alert),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
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
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
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
                            body,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.35),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    alert['time'] as String,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(target.sectionIcon, size: 12, color: const Color(0xFF2563EB)),
                                    const SizedBox(width: 5),
                                    Text(
                                      target.actionBadgeText,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF2563EB)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tab 3: Figure 13 (Manifest & Verification) ───────────────────────
  Widget _buildManifestTab() {
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
                      child: _buildGridItem('Container ID', _activeShipment.containerNumber, const Color(0xFF0F172A)),
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
                      child: _buildGridItem('Authorized Hauler', _activeShipment.vehiclePlate, const Color(0xFF475569)),
                    ),
                    Expanded(
                      child: _buildGridItem('Assigned Smart Lock', _activeShipment.smartLockId, AppTheme.customsBlue),
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                        Container(width: 2, height: 48, color: const Color(0xFFCBD5E1)),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 13),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Location', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(_activeShipment.origin, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          const Text('Started: Today at 8:45 AM', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 20),
                          const Text('Destination', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(_activeShipment.destination, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          const Text('Expected: Today at 9:35 AM', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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

          const SizedBox(height: 16),

          // Stage 1: Initialization & Smart Seal Arming (UC-01)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Form(
              key: _initFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stage 1: Port Initialization & Arming (UC-01)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _containerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Container ID',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _iotDeviceIdController,
                    decoration: const InputDecoration(
                      labelText: 'ESP32 Device ID',
                      prefixIcon: Icon(Icons.developer_board_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _rfidLockController,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Smart Lock RFID',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _cusDecController,
                    decoration: const InputDecoration(
                      labelText: 'CusDec Declaration No',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCorridor,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.alt_route_rounded, color: Color(0xFF0E3352), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    items: kApprovedRoutes.map((route) {
                      return DropdownMenuItem<String>(
                        value: route.name,
                        child: Text(route.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCorridor = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '8-Point Security Inspection Checklist',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  ..._inspectionChecklist.keys.map(
                    (checkItem) => Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      child: CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: _inspectionChecklist[checkItem],
                        onChanged: (val) {
                          setState(() {
                            _inspectionChecklist[checkItem] = val ?? false;
                          });
                        },
                        title: Text(checkItem, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isArming ? null : _handleStage1Arm,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3352),
                      ),
                      icon: _isArming
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.shield_rounded),
                      label: Text(_isArming ? 'Arming Lock & Syncing...' : 'Arm Smart Seal & Clear Gate'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stage 4 Disarm & Unlock Action Section
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
                  'Stage 4: ICD Electronic Disarm & Clearance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Inspector Master Disarm PIN',
                    hintText: '884921',
                    prefixIcon: Icon(Icons.pin_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isDisarming ? null : _handleStage4Disarm,
                    style: FilledButton.styleFrom(
                      backgroundColor: _isDisarmSuccess ? const Color(0xFF16A34A) : const Color(0xFF0E3352),
                    ),
                    icon: _isDisarming
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(_isDisarmSuccess ? Icons.check_circle : Icons.lock_open_rounded),
                    label: Text(
                      _isDisarming
                          ? 'Authorizing Disarm...'
                          : _isDisarmSuccess
                              ? 'Seal Unlocked & Session Closed'
                              : 'Authenticate & Unlock Electronic Seal',
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

  // ── Tab 4: Figure 14 (Profile Page for Inspector) ────────────────────
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
                  child: Icon(Icons.shield, size: 44, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  'Customs Enforcement Division',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  'Station: Colombo Port Gate 4 / ICD • SL-CUS-0884',
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
                  label: 'Official Email',
                  value: 'enforcement.gate4@customs.gov.lk',
                ),
                SizedBox(height: 14),
                _ContactRowWidget(
                  icon: Icons.phone_outlined,
                  label: 'Customs Desk Extension',
                  value: '+94 11 244 5678 (Ext. 402)',
                ),
                SizedBox(height: 14),
                _ContactRowWidget(
                  icon: Icons.security_rounded,
                  label: 'Assigned Port Sector',
                  value: 'Colombo Port SAGT Gate 4 & ICD Corridor',
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
                        label: 'Seals Armed Today',
                        bgColor: Color(0xFFF0F7FF),
                        valueColor: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _TintedStatWidget(
                        value: '98%',
                        label: 'Checklist Compliance',
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
                        label: 'km Corridors Audited',
                        bgColor: Color(0xFFF0F7FF),
                        valueColor: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _TintedStatWidget(
                        value: '4.8',
                        label: 'Station Rating',
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
                  value: 'Customs Officer Authenticated (Secure)',
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
