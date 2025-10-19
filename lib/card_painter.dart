import 'dart:ui' as ui; // Ensure ui is imported as ui
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CardPainter extends CustomPainter {
  final int index;

  CardPainter(this.index);

  // Define static data here to avoid re-creation on every paint
  static const double cardWidth = 250;
  static const double cardHeight = 100;

  static final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final color = colors[index % colors.length];
    final rect = Rect.fromLTWH(0, 0, cardWidth, cardHeight);
    final borderRadius = BorderRadius.circular(16).toRRect(rect);
    final bounds = rect.deflate(1); // For border inside

    // 1. Draw Box Shadow (using a blur filter for better performance than many Flutter shadows)
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawRRect(
      borderRadius.shift(const Offset(0, 2)),
      shadowPaint,
    ); // Apply a slight shadow offset

    // 2. Draw Gradient Background
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(cardWidth, cardHeight),
      [color.withOpacity(0.8), color.withOpacity(0.4)],
    );
    final gradientPaint = Paint()..shader = gradient;
    canvas.drawRRect(borderRadius, gradientPaint);

    // 3. Draw White Border
    final borderPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
    canvas.drawRRect(borderRadius, borderPaint);

    // NOTE: Text is still drawn using separate widgets for simplicity and text rendering quality.
  }

  @override
  bool shouldRepaint(covariant CardPainter oldDelegate) =>
      oldDelegate.index != index;
}
