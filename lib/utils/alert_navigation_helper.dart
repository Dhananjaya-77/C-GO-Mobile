import 'package:flutter/material.dart';

/// Target metadata for the originating section of an alert.
class AlertOriginTarget {
  final int tabIndex;
  final String sectionName;
  final IconData sectionIcon;
  final String actionBadgeText;

  const AlertOriginTarget({
    required this.tabIndex,
    required this.sectionName,
    required this.sectionIcon,
    required this.actionBadgeText,
  });
}

/// Helper to analyze alert content and route the user to its originating section.
class AlertNavigationHelper {
  /// Resolves the origin section for a given alert by examining its title and body text.
  static AlertOriginTarget resolveAlertOrigin(String title, String body, {String role = 'driver'}) {
    final combined = ('$title $body').toLowerCase();

    // 1. Overview / Emergency / Pre-trip / SOS (Highest Priority)
    if (combined.contains('emergency') ||
        combined.contains('sos') ||
        combined.contains('incident') ||
        combined.contains('patrol') ||
        combined.contains('pre-trip') ||
        combined.contains('dispatch')) {
      return const AlertOriginTarget(
        tabIndex: 0, // Home Tab
        sectionName: 'Home Screen & Safety Overview',
        sectionIcon: Icons.home_rounded,
        actionBadgeText: 'View in Home',
      );
    }

    // 2. Live Navigation / GPS / Route Deviation / Traffic / Weather
    if (combined.contains('deviation') ||
        combined.contains('deviated') ||
        combined.contains('route') ||
        combined.contains('corridor') ||
        combined.contains('geofence') ||
        combined.contains('traffic') ||
        combined.contains('weather') ||
        combined.contains('highway') ||
        combined.contains('speed')) {
      return const AlertOriginTarget(
        tabIndex: 1, // Navigate Tab
        sectionName: 'Live Route Navigation',
        sectionIcon: Icons.navigation_rounded,
        actionBadgeText: 'View in Live Navigate',
      );
    }

    // 3. Trip Details / Checkpoints / Smart Lock / Seal / Cargo / Disarm
    if (combined.contains('checkpoint') ||
        combined.contains('milestone') ||
        combined.contains('seal') ||
        combined.contains('smart lock') ||
        combined.contains('rfid') ||
        combined.contains('disarm') ||
        combined.contains('cargo') ||
        combined.contains('container') ||
        combined.contains('manifest') ||
        combined.contains('clearance') ||
        combined.contains('inspection')) {
      return const AlertOriginTarget(
        tabIndex: 3, // Trip Details Tab
        sectionName: 'Trip Details & Security',
        sectionIcon: Icons.description_rounded,
        actionBadgeText: 'View in Trip Details',
      );
    }

    // 4. Profile / Shift / Driver Rating / Credentials / Session
    if (combined.contains('driver') ||
        combined.contains('profile') ||
        combined.contains('rating') ||
        combined.contains('shift') ||
        combined.contains('duty') ||
        combined.contains('login') ||
        combined.contains('account')) {
      return const AlertOriginTarget(
        tabIndex: 4, // Profile Tab
        sectionName: 'User Profile & Credentials',
        sectionIcon: Icons.person_rounded,
        actionBadgeText: 'View in Profile',
      );
    }

    // Default fallback to Navigate section
    return const AlertOriginTarget(
      tabIndex: 1,
      sectionName: 'Live Route Navigation',
      sectionIcon: Icons.navigation_rounded,
      actionBadgeText: 'View in Section',
    );
  }

  /// Dispatches navigation to the target section and presents a user feedback snackbar.
  static void navigateToOriginSection({
    required BuildContext context,
    required AlertOriginTarget target,
    required String alertTitle,
    required void Function(int tabIndex) onTabSelected,
  }) {
    // 1. Switch active dashboard tab
    onTabSelected(target.tabIndex);

    // 2. Show floating feedback notification
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                target.sectionIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opened: ${target.sectionName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Originating from "$alertTitle"',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0E3352),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }
}
