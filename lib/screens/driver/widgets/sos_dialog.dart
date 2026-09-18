import 'package:flutter/material.dart';

class SosDialog extends StatelessWidget {
  final String vehiclePlate;
  final String driverName;
  final VoidCallback onSosTriggered;

  const SosDialog({
    super.key,
    required this.vehiclePlate,
    required this.driverName,
    required this.onSosTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 48,
        ),
      ),
      title: const Text(
        'EMERGENCY SOS ALERT',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.1,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Triggering SOS immediately alerts the 24/7 SecureTrack Command Center, nearby patrol units, and fleet managers with your live location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.directions_bus, 'Vehicle', vehiclePlate),
                  const Divider(height: 12),
                  _infoRow(Icons.person, 'Driver', driverName),
                  const Divider(height: 12),
                  _infoRow(
                    Icons.location_on,
                    'Location',
                    '6.9271° N, 79.8612° E\nBaseline Rd, Colombo',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone_in_talk, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fleet Emergency Hotline:\n+94 11 234 5678 / 1990',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onSosTriggered();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.notifications_active),
          label: const Text(
            'BROADCAST SOS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
