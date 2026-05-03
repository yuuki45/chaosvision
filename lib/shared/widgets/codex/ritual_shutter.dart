import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RitualShutter extends StatefulWidget {
  final bool busy;
  final VoidCallback? onPressed;

  const RitualShutter({super.key, required this.busy, required this.onPressed});

  @override
  State<RitualShutter> createState() => _RitualShutterState();
}

class _RitualShutterState extends State<RitualShutter>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _busy;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _busy = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didUpdateWidget(covariant RitualShutter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busy && !_busy.isAnimating) {
      _busy.repeat();
    } else if (!widget.busy) {
      _busy.stop();
      _busy.reset();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _busy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.busy ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _busy]),
        builder: (context, _) {
          return SizedBox(
            width: 108,
            height: 108,
            child: CustomPaint(
              painter: _ShutterPainter(
                pulse: _idle.value,
                spin: _busy.value,
                busy: widget.busy,
                pressed: _pressed,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShutterPainter extends CustomPainter {
  final double pulse;
  final double spin;
  final bool busy;
  final bool pressed;

  _ShutterPainter({
    required this.pulse,
    required this.spin,
    required this.busy,
    required this.pressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final accent =
        busy ? AppColors.bloodBright : AppColors.goldLeaf;

    // Outer ring (faded glow)
    final glow = Paint()
      ..color = accent.withValues(alpha: 0.18 + 0.18 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, maxR * 0.78, glow);

    // Outer hairline ring with rotating dashes
    final dashPaint = Paint()
      ..color = AppColors.bone.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final outerR = maxR * 0.92;
    final rotation = busy ? spin * math.pi * 2 : 0.0;
    const dashCount = 36;
    for (int i = 0; i < dashCount; i++) {
      final a = rotation + (i / dashCount) * math.pi * 2;
      final p1 = Offset(
        center.dx + outerR * math.cos(a),
        center.dy + outerR * math.sin(a),
      );
      final p2 = Offset(
        center.dx + (outerR - 4) * math.cos(a),
        center.dy + (outerR - 4) * math.sin(a),
      );
      canvas.drawLine(p1, p2, dashPaint);
    }

    // Main ring
    final ring = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, maxR * 0.72, ring);

    // Inner solid disc
    final disc = Paint()
      ..color = busy
          ? AppColors.blood.withValues(alpha: 0.55)
          : AppColors.inkBlack.withValues(alpha: 0.85);
    canvas.drawCircle(center, maxR * 0.58, disc);

    // Pressed inset
    if (pressed) {
      canvas.drawCircle(
        center,
        maxR * 0.58,
        Paint()..color = Colors.white.withValues(alpha: 0.06),
      );
    }

    // Eye sigil — center
    final innerR = maxR * 0.58;
    _drawEye(canvas, center, innerR, accent);

    // Petals around inner ring
    final petalPaint = Paint()
      ..color = accent.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const petalCount = 6;
    for (int i = 0; i < petalCount; i++) {
      final a = (i / petalCount) * math.pi * 2 - math.pi / 2 + rotation * 0.5;
      final p1 = Offset(
        center.dx + innerR * 1.05 * math.cos(a),
        center.dy + innerR * 1.05 * math.sin(a),
      );
      final p2 = Offset(
        center.dx + innerR * 1.18 * math.cos(a),
        center.dy + innerR * 1.18 * math.sin(a),
      );
      canvas.drawLine(p1, p2, petalPaint);
      canvas.drawCircle(p2, 1.6, petalPaint..style = PaintingStyle.fill);
      petalPaint.style = PaintingStyle.stroke;
    }
  }

  void _drawEye(Canvas canvas, Offset center, double innerR, Color accent) {
    final eyeWidth = innerR * 1.05;
    final eyeHeight = innerR * 0.55;
    final outline = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(center.dx - eyeWidth / 2, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy - eyeHeight,
        center.dx + eyeWidth / 2,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + eyeHeight,
        center.dx - eyeWidth / 2,
        center.dy,
      )
      ..close();
    canvas.drawPath(path, outline);

    // Iris
    final irisR = eyeHeight * 0.78;
    canvas.drawCircle(
      center,
      irisR,
      Paint()..color = accent.withValues(alpha: busy ? 0.85 : 0.55),
    );
    // Pupil
    canvas.drawCircle(
      center,
      irisR * 0.45,
      Paint()..color = AppColors.inkDeeper,
    );
    // Sparkle
    canvas.drawCircle(
      Offset(center.dx + irisR * 0.25, center.dy - irisR * 0.25),
      irisR * 0.15,
      Paint()..color = AppColors.bone,
    );
  }

  @override
  bool shouldRepaint(covariant _ShutterPainter oldDelegate) =>
      oldDelegate.pulse != pulse ||
      oldDelegate.spin != spin ||
      oldDelegate.busy != busy ||
      oldDelegate.pressed != pressed;
}
