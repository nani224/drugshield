import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum ReticleLockState {
  searching, // 🔴 Crimson: <4 markers
  adjusting, // 🟡 Amber: markers visible, but tilt > 3° or lux < 150
  locked,    // 🟢 Cyan/Emerald: Planar lock confirmed (< 3° tilt, > 150 Lux, 4 markers)
}

class HudReticlePainter extends CustomPainter {
  final ReticleLockState lockState;
  final double tiltDeg;
  final double lux;
  final double autoCaptureProgress; // 0.0 to 1.0
  final List<Offset> markerCorners; // 4 corners if detected

  HudReticlePainter({
    required this.lockState,
    required this.tiltDeg,
    required this.lux,
    required this.autoCaptureProgress,
    required this.markerCorners,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stateColor = _getStateColor();

    // 1. Draw Tactical Bounding Brackets for Pouch
    _drawCornerBrackets(canvas, size, stateColor);

    // 2. Draw Center Targeting Reticle Crosshair
    _drawCenterReticle(canvas, size, stateColor);

    // 3. Draw Auto-Capture Circular Countdown Ring
    if (lockState == ReticleLockState.locked && autoCaptureProgress > 0) {
      _drawAutoCaptureRing(canvas, size);
    }
  }

  Color _getStateColor() {
    switch (lockState) {
      case ReticleLockState.searching:
        return DSColors.accentCrimson;
      case ReticleLockState.adjusting:
        return DSColors.accentAmber;
      case ReticleLockState.locked:
        return DSColors.hudCyan;
    }
  }

  void _drawCornerBrackets(Canvas canvas, Size size, Color color) {
    final bracketPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Bounding box dimensions for drug test pouch
    final boxW = size.width * 0.82;
    final boxH = size.height * 0.52;
    final left = (size.width - boxW) / 2;
    final top = size.height * 0.18;
    final right = left + boxW;
    final bottom = top + boxH;

    const armLen = 32.0;

    void drawCorner(Offset corner, Offset hArm, Offset vArm) {
      final path = Path()
        ..moveTo(corner.dx + hArm.dx, corner.dy + hArm.dy)
        ..lineTo(corner.dx, corner.dy)
        ..lineTo(corner.dx + vArm.dx, corner.dy + vArm.dy);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, bracketPaint);
    }

    // Top-Left (ARUCO #1)
    drawCorner(Offset(left, top), const Offset(armLen, 0), const Offset(0, armLen));
    // Top-Right (ARUCO #2)
    drawCorner(Offset(right, top), const Offset(-armLen, 0), const Offset(0, armLen));
    // Bottom-Right (ARUCO #3)
    drawCorner(Offset(right, bottom), const Offset(-armLen, 0), const Offset(0, -armLen));
    // Bottom-Left (ARUCO #4)
    drawCorner(Offset(left, bottom), const Offset(armLen, 0), const Offset(0, -armLen));

    // Draw Dashed Bounding Guides between brackets
    final dashPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, Offset(left + armLen, top), Offset(right - armLen, top), dashPaint);
    _drawDashedLine(canvas, Offset(right, top + armLen), Offset(right, bottom - armLen), dashPaint);
    _drawDashedLine(canvas, Offset(right - armLen, bottom), Offset(left + armLen, bottom), dashPaint);
    _drawDashedLine(canvas, Offset(left, bottom - armLen), Offset(left, top + armLen), dashPaint);

    // Corner Label Badges
    _drawText(canvas, 'ARUCO #1 (TL)', Offset(left + 6, top + 8), color);
    _drawText(canvas, 'ARUCO #2 (TR)', Offset(right - 80, top + 8), color);
    _drawText(canvas, 'ARUCO #4 (BL)', Offset(left + 6, bottom - 20), color);
    _drawText(canvas, 'ARUCO #3 (BR)', Offset(right - 80, bottom - 20), color);
  }

  void _drawCenterReticle(Canvas canvas, Size size, Color color) {
    final cx = size.width / 2;
    final cy = size.height * 0.44;

    final reticlePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Crosshair arms
    const crossSize = 16.0;
    canvas.drawLine(Offset(cx - crossSize, cy), Offset(cx - 5, cy), reticlePaint);
    canvas.drawLine(Offset(cx + 5, cy), Offset(cx + crossSize, cy), reticlePaint);
    canvas.drawLine(Offset(cx, cy - crossSize), Offset(cx, cy - 5), reticlePaint);
    canvas.drawLine(Offset(cx, cy + 5), Offset(cx, cy + crossSize), reticlePaint);

    // Center aiming circle
    canvas.drawCircle(Offset(cx, cy), 28, reticlePaint);

    // Horizon Tilt & Ambient Light Status Text below center
    final tiltStatus = tiltDeg <= 3.0 ? '[OK]' : '[TILT > 3°]';
    final tiltColor = tiltDeg <= 3.0 ? DSColors.hudCyan : DSColors.accentAmber;
    _drawText(
      canvas,
      'Horizon Tilt: ${tiltDeg.toStringAsFixed(1)}° $tiltStatus',
      Offset(cx - 72, cy + 44),
      tiltColor,
      fontSize: 12,
    );

    final luxStatus = lux >= 150 ? '[OK]' : '[LOW LIGHT]';
    final luxColor = lux >= 150 ? DSColors.hudCyan : DSColors.accentAmber;
    _drawText(
      canvas,
      'Ambient Light: ${lux.toInt()} Lux $luxStatus',
      Offset(cx - 68, cy + 64),
      luxColor,
      fontSize: 12,
    );
  }

  void _drawAutoCaptureRing(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.44;

    final trackPaint = Paint()
      ..color = DSColors.surfaceBorder.withOpacity(0.5)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy), 38, trackPaint);

    final sweepPaint = Paint()
      ..color = DSColors.accentEmerald
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = 2 * pi * autoCaptureProgress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 38),
      -pi / 2,
      sweepAngle,
      false,
      sweepPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 6.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final count = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < count; ++i) {
      final t1 = (i * (dashWidth + dashSpace)) / distance;
      final t2 = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;
      canvas.drawLine(
        Offset(p1.dx + dx * t1, p1.dy + dy * t1),
        Offset(p1.dx + dx * t2, p1.dy + dy * t2),
        paint,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 10,
  }) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant HudReticlePainter oldDelegate) {
    return oldDelegate.lockState != lockState ||
        oldDelegate.tiltDeg != tiltDeg ||
        oldDelegate.lux != lux ||
        oldDelegate.autoCaptureProgress != autoCaptureProgress ||
        oldDelegate.markerCorners != markerCorners;
  }
}
