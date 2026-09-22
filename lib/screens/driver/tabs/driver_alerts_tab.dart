import 'package:flutter/material.dart';
import '../../../utils/alert_navigation_helper.dart';

class DriverAlertsTab extends StatefulWidget {
  final List<String> additionalAlerts;
  final void Function(int tabIndex, String alertTitle, String sectionName)? onNavigateToSection;

  const DriverAlertsTab({
    super.key,
    this.additionalAlerts = const [],
    this.onNavigateToSection,
  });

  @override
  State<DriverAlertsTab> createState() => _DriverAlertsTabState();
}

class _DriverAlertsTabState extends State<DriverAlertsTab> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  @override
  void didUpdateWidget(DriverAlertsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.additionalAlerts != oldWidget.additionalAlerts) {
      _initNotifications();
    }
  }

  void _initNotifications() {
    final defaultList = [
      {
        'id': 'alt_dev',
        'title': 'Route Deviation',
        'body': 'You deviated from the optimized route 15 minutes ago',
        'time': '15 min ago',
        'isUnread': true,
        'type': 'warning',
      },
      {
        'id': 'alt_weather',
        'title': 'Weather Update',
        'body': 'Light rain expected on your route in 1 hour',
        'time': '1 hour ago',
        'isUnread': true,
        'type': 'info',
      },
      {
        'id': 'alt_checkpoint',
        'title': 'Checkpoint Passed',
        'body': 'You successfully passed checkpoint #3 (Ingurukade Flyover)',
        'time': '2 hours ago',
        'isUnread': false,
        'type': 'success',
      },
      {
        'id': 'alt_traffic',
        'title': 'Traffic Alert',
        'body': 'Heavy traffic detected ahead, adding 20 min to ETA',
        'time': '3 hours ago',
        'isUnread': false,
        'type': 'warning',
      },
    ];

    final dynamicAlerts = widget.additionalAlerts.map((alert) {
      return {
        'id': 'dyn_${alert.hashCode}',
        'title': alert.contains('Deviation')
            ? 'Corridor Route Deviation'
            : 'Customs System Notice',
        'body': alert,
        'time': 'Just now',
        'isUnread': true,
        'type': alert.contains('🚨') || alert.contains('⚠️') ? 'danger' : 'info',
      };
    }).toList();

    _notifications = [...dynamicAlerts, ...defaultList];
  }

  void _handleAlertTap(Map<String, dynamic> item) {
    setState(() {
      item['isUnread'] = false;
    });

    final title = item['title'] as String;
    final body = item['body'] as String;
    final target = AlertNavigationHelper.resolveAlertOrigin(title, body, role: 'driver');

    if (widget.onNavigateToSection != null) {
      widget.onNavigateToSection!(target.tabIndex, title, target.sectionName);
    } else {
      AlertNavigationHelper.navigateToOriginSection(
        context: context,
        target: target,
        alertTitle: title,
        onTabSelected: (_) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        for (final n in _notifications)
          _buildNotificationCard(n),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final body = item['body'] as String;
    final time = item['time'] as String;
    final isUnread = item['isUnread'] as bool;
    final type = item['type'] as String;

    final target = AlertNavigationHelper.resolveAlertOrigin(title, body, role: 'driver');

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
          onTap: () => _handleAlertTap(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Clickable Originating Section Action Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  target.sectionIcon,
                                  size: 12,
                                  color: const Color(0xFF2563EB),
                                ),
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
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9,
                                  color: Color(0xFF2563EB),
                                ),
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
  }
}
