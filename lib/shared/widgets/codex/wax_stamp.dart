import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class WaxStamp extends StatelessWidget {
  final String label;
  final String? sublabel;
  final Color color;
  final double size;
  final double tilt;

  const WaxStamp({
    super.key,
    required this.label,
    this.sublabel,
    required this.color,
    this.size = 78,
    this.tilt = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArchiveSigilPainter(color: color),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.18,
                vertical: size * 0.12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.shipporiMincho(
                      fontSize: label.length > 2 ? size * 0.22 : size * 0.32,
                      color: AppColors.bone,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  if (sublabel != null) ...[
                    SizedBox(height: size * 0.06),
                    Container(
                      width: size * 0.32,
                      height: 0.6,
                      color: color.withValues(alpha: 0.7),
                    ),
                    SizedBox(height: size * 0.05),
                    Text(
                      sublabel!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: size * 0.1,
                        color: color.withValues(alpha: 0.95),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveSigilPainter extends CustomPainter {
  final Color color;

  _ArchiveSigilPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    final outerHex = _hexPath(center, r);
    final midHex = _hexPath(center, r * 0.86);
    final innerHex = _hexPath(center, r * 0.7);

    // Subtle drop shadow (offset down)
    canvas.save();
    canvas.translate(0, 2);
    final shadow = Paint()
      ..color = AppColors.inkDeeper.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(outerHex, shadow);
    canvas.restore();

    // Inkblack fill
    final fill = Paint()
      ..color = AppColors.inkBlack.withValues(alpha: 0.94);
    canvas.drawPath(outerHex, fill);

    // Faint accent tint
    final tint = Paint()..color = color.withValues(alpha: 0.1);
    canvas.drawPath(outerHex, tint);

    // Outer hex border (rarity color, slightly bold)
    final outerStroke = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(outerHex, outerStroke);

    // Mid hex (gold tarnish hairline)
    final midStroke = Paint()
      ..color = AppColors.goldTarnish.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawPath(midHex, midStroke);

    // Inner hex (rarity color, very faint)
    final innerStroke = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(innerHex, innerStroke);

    // Vertex dots
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2 - math.pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + r * math.cos(a),
          center.dy + r * math.sin(a),
        ),
        2.0,
        dotPaint,
      );
    }

    // Edge tick marks (mid-edges)
    final tickPaint = Paint()
      ..color = AppColors.goldTarnish.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int i = 0; i < 6; i++) {
      final a = ((i + 0.5) / 6) * math.pi * 2 - math.pi / 2;
      final inner = Offset(
        center.dx + r * 0.94 * math.cos(a),
        center.dy + r * 0.94 * math.sin(a),
      );
      final outer = Offset(
        center.dx + r * 1.04 * math.cos(a),
        center.dy + r * 1.04 * math.sin(a),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  Path _hexPath(Offset center, double radius) {
    final p = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2 - math.pi / 2;
      final pt = Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      );
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant _ArchiveSigilPainter oldDelegate) =>
      oldDelegate.color != color;
}
