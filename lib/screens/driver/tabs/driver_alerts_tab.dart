import 'package:flutter/material.dart';

class DriverAlertsTab extends StatelessWidget {
  final List<String> additionalAlerts;

  const DriverAlertsTab({
    super.key,
    this.additionalAlerts = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Standard Figure 12 Notifications
    final defaultNotifications = [
      {
        'title': 'Route Deviation',
        'body': 'You deviated from the optimized route 15 minutes ago',
        'time': '15 min ago',
        'isUnread': true,
        'type': 'warning',
      },
      {
        'title': 'Weather Update',
        'body': 'Light rain expected on your route in 1 hour',
        'time': '1 hour ago',
        'isUnread': true,
        'type': 'info',
      },
      {
        'title': 'Checkpoint Passed',
        'body': 'You successfully passed checkpoint #3',
        'time': '2 hours ago',
        'isUnread': false,
        'type': 'success',
      },
      {
        'title': 'Traffic Alert',
        'body': 'Heavy traffic detected ahead, adding 20 min to ETA',
        'time': '3 hours ago',
        'isUnread': false,
        'type': 'warning',
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        // Any dynamic alerts dispatched during session
        for (final alert in additionalAlerts)
          _buildNotificationCard(
            title: 'Customs System Notice',
            body: alert,
            time: 'Just now',
            isUnread: true,
            type: alert.contains('🚨') ? 'danger' : 'info',
          ),

        for (final n in defaultNotifications)
          _buildNotificationCard(
            title: n['title'] as String,
            body: n['body'] as String,
            time: n['time'] as String,
            isUnread: n['isUnread'] as bool,
            type: n['type'] as String,
          ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String body,
    required String time,
    required bool isUnread,
    required String type,
  }) {
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
                      title,
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
                  body,
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
                      time,
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
  }
}
