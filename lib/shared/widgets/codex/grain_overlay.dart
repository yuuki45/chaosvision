import 'dart:math' as math;
import 'package:flutter/material.dart';

class GrainOverlay extends StatelessWidget {
  final double opacity;
  final int density;

  const GrainOverlay({
    super.key,
    this.opacity = 0.06,
    this.density = 1800,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GrainPainter(opacity: opacity, density: density),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  final int density;
  final math.Random _rng = math.Random(7);

  _GrainPainter({required this.opacity, required this.density});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < density; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final brightness = _rng.nextDouble();
      final radius = _rng.nextDouble() * 0.7 + 0.2;
      paint.color = (brightness > 0.5
              ? const Color(0xFFE8DCC4)
              : const Color(0xFF000000))
          .withValues(alpha: opacity * (0.4 + _rng.nextDouble() * 0.6));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
