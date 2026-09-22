import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

/// Modal bottom sheet or dialog simulating authentic biometric authentication
/// Supports Fingerprint scanner, Face Identification, or Both.
class BiometricAuthDialog extends StatefulWidget {
  final String email;
  final String? userName;
  final String? roleName;

  const BiometricAuthDialog({
    super.key,
    required this.email,
    this.userName,
    this.roleName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String email,
    String? userName,
    String? roleName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BiometricAuthDialog(
        email: email,
        userName: userName,
        roleName: roleName,
      ),
    );
  }

  @override
  State<BiometricAuthDialog> createState() => _BiometricAuthDialogState();
}

class _BiometricAuthDialogState extends State<BiometricAuthDialog>
    with SingleTickerProviderStateMixin {
  late BiometricScanMode _activeMode;
  bool _isAuthenticating = false;
  bool _isSuccess = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final bio = BiometricService.instance;
    // Default to fingerprint if available, otherwise face
    if (bio.hasFingerprint) {
      _activeMode = BiometricScanMode.fingerprint;
    } else {
      _activeMode = BiometricScanMode.face;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _simulateScan() async {
    if (_isAuthenticating || _isSuccess) return;

    _animController.stop();
    setState(() {
      _isAuthenticating = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bio = BiometricService.instance;
    final displayName = widget.userName ?? widget.email;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 25,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _activeMode == BiometricScanMode.fingerprint
                      ? Icons.fingerprint_rounded
                      : Icons.face_rounded,
                  color: const Color(0xFF0E3352),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _activeMode == BiometricScanMode.fingerprint
                      ? 'Biometric Fingerprint Scan'
                      : 'Face Identification Scan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in for $displayName',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Sensor mode switcher if both available on device
            if (bio.hasBoth) ...[
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSensorTab(
                        mode: BiometricScanMode.fingerprint,
                        label: 'Fingerprint',
                        icon: Icons.fingerprint_rounded,
                      ),
                    ),
                    Expanded(
                      child: _buildSensorTab(
                        mode: BiometricScanMode.face,
                        label: 'Face ID',
                        icon: Icons.face_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Biometric Animation & Touch Area
            GestureDetector(
              onTap: _simulateScan,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (ctx, child) {
                  return Transform.scale(
                    scale: _isSuccess ? 1.1 : _scaleAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSuccess
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFF0E3352).withValues(alpha: 0.08),
                        border: Border.all(
                          color: _isSuccess
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0E3352).withValues(alpha: 0.3),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: _isSuccess
                            ? const Icon(
                                Icons.check_circle_rounded,
                                size: 54,
                                color: Color(0xFF10B981),
                              )
                            : _isAuthenticating
                                ? const SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0E3352),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _activeMode == BiometricScanMode.fingerprint
                                        ? Icons.fingerprint_rounded
                                        : Icons.face_retouching_natural_rounded,
                                    size: 54,
                                    color: const Color(0xFF0E3352),
                                  ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _isSuccess
                  ? 'Biometric Verified!'
                  : _isAuthenticating
                      ? 'Verifying identity...'
                      : _activeMode == BiometricScanMode.fingerprint
                          ? 'Touch sensor to verify fingerprint'
                          : 'Look at camera for Face ID scan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isSuccess
                    ? const Color(0xFF10B981)
                    : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the icon above to authenticate immediately',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF94A3B8),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Use Password Instead',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _simulateScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E3352),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Verify Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTab({
    required BiometricScanMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _activeMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMode = mode;
          _isAuthenticating = false;
          _isSuccess = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF0E3352) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0E3352) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
