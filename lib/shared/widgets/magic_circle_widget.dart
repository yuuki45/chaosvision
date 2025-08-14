import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class MagicCircleWidget extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final bool animate;

  const MagicCircleWidget({
    super.key,
    this.size = 150,
    this.color = AppColors.primary,
    this.strokeWidth = 2.0,
    this.animate = true,
  });

  @override
  State<MagicCircleWidget> createState() => _MagicCircleWidgetState();
}

class _MagicCircleWidgetState extends State<MagicCircleWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.animate) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
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
          // 外側の円
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: MagicCirclePainter(
                    color: widget.color,
                    strokeWidth: widget.strokeWidth,
                    opacity: 1.0,
                    isOuter: true,
                  ),
                ),
              );
            },
          ),
          
          // 内側の円（逆回転）
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_rotationController.value * 1.5 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size * 0.7, widget.size * 0.7),
                  painter: MagicCirclePainter(
                    color: widget.color,
                    strokeWidth: widget.strokeWidth * 0.8,
                    opacity: 0.8,
                    isOuter: false,
                  ),
                ),
              );
            },
          ),
          
          // 中心のグロー効果
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: widget.size * 0.3 * (1 + _pulseController.value * 0.2),
                height: widget.size * 0.3 * (1 + _pulseController.value * 0.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.6 * _pulseController.value),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.1),
                    border: Border.all(
                      color: widget.color.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MagicCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double opacity;
  final bool isOuter;

  MagicCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.opacity,
    required this.isOuter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // メインの円
    canvas.drawCircle(center, radius, paint);

    // ルーン風の装飾
    if (isOuter) {
      _drawOuterDecorations(canvas, center, radius, paint);
    } else {
      _drawInnerDecorations(canvas, center, radius, paint);
    }
  }

  void _drawOuterDecorations(Canvas canvas, Offset center, double radius, Paint paint) {
    final decorationPaint = Paint()
      ..color = color.withOpacity(opacity * 0.7)
      ..strokeWidth = strokeWidth * 0.5
      ..style = PaintingStyle.stroke;

    // 外側の装飾（8個の小さな円）
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final decorCenter = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );
      canvas.drawCircle(decorCenter, 3, decorationPaint);
    }

    // 十字線
    canvas.drawLine(
      Offset(center.dx - radius * 0.8, center.dy),
      Offset(center.dx + radius * 0.8, center.dy),
      decorationPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.8),
      Offset(center.dx, center.dy + radius * 0.8),
      decorationPaint,
    );
  }

  void _drawInnerDecorations(Canvas canvas, Offset center, double radius, Paint paint) {
    final decorationPaint = Paint()
      ..color = color.withOpacity(opacity * 0.6)
      ..strokeWidth = strokeWidth * 0.4
      ..style = PaintingStyle.stroke;

    // 内側の三角形
    final trianglePath = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i * math.pi * 2) / 3 - math.pi / 2;
      final point = Offset(
        center.dx + radius * 0.6 * math.cos(angle),
        center.dy + radius * 0.6 * math.sin(angle),
      );
      if (i == 0) {
        trianglePath.moveTo(point.dx, point.dy);
      } else {
        trianglePath.lineTo(point.dx, point.dy);
      }
    }
    trianglePath.close();
    canvas.drawPath(trianglePath, decorationPaint);

    // 中心点
    canvas.drawCircle(center, 2, decorationPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}