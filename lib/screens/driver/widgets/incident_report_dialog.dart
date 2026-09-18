import 'package:flutter/material.dart';

class IncidentReportDialog extends StatefulWidget {
  final String vehiclePlate;
  final ValueChanged<String> onIncidentSubmitted;

  const IncidentReportDialog({
    super.key,
    required this.vehiclePlate,
    required this.onIncidentSubmitted,
  });

  @override
  State<IncidentReportDialog> createState() => _IncidentReportDialogState();
}

class _IncidentReportDialogState extends State<IncidentReportDialog> {
  final _detailsController = TextEditingController();
  String _selectedCategory = 'Mechanical Breakdown';
  String _selectedSeverity = 'Medium';
  bool _photoAttached = false;

  final List<String> _categories = [
    'Mechanical Breakdown',
    'Road Accident',
    'Heavy Traffic / Roadblock',
    'Medical Incident',
    'Flat Tire',
    'Other Issue',
  ];

  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'Low':
        return Colors.blue;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.deepOrange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.report_problem,
                      color: Colors.amber.shade900,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Incident',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Notify Dispatch & Fleet Supervisors',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
              const SizedBox(height: 16),
              const Text(
                'Incident Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Severity Level',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _severities.map((severity) {
                  final isSelected = _selectedSeverity == severity;
                  final color = _severityColor(severity);
                  return ChoiceChip(
                    label: Text(severity),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: isSelected ? color : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? color : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSeverity = severity);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description & Notes',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe what happened, current location landmarks, assistance required...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _photoAttached = !_photoAttached;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _photoAttached ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _photoAttached ? Colors.green.shade300 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _photoAttached ? Icons.check_circle : Icons.camera_alt_outlined,
                        color: _photoAttached ? Colors.green.shade700 : Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _photoAttached
                              ? 'Incident Photo Attached (incident_snap.jpg)'
                              : 'Attach Camera Photo / Dashcam Clip',
                          style: TextStyle(
                            fontSize: 13,
                            color: _photoAttached ? Colors.green.shade900 : Colors.black87,
                            fontWeight: _photoAttached ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _severityColor(_selectedSeverity),
                      ),
                      onPressed: () {
                        final summary =
                            '$_selectedCategory ($_selectedSeverity): ${_detailsController.text.trim().isEmpty ? "Dispatched assistance requested" : _detailsController.text.trim()}';
                        Navigator.of(context).pop();
                        widget.onIncidentSubmitted(summary);
                      },
                      child: const Text(
                        'Send Report',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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
