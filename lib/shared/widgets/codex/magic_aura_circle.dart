import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../magic_circle_widget.dart';

class MagicAuraCircle extends StatefulWidget {
  final double size;
  const MagicAuraCircle({super.key, this.size = 280});

  @override
  State<MagicAuraCircle> createState() => _MagicAuraCircleState();
}

class _MagicAuraCircleState extends State<MagicAuraCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _aura;

  @override
  void initState() {
    super.initState();
    _aura = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _aura,
            builder: (context, _) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _AuraPainter(pulse: _aura.value),
              );
            },
          ),
          MagicCircleWidget(
            size: widget.size * 0.55,
            color: AppColors.goldLeaf,
            strokeWidth: 1.4,
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CornerSigilsPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  final double pulse;
  _AuraPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    final outer = Paint()
      ..color = AppColors.goldTarnish.withValues(alpha: 0.18 + 0.08 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
    canvas.drawCircle(center, maxR * 0.95, outer);

    final outer2 = Paint()
      ..color = AppColors.goldTarnish.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, maxR * 0.86, outer2);

    final glow = Paint()
      ..color = AppColors.bloodBright.withValues(alpha: 0.12 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(center, maxR * 0.5, glow);

    final dashPaint = Paint()
      ..color = AppColors.bone.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    const dashCount = 64;
    for (int i = 0; i < dashCount; i++) {
      final a = (i / dashCount) * math.pi * 2;
      final inner = Offset(
        center.dx + maxR * 0.78 * math.cos(a),
        center.dy + maxR * 0.78 * math.sin(a),
      );
      final outerPt = Offset(
        center.dx + maxR * 0.81 * math.cos(a),
        center.dy + maxR * 0.81 * math.sin(a),
      );
      canvas.drawLine(inner, outerPt, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuraPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

class _CornerSigilsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldLeaf.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = AppColors.goldLeaf.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2) * i - math.pi / 2;
      final pos = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawCircle(pos, 4, paint);
      canvas.drawCircle(pos, 1.5, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerSigilsPainter oldDelegate) => false;
}
