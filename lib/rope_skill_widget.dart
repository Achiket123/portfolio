import 'dart:ui';
import 'package:flutter/material.dart';

/// ----------------- SKILL BUTTON WIDGET -----------------
class SkillButton extends StatelessWidget {
  final String text;
  final double opacity;
  final double scale;

  const SkillButton({
    super.key, // Added key for completeness
    required this.text,
    required this.opacity,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        // 💡 Change ElevatedButton to TextButton for a flatter look
        // Or keep ElevatedButton and apply aggressive styling:
        child: ElevatedButton(
          onPressed: () {
            debugPrint('$text clicked');
          },
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0.0),

            backgroundColor: WidgetStateProperty.all(
              Colors.white.withOpacity(0.15),
            ),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),

            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.5 * opacity),
                  width: 1,
                ),
              ),
            ),
            // 4. Set shadowColor to transparent to eliminate residual shadows
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            // 5. Explicitly set surfaceTintColor to transparent (can interfere with shape)
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(opacity),
            ),
          ),
        ),
      ),
    );
  }
}

/// ----------------- ROPE PAINTER -----------------
class RopePainter extends CustomPainter {
  final List<Offset> points;
  final bool isLeftSide;

  RopePainter(this.points, this.isLeftSide);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint =
        Paint()
          ..color = Colors.grey.shade600.withOpacity(0.8)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    // Draw the rope by connecting the calculated points
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw hanging knots/circles (optional)
    final knotPaint =
        Paint()
          ..color = Colors.brown.shade800
          ..style = PaintingStyle.fill;

    // Draw a small knot near each button position (e.g., every 5th point)
    for (int i = 0; i < points.length; i += 5) {
      canvas.drawCircle(points[i], 3.0, knotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RopePainter oldDelegate) =>
      oldDelegate.points != points;
}
