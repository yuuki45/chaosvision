import 'package:flutter/material.dart';

class ScanlineOverlay extends StatelessWidget {
  final double opacity;
  final double spacing;

  const ScanlineOverlay({
    super.key,
    this.opacity = 0.035,
    this.spacing = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScanlinePainter(opacity: opacity, spacing: spacing),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  final double spacing;

  _ScanlinePainter({required this.opacity, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: opacity)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => false;
}
