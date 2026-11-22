import 'dart:math';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';

class RingPainter extends CustomPainter {
  final double progress;
  final AppPalette palette;

  const RingPainter({required this.progress, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = Metrics.timerStroke;
    final radius = (size.shortestSide - strokeWidth) / 2;
    const startAngle = -pi / 2;

    final trackPaint = Paint()
      ..color = palette.lineStrong
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: center, radius: radius);

      final glowPaint = AppGlow.ring(palette, strokeWidth: strokeWidth);
      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

      final progressPaint = Paint()
        ..color = palette.brass
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
