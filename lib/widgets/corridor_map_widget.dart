import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CorridorMapWidget extends StatefulWidget {
  final String corridorTitle;
  final String originTitle;
  final String destinationTitle;
  final double progress; // 0.0 to 1.0
  final bool isDeviated;
  final double deviationMeters;
  final int speedKmH;
  final VoidCallback? onToggleDeviation;
  final double height;
  final bool showSrsCallouts;
  final bool showTopStatusOverlay;

  const CorridorMapWidget({
    super.key,
    required this.corridorTitle,
    required this.originTitle,
    required this.destinationTitle,
    required this.progress,
    this.isDeviated = false,
    this.deviationMeters = 0.0,
    this.speedKmH = 42,
    this.onToggleDeviation,
    this.height = 240,
    this.showSrsCallouts = true,
    this.showTopStatusOverlay = true,
  });

  @override
  State<CorridorMapWidget> createState() => _CorridorMapWidgetState();
}

class _CorridorMapWidgetState extends State<CorridorMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDeviated ? AppTheme.tamperRed : AppTheme.slate200,
          width: widget.isDeviated ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Custom Paint GIS Grid, River/Roads, and Corridor
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CorridorPainter(
                    progress: widget.progress,
                    isDeviated: widget.isDeviated,
                    pulseValue: _pulseController.value,
                    showSrsCallouts: widget.showSrsCallouts,
                  ),
                );
              },
            ),
          ),

          // Optional Top Status Overlay (Geofence Corridor compliance)
          if (widget.showTopStatusOverlay)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isDeviated
                      ? AppTheme.tamperRed
                      : AppTheme.navyPrimary.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isDeviated
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.isDeviated
                                ? '🚨 CORRIDOR DEVIATION ALERT (+${widget.deviationMeters.toStringAsFixed(0)}m)'
                                : '🟢 WITHIN CUSTOMS APPROVED CORRIDOR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            widget.corridorTitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.onToggleDeviation != null)
                      InkWell(
                        onTap: widget.onToggleDeviation,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.isDeviated ? 'Restore Route' : 'Simulate Deviation',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Origin & Destination Labels (SRS styled)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.originTitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.securityGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.destinationTitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Speed Overlay Chip
          if (widget.showTopStatusOverlay)
            Positioned(
              right: 12,
              top: 54,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speed_rounded, size: 14, color: AppTheme.customsBlue),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.speedKmH} km/h',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CorridorPainter extends CustomPainter {
  final double progress;
  final bool isDeviated;
  final double pulseValue;
  final bool showSrsCallouts;

  _CorridorPainter({
    required this.progress,
    required this.isDeviated,
    required this.pulseValue,
    required this.showSrsCallouts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle GIS Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFD3DCE3)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw mock water body (Port of Colombo coast) on the left
    final seaPaint = Paint()..color = const Color(0xFFC7DDF2).withValues(alpha: 0.6);
    final seaPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.22, 0)
      ..quadraticBezierTo(size.width * 0.14, size.height * 0.5, size.width * 0.26, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(seaPath, seaPaint);

    // 2b. Secondary roads network (matching Figures 10 and 11)
    final secRoadPaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final roadNet1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.15)
      ..lineTo(size.width * 0.95, size.height * 0.4);
    canvas.drawPath(roadNet1, secRoadPaint);

    final roadNet2 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.85)
      ..lineTo(size.width * 0.8, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.9);
    canvas.drawPath(roadNet2, secRoadPaint);

    // 3. Define the Highway Route Corridor Curve (Origin Katunayake / Port -> Checkpoint -> Destination)
    final p0 = Offset(size.width * 0.16, size.height * 0.68);
    final p1 = Offset(size.width * 0.38, size.height * 0.36);
    final p2 = Offset(size.width * 0.62, size.height * 0.62);
    final p3 = Offset(size.width * 0.88, size.height * 0.34);

    final corridorPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    // 4. Draw Geofence Buffer Corridor (thick blue band)
    final bufferPaint = Paint()
      ..color = isDeviated
          ? AppTheme.tamperRed.withValues(alpha: 0.18)
          : const Color(0xFF2563EB).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(corridorPath, bufferPaint);

    // 5. Draw Primary Navigation Route (Deep Blue Line like in Figure 10 & 11)
    final routeLinePaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(corridorPath, routeLinePaint);

    // 6. Draw Waypoint Circles
    _drawCheckpoint(canvas, p0, 'Katunayake', true);
    _drawCheckpoint(canvas, Offset(size.width * 0.40, size.height * 0.42), 'Peliyagoda', true);
    _drawCheckpoint(canvas, Offset(size.width * 0.64, size.height * 0.58), 'Ingurukade', true);
    _drawCheckpoint(canvas, p3, 'Port Gate 4', false);

    // 7. Draw Segment Time Badges from Figure 10 ("19 min", "18 min", "17 min")
    if (showSrsCallouts) {
      _drawTimeBadge(canvas, Offset(size.width * 0.48, size.height * 0.22), '19 min');
      _drawTimeBadge(canvas, Offset(size.width * 0.52, size.height * 0.45), '18 min');
      _drawTimeBadge(canvas, Offset(size.width * 0.50, size.height * 0.68), '17 min');

      // Road code tag "AC11"
      _drawRoadCode(canvas, Offset(size.width * 0.30, size.height * 0.40), 'AC11');
    }

    // 8. Calculate Vehicle Position on Route based on progress
    final t = progress.clamp(0.0, 1.0);
    final oneMinusT = 1.0 - t;
    final vx = math.pow(oneMinusT, 3) * p0.dx +
        3 * math.pow(oneMinusT, 2) * t * p1.dx +
        3 * oneMinusT * math.pow(t, 2) * p2.dx +
        math.pow(t, 3) * p3.dx;
    var vy = math.pow(oneMinusT, 3) * p0.dy +
        3 * math.pow(oneMinusT, 2) * t * p1.dy +
        3 * oneMinusT * math.pow(t, 2) * p2.dy +
        math.pow(t, 3) * p3.dy;

    // If simulated deviation is active, shift vehicle off the road corridor!
    if (isDeviated) {
      vy -= 42;
    }

    final vehiclePos = Offset(vx, vy);

    // Draw Pulse Ring around truck
    final pulsePaint = Paint()
      ..color = (isDeviated ? AppTheme.tamperRed : const Color(0xFF10B981))
          .withValues(alpha: (1.0 - pulseValue).clamp(0.0, 1.0) * 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehiclePos, 12 + (pulseValue * 16), pulsePaint);

    // Draw Green Truck Pin (as in Figures 10 and 11)
    final truckCirclePaint = Paint()
      ..color = isDeviated ? AppTheme.tamperRed : const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehiclePos, 14, truckCirclePaint);

    final truckBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(vehiclePos, 14, truckBorder);

    // Inner icon symbol
    final iconPaint = Paint()..color = Colors.white;
    canvas.drawCircle(vehiclePos, 4, iconPaint);

    // In Figure 11: Speech Callout "18 min \n 7.3 km"
    if (showSrsCallouts && size.width > 260) {
      _drawTruckCallout(canvas, Offset(vx + 18, vy - 10), '18 min', '7.3 km');
    }

    // If deviated, draw red dotted line from route to deviated vehicle position
    if (isDeviated) {
      final deviationLinePaint = Paint()
        ..color = AppTheme.tamperRed
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(vx, vy + 42), vehiclePos, deviationLinePaint);
    }
  }

  void _drawTimeBadge(Canvas canvas, Offset pos, String timeText) {
    const double w = 52;
    const double h = 20;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: w, height: h),
      const Radius.circular(4),
    );

    final bgPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    final textSpan = TextSpan(
      text: timeText,
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  void _drawRoadCode(Canvas canvas, Offset pos, String code) {
    const double w = 36;
    const double h = 18;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: w, height: h),
      const Radius.circular(4),
    );

    final bgPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRRect(rrect, bgPaint);

    final textSpan = TextSpan(
      text: code,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  void _drawTruckCallout(Canvas canvas, Offset pos, String duration, String distance) {
    const double w = 84;
    const double h = 38;
    final rect = Rect.fromLTWH(pos.dx, pos.dy - h / 2, w, h);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(rrect.shift(const Offset(0, 2)), shadowPaint);

    final bgPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Left green truck circle
    final iconCircle = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(pos.dx + 16, pos.dy), 10, iconCircle);

    // Text: Duration & Distance
    final span = TextSpan(
      children: [
        TextSpan(
          text: '$duration\n',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: distance,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx + 30, pos.dy - tp.height / 2));
  }

  void _drawCheckpoint(Canvas canvas, Offset pos, String label, bool isPassed) {
    final bgPaint = Paint()..color = isPassed ? const Color(0xFF1D4ED8) : Colors.white;
    final borderPaint = Paint()
      ..color = isPassed ? Colors.white : const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(pos, 5, bgPaint);
    canvas.drawCircle(pos, 5, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CorridorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDeviated != isDeviated ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.showSrsCallouts != showSrsCallouts;
  }
}
