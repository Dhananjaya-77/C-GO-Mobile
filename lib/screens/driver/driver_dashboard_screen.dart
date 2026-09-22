import 'package:flutter/material.dart';
import '../../models/container_model.dart';
import '../../models/driver_model.dart';
import '../../models/trip_model.dart';
import '../../models/vehicle_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/srs_curved_header.dart';
import 'tabs/driver_alerts_tab.dart';
import 'tabs/driver_home_tab.dart';
import 'tabs/driver_navigate_tab.dart';
import 'tabs/driver_profile_tab.dart';
import 'tabs/driver_trip_tab.dart';
import 'widgets/incident_report_dialog.dart';
import 'widgets/inspection_checklist_dialog.dart';
import 'widgets/sos_dialog.dart';
import '../welcome_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _currentTabIndex = 0;
  bool _isOnDuty = true;

  DriverProfile _driver = DriverProfile.mockDriver;
  VehicleInfo _vehicle = VehicleInfo.mockVehicle;
  TripInfo? _activeTrip = TripInfo.mockActiveTrip;
  final List<TripInfo> _completedTrips = List.from(TripInfo.mockCompletedTrips);

  final List<String> _recentAlerts = [
    'Pre-trip clearance verified by Customs Control Unit',
    'Colombo Fort to Orugodawaththa: GPS lock continuous (11 Satellites)',
    'Geofence Checkpoint: Totalanga Elevated Flyover cleared',
    'Driver Safety Rating: 4.96 ★ (Authorized Customs Haulier)',
  ];

  void _onDutyChanged(bool newStatus) {
    setState(() {
      _isOnDuty = newStatus;
      _driver = _driver.copyWith(
        status: newStatus ? ShiftStatus.onDuty : ShiftStatus.offDuty,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? 'Shift Started: GPS Telemetry transmitting to Sri Lanka Customs'
              : 'Shift Paused: You are now Off Duty',
        ),
        backgroundColor:
            newStatus ? AppTheme.securityGreen : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleTripAction() {
    if (_activeTrip == null) return;

    setState(() {
      final newStatus = _activeTrip!.status == TripStatus.paused
          ? TripStatus.inProgress
          : TripStatus.paused;
      _activeTrip = _activeTrip!.copyWith(status: newStatus);
    });

    final isPaused = _activeTrip!.status == TripStatus.paused;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPaused
            ? 'Transit Paused: Rest waypoint logged'
            : 'Transit Resumed: Customs Corridor GPS active'),
        backgroundColor:
            isPaused ? AppTheme.warningAmber : AppTheme.customsBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNextStopReached() {
    if (_activeTrip == null) return;

    final stops = List<RouteStop>.from(_activeTrip!.stops);
    final currentIndex = stops.indexWhere((s) => s.isCurrent);

    if (currentIndex != -1) {
      stops[currentIndex] = RouteStop(
        name: stops[currentIndex].name,
        scheduledTime: stops[currentIndex].scheduledTime,
        isCompleted: true,
        isCurrent: false,
        checkpointNote: 'Checkpoint cleared by hauler.',
      );

      final nextIndex = currentIndex + 1;
      if (nextIndex < stops.length) {
        stops[nextIndex] = RouteStop(
          name: stops[nextIndex].name,
          scheduledTime: stops[nextIndex].scheduledTime,
          isCompleted: false,
          isCurrent: true,
          checkpointNote: 'In transit to next checkpoint.',
        );

        final updatedCovered = (_activeTrip!.coveredDistanceKm + 2.8)
            .clamp(0.0, _activeTrip!.totalDistanceKm);

        setState(() {
          _activeTrip = _activeTrip!.copyWith(
            stops: stops,
            coveredDistanceKm: updatedCovered,
            nextStop: stops[nextIndex].name,
            nextStopDistanceKm: 1.8,
            nextStopEtaMinutes: 5,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Arrived at ${stops[currentIndex].name}. Next Checkpoint: ${stops[nextIndex].name}'),
            backgroundColor: AppTheme.customsBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _finishTrip();
      }
    }
  }

  void _finishTrip() {
    if (_activeTrip == null) return;

    final finished = _activeTrip!.copyWith(
      status: TripStatus.completed,
      coveredDistanceKm: _activeTrip!.totalDistanceKm,
    );

    setState(() {
      _completedTrips.insert(0, finished);
      _activeTrip = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Corridor route completed successfully! Destination ICD reached.'),
        backgroundColor: AppTheme.securityGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSosDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SosDialog(
        vehiclePlate: _vehicle.plateNumber,
        driverName: 'Authorized Driver',
        onSosTriggered: () {
          setState(() {
            _recentAlerts.insert(0, '🚨 EMERGENCY SOS BROADCASTED TO CUSTOMS COMMAND');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '🚨 SOS ALERT TRANSMITTED! Sri Lanka Customs & Police dispatched.'),
              backgroundColor: AppTheme.tamperRed,
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showInspectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => InspectionChecklistDialog(
        vehiclePlate: _vehicle.plateNumber,
        onInspectionSubmitted: (passed) {
          setState(() {
            _vehicle = _vehicle.copyWith(
              isPreTripPassed: true,
              lastInspectionTime: 'Just now (Driver Self-Check Verified)',
            );
            _recentAlerts.insert(
                0, 'Pre-trip 10-point checklist verified by driver');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pre-trip inspection recorded and approved!'),
              backgroundColor: AppTheme.securityGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showIncidentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => IncidentReportDialog(
        vehiclePlate: _vehicle.plateNumber,
        onIncidentSubmitted: (summary) {
          setState(() {
            _recentAlerts.insert(0, 'Incident reported: $summary');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incident report logged and sent to control room.'),
              backgroundColor: AppTheme.warningAmber,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of the Driver Dashboard?',
        ),
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
                // Tab 0: Figure 10 (Mobile Home Screen)
                DriverHomeTab(
                  driver: _driver,
                  vehicle: _vehicle,
                  activeTrip: _activeTrip,
                  isOnDuty: _isOnDuty,
                  onDutyChanged: _onDutyChanged,
                  onSosPressed: _showSosDialog,
                  onInspectionPressed: _showInspectionDialog,
                  onIncidentReportPressed: _showIncidentDialog,
                  onTripActionPressed: _toggleTripAction,
                  onViewRoutesPressed: () {
                    setState(() => _currentTabIndex = 1);
                  },
                  onNextStopReached: _onNextStopReached,
                  recentAlerts: _recentAlerts,
                ),

                // Tab 1: Figure 11 (Mobile Navigate Screen)
                DriverNavigateTab(
                  activeTrip: _activeTrip,
                  onSimulateDeviation: () {
                    setState(() {
                      _recentAlerts.insert(
                          0, '⚠️ Geofence Route Deviation: Alert sent to Customs');
                    });
                  },
                ),

                // Tab 2: Figure 12 (Mobile Notification Page)
                DriverAlertsTab(
                  additionalAlerts: _recentAlerts,
                  onNavigateToSection: (targetIndex, alertTitle, sectionName) {
                    setState(() {
                      _currentTabIndex = targetIndex;
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Navigated to $sectionName for "$alertTitle"',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF0E3352),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 2200),
                      ),
                    );
                  },
                ),

                // Tab 3: Figure 13 (Mobile Trip Details)
                DriverTripTab(
                  activeTrip: _activeTrip,
                  vehicle: _vehicle,
                  container: ContainerInfo.mockPrimaryContainer,
                ),

                // Tab 4: Figure 14 (Mobile Profile Page)
                DriverProfileTab(
                  driver: _driver,
                ),
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
                  badgeCount: _recentAlerts.length,
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
      case 0: // Figure 10: Mobile Home Screen
        title = 'Driver Navigation Module';
        subtitle = null;
        break;
      case 2: // Figure 12: Notifications
        title = 'Notifications';
        subtitle = 'Stay updated on your trip';
        break;
      case 3: // Figure 13: Trip Details
        title = 'Trip Details';
        subtitle = 'Current journey information';
        break;
      case 4: // Figure 14: Profile
        title = 'Driver Profile';
        subtitle = null;
        break;
      default:
        title = 'Driver Navigation Module';
        subtitle = null;
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
          // Emergency SOS Quick Button
          IconButton(
            tooltip: 'Emergency SOS',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded,
                  size: 18, color: Colors.white),
            ),
            onPressed: _showSosDialog,
          ),
          const SizedBox(width: 4),
          // Quick Logout Button
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(width: 4),
          // User Avatar Button (Figure 10)
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
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent, // Pill highlight
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
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
