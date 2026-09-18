import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/inspector/inspector_dashboard_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../utils/app_theme.dart';

class RoleSwitcherSheet extends StatelessWidget {
  final UserRole currentRole;

  const RoleSwitcherSheet({super.key, required this.currentRole});

  static void show(BuildContext context, UserRole currentRole) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RoleSwitcherSheet(currentRole: currentRole),
    );
  }

  void _navigateToRole(BuildContext context, UserRole role) {
    Navigator.of(context).pop();
    if (role == currentRole) return;

    Widget screen;
    switch (role) {
      case UserRole.driver:
        screen = const DriverDashboardScreen();
        break;
      case UserRole.inspector:
        screen = const InspectorDashboardScreen();
        break;
      case UserRole.owner:
        screen = const OwnerDashboardScreen();
        break;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, color: AppTheme.customsBlue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Switch Application Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Select a user portal defined in the SecureTrack SL framework to capture screenshots for the final report.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            _buildRoleTile(
              context: context,
              role: UserRole.driver,
              icon: Icons.local_shipping_rounded,
              title: 'Truck Driver Dashboard',
              badgeText: 'Mobile Navigation Module',
              desc: 'Corridor compliance, GPS tracking, emergency SOS, and vehicle health.',
              isSelected: currentRole == UserRole.driver,
            ),
            const SizedBox(height: 10),
            _buildRoleTile(
              context: context,
              role: UserRole.inspector,
              icon: Icons.policy_rounded,
              title: 'Customs Inspector Dashboard',
              badgeText: 'Field Inspection Portal',
              desc: 'Shipment initialization (Stage 1), seal pairing, and destination disarm (Stage 4).',
              isSelected: currentRole == UserRole.inspector,
            ),
            const SizedBox(height: 10),
            _buildRoleTile(
              context: context,
              role: UserRole.owner,
              icon: Icons.corporate_fare_rounded,
              title: 'Cargo Owner Dashboard',
              badgeText: 'Restricted Client View',
              desc: 'Real-time consignment map, dual-sensor anti-theft telemetry, and arrival alerts.',
              isSelected: currentRole == UserRole.owner,
            ),
            const SizedBox(height: 12),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required UserRole role,
    required IconData icon,
    required String title,
    required String badgeText,
    required String desc,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _navigateToRole(context, role),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.customsBlue.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.customsBlue : AppTheme.slate200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected ? AppTheme.customsBlue : AppTheme.slate100,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.slate700,
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.customsBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.customsBlueDark.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
