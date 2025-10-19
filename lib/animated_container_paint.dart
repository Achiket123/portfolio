// Add this class definition outside your _ScrollVideoPageState
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedContainerPainter extends CustomPainter {
  final bool isLeftSide;
  final double opacity;
  final double containerWidth;
  final double containerHeight;

  AnimatedContainerPainter({
    required this.isLeftSide,
    required this.opacity,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final baseColor = isLeftSide ? Colors.blue : Colors.orange;
    final rect = Rect.fromLTWH(0, 0, containerWidth, containerHeight);
    final borderRadius = BorderRadius.circular(20).toRRect(rect);

    // 1. Draw Box Shadow (Dynamic opacity)
    final shadowPaint =
        Paint()
          ..color = baseColor.withOpacity(0.3 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    // Draw the shadow slightly offset
    canvas.drawRRect(borderRadius.shift(const Offset(0, 3)), shadowPaint);

    // 2. Draw Gradient Background (Dynamic opacity)
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(containerWidth, containerHeight),
      [
        baseColor.withOpacity(0.8 * opacity),
        baseColor.withOpacity(0.4 * opacity),
      ],
    );
    final gradientPaint = Paint()..shader = gradient;
    canvas.drawRRect(borderRadius, gradientPaint);

    // 3. Draw Border (Dynamic opacity)
    final borderPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2 * opacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
    canvas.drawRRect(borderRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedContainerPainter oldDelegate) {
    // Repaint only if the visual properties change
    return oldDelegate.isLeftSide != isLeftSide ||
        oldDelegate.opacity != opacity ||
        oldDelegate.containerWidth != containerWidth ||
        oldDelegate.containerHeight != containerHeight;
  }
}
