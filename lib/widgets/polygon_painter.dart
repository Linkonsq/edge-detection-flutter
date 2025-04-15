import 'package:flutter/material.dart';

class PolygonPainter extends CustomPainter {
  final List<Offset> corners;
  static const double CIRCLE_SIZE = 20.0;

  PolygonPainter(this.corners);

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.isEmpty || corners.length != 4) {
      return;
    }

    // Get device pixel ratio to make sure the polygon is drawn correctly on different screens
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;

    // Draw polygon outline
    final paint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Start from the first point
    path.moveTo(
      corners[0].dx / devicePixelRatio,
      corners[0].dy / devicePixelRatio,
    );

    // Connect to remaining points
    for (int i = 1; i < corners.length; i++) {
      path.lineTo(
        corners[i].dx / devicePixelRatio,
        corners[i].dy / devicePixelRatio,
      );
    }

    // Close the path
    path.close();

    canvas.drawPath(path, paint);

    // Draw circles at corners with shadow effect
    final circlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Draw shadow for each corner
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    for (final corner in corners) {
      final adjustedCorner = Offset(
        corner.dx / devicePixelRatio,
        corner.dy / devicePixelRatio,
      );

      // Draw shadow first
      canvas.drawCircle(adjustedCorner, CIRCLE_SIZE / 2, shadowPaint);

      // Then draw white circle
      canvas.drawCircle(adjustedCorner, CIRCLE_SIZE / 2, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PolygonPainter oldDelegate) =>
      oldDelegate.corners != corners;
}
