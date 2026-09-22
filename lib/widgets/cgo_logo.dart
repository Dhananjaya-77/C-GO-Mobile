import 'package:flutter/material.dart';

/// Renders the official CGO SECURE TRANSIT circular emblem from SRS Figures 8 & 9.
/// Uses the asset image if available, with a high-fidelity vector fallback.
class CgoLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const CgoLogo({
    super.key,
    this.size = 110,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF0D3B66),
          width: size * 0.025,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0D3B66).withValues(alpha: 0.18),
                  blurRadius: size * 0.15,
                  offset: Offset(0, size * 0.05),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.03),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/1.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildVectorEmblem(size);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVectorEmblem(double s) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF0F3A60),
            Color(0xFF061A2D),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(s * 0.05),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF38BDF8),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                color: const Color(0xFF38BDF8),
                size: s * 0.32,
              ),
            ),
            SizedBox(height: s * 0.02),
            Text(
              'CGO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: s * 0.12,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'SECURE TRANSIT',
              style: TextStyle(
                color: const Color(0xFF38BDF8),
                fontWeight: FontWeight.w600,
                fontSize: s * 0.065,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
