import 'package:flutter/material.dart';

class PolygonPainter extends CustomPainter {
  final List<Offset> corners;

  PolygonPainter(this.corners);

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    final paint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(corners[0].dx, corners[0].dy)
          ..lineTo(corners[1].dx, corners[1].dy)
          ..lineTo(corners[2].dx, corners[2].dy)
          ..lineTo(corners[3].dx, corners[3].dy)
          ..close();

    canvas.drawPath(path, paint);

    // Draw circles at corners
    final circlePaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    for (final corner in corners) {
      canvas.drawCircle(corner, 10.0, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
