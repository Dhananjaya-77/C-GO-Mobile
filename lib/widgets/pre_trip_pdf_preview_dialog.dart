import 'package:flutter/material.dart';
import '../services/pre_trip_pdf_service.dart';
import '../utils/app_theme.dart';

/// Interactive dialog that previews the generated Pre-Trip Clearance PDF
/// containing Container & Smart Lock Info (Container ID, RFID Lock, Seal Status, Weight, Type)
/// and allows saving/downloading the PDF before starting the trip.
class PreTripPdfPreviewDialog extends StatefulWidget {
  final PreTripPdfResult pdfResult;
  final bool startTripAfterConfirm;
  final VoidCallback? onConfirmStartTrip;

  const PreTripPdfPreviewDialog({
    super.key,
    required this.pdfResult,
    this.startTripAfterConfirm = true,
    this.onConfirmStartTrip,
  });

  /// Generates the Pre-Trip PDF via [PreTripPdfService] and immediately displays
  /// the preview/save dialog. Returns `true` if the user confirmed starting the trip.
  static Future<bool> generateAndShow(
    BuildContext context, {
    required String containerId,
    required String rfidLockId,
    String sealStatus = 'Closed',
    String weight = '18,500 kg',
    String containerType = '40ft HC',
    String iotDeviceId = 'ST-ESP32-094',
    String physicalSealNumber = 'CUS-SL-778219',
    String truckModel = 'Volvo FMX 440 Heavy Prime Mover',
    String vehiclePlate = 'WP LY-4821',
    String origin = 'Colombo Fort',
    String destination = 'Orugodawaththa',
    String routeName = 'Colombo Fort to Orugodawaththa',
    String cusDecNumber = 'CD-2026-COL-0842',
    bool startTripAfterConfirm = true,
    VoidCallback? onConfirmStartTrip,
  }) async {
    final result = await PreTripPdfService.instance.generatePreTripPdf(
      containerId: containerId,
      rfidLockId: rfidLockId,
      sealStatus: sealStatus,
      weight: weight,
      containerType: containerType,
      iotDeviceId: iotDeviceId,
      physicalSealNumber: physicalSealNumber,
      truckModel: truckModel,
      vehiclePlate: vehiclePlate,
      origin: origin,
      destination: destination,
      routeName: routeName,
      cusDecNumber: cusDecNumber,
    );

    if (!context.mounted) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PreTripPdfPreviewDialog(
        pdfResult: result,
        startTripAfterConfirm: startTripAfterConfirm,
        onConfirmStartTrip: onConfirmStartTrip,
      ),
    );

    return confirmed ?? false;
  }

  @override
  State<PreTripPdfPreviewDialog> createState() =>
      _PreTripPdfPreviewDialogState();
}

class _PreTripPdfPreviewDialogState extends State<PreTripPdfPreviewDialog> {
  bool _isSavedBannerVisible = true;

  void _handleSavePdf() {
    setState(() {
      _isSavedBannerVisible = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PDF saved: ${widget.pdfResult.fileName} (${widget.pdfResult.fileSizeKb.toStringAsFixed(1)} KB)',
        ),
        backgroundColor: AppTheme.securityGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.pdfResult.data;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Dialog Bar: PDF Viewer Header ──────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E3352), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFFCA5A5),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pre-Trip Clearance PDF Generated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.pdfResult.fileName} • ${widget.pdfResult.fileSizeKb.toStringAsFixed(1)} KB',
                          style: const TextStyle(
                            color: Color(0xFFBAE6FD),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(false),
                    tooltip: 'Close PDF Preview',
                  ),
                ],
              ),
            ),

            // ── Auto-Saved Status Strip ───────────────────────────────────
            if (_isSavedBannerVisible)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFDCFCE7),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF15803D),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PDF Ready & Saved: ${widget.pdfResult.savedFilePath ?? widget.pdfResult.fileName}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF166534),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Scrollable A4 PDF Document Sheet Preview ──────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Official Document Header inside the PDF page
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SRI LANKA CUSTOMS • C GO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF0E3352),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ref: ${data.documentId}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Text(
                              'OFFICIAL PRE-TRIP PDF',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 20),

                      // Primary Section: Container & Smart Lock Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: Color(0xFF1D4ED8),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Container & Smart Lock Info',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPdfField(
                                    label: 'Container ID',
                                    value: data.containerId,
                                    valueColor: const Color(0xFF0F172A),
                                  ),
                                ),
                                Expanded(
                                  child: _buildPdfField(
                                    label: 'Seal Status',
                                    value: data.sealStatus,
                                    valueColor: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPdfField(
                                    label: 'Weight',
                                    value: data.weight,
                                    valueColor: const Color(0xFF0F172A),
                                  ),
                                ),
                                Expanded(
                                  child: _buildPdfField(
                                    label: 'Type',
                                    value: data.containerType,
                                    valueColor: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPdfField(
                                    label: 'Assigned RFID Lock',
                                    value: data.rfidLockId,
                                    valueColor: AppTheme.customsBlue,
                                  ),
                                ),
                                Expanded(
                                  child: _buildPdfField(
                                    label: 'IoT Device & Seal',
                                    value:
                                        '${data.iotDeviceId} • ${data.physicalSealNumber}',
                                    valueColor: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Secondary Summary: Transport & Route
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCompactRow(
                              'Truck & Reg',
                              '${data.truckModel} (${data.vehiclePlate})',
                            ),
                            const SizedBox(height: 6),
                            _buildCompactRow(
                              'Transit Corridor',
                              '${data.origin} -> ${data.destination}',
                            ),
                            const SizedBox(height: 6),
                            _buildCompactRow(
                              'Generated At',
                              data.formattedTimestamp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Actions: Download/Save PDF & Start Trip ────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleSavePdf,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Save PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0E3352),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        widget.onConfirmStartTrip?.call();
                      },
                      icon: Icon(
                        widget.startTripAfterConfirm
                            ? Icons.play_arrow_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                      label: Text(
                        widget.startTripAfterConfirm
                            ? 'Confirm & Start Trip'
                            : 'Done',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfField({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
