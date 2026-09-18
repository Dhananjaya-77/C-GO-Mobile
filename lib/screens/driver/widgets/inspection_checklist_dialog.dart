import 'package:flutter/material.dart';

class InspectionChecklistDialog extends StatefulWidget {
  final String vehiclePlate;
  final ValueChanged<bool> onInspectionSubmitted;

  const InspectionChecklistDialog({
    super.key,
    required this.vehiclePlate,
    required this.onInspectionSubmitted,
  });

  @override
  State<InspectionChecklistDialog> createState() =>
      _InspectionChecklistDialogState();
}

class _InspectionChecklistDialogState extends State<InspectionChecklistDialog> {
  final List<Map<String, dynamic>> _checklistItems = [
    {'title': 'Service & Parking Brakes Check', 'checked': true},
    {'title': 'Headlights, Taillights & Flashers', 'checked': true},
    {'title': 'Tire Pressure & Tread Depth', 'checked': true},
    {'title': 'Mirrors, Windshield & Wipers', 'checked': true},
    {'title': 'Engine Oil & Coolant Levels', 'checked': true},
    {'title': 'Seatbelts & Door Locks', 'checked': true},
    {'title': 'Horn & Reverse Safety Alarm', 'checked': true},
    {'title': 'First Aid Kit & Fire Extinguisher', 'checked': true},
    {'title': 'Emergency Exit Latches & Hammer', 'checked': false},
    {'title': 'Revenue License & Fleet Insurance', 'checked': true},
  ];

  int get _checkedCount =>
      _checklistItems.where((item) => item['checked'] == true).length;

  void _toggleAll(bool value) {
    setState(() {
      for (var item in _checklistItems) {
        item['checked'] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAllChecked = _checkedCount == _checklistItems.length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fact_check_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pre-Trip Safety Inspection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Vehicle: ${widget.vehiclePlate}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAllChecked ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAllChecked ? Colors.green.shade200 : Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAllChecked ? Icons.check_circle : Icons.info_outline,
                      size: 18,
                      color: isAllChecked ? Colors.green.shade700 : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Completed: $_checkedCount of ${_checklistItems.length} items checked',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isAllChecked ? Colors.green.shade800 : Colors.amber.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _toggleAll(!isAllChecked),
                      child: Text(
                        isAllChecked ? 'Uncheck' : 'Check All',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _checklistItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _checklistItems[index];
                    return Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      child: CheckboxListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item['checked'] == true
                                ? FontWeight.w500
                                : FontWeight.normal,
                            decoration: item['checked'] == true
                                ? TextDecoration.none
                                : null,
                          ),
                        ),
                        value: item['checked'] as bool,
                        onChanged: (val) {
                          setState(() {
                            item['checked'] = val ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isAllChecked
                          ? () {
                              Navigator.of(context).pop();
                              widget.onInspectionSubmitted(true);
                            }
                          : null,
                      icon: const Icon(Icons.verified),
                      label: const Text('Submit Clearance'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
