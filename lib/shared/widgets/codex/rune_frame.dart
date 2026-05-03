import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class RuneFrame extends StatefulWidget {
  final double size;
  final bool scanning;
  const RuneFrame({super.key, this.size = 280, this.scanning = false});

  @override
  State<RuneFrame> createState() => _RuneFrameState();
}

class _RuneFrameState extends State<RuneFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didUpdateWidget(covariant RuneFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scanning && !_scan.isAnimating) {
      _scan.repeat();
    } else if (!widget.scanning) {
      _scan.stop();
      _scan.reset();
    }
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.scanning
        ? AppColors.bloodBright
        : AppColors.goldLeaf;
    return SizedBox(
      width: widget.size + 64,
      height: widget.size + 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _kanjiMark(top: 0, char: '北'),
          _kanjiMark(bottom: 0, char: '南'),
          _kanjiMark(left: 0, char: '西'),
          _kanjiMark(right: 0, char: '東'),
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _scan,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RuneFramePainter(
                    color: color,
                    scanning: widget.scanning,
                    sweep: _scan.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _kanjiMark({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String char,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inkDeeper.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.goldTarnish.withValues(alpha: 0.55),
            width: 0.6,
          ),
        ),
        child: Text(
          char,
          style: GoogleFonts.shipporiMincho(
            fontSize: 11,
            color: AppColors.bone.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _RuneFramePainter extends CustomPainter {
  final Color color;
  final bool scanning;
  final double sweep;

  _RuneFramePainter({
    required this.color,
    required this.scanning,
    required this.sweep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hairline = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), hairline);

    final corner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    const tick = 26.0;
    void drawCorner(Offset origin, Offset h, Offset v) {
      canvas.drawLine(origin, origin + h, corner);
      canvas.drawLine(origin, origin + v, corner);
    }

    drawCorner(Offset.zero, const Offset(tick, 0), const Offset(0, tick));
    drawCorner(
      Offset(size.width, 0),
      const Offset(-tick, 0),
      const Offset(0, tick),
    );
    drawCorner(
      Offset(0, size.height),
      const Offset(tick, 0),
      const Offset(0, -tick),
    );
    drawCorner(
      Offset(size.width, size.height),
      const Offset(-tick, 0),
      const Offset(0, -tick),
    );

    final dotFill = Paint()..color = color;
    for (final p in [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      canvas.drawCircle(p, 2.4, dotFill);
    }

    final crosshair = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 0.6;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 14, cy), Offset(cx - 4, cy), crosshair);
    canvas.drawLine(Offset(cx + 4, cy), Offset(cx + 14, cy), crosshair);
    canvas.drawLine(Offset(cx, cy - 14), Offset(cx, cy - 4), crosshair);
    canvas.drawLine(Offset(cx, cy + 4), Offset(cx, cy + 14), crosshair);

    if (scanning) {
      final beamY = sweep * size.height;
      final beam = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, beamY - 1, size.width, 2));
      canvas.drawRect(
        Rect.fromLTWH(0, beamY - 1, size.width, 2),
        beam,
      );
      final glow = Paint()
        ..color = color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRect(
        Rect.fromLTWH(0, beamY - 4, size.width, 8),
        glow,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RuneFramePainter oldDelegate) =>
      oldDelegate.sweep != sweep ||
      oldDelegate.scanning != scanning ||
      oldDelegate.color != color;
}
