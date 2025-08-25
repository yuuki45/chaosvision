import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class MagicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final double? width;
  final double height;
  final Color glowColor;
  final IconData? icon;
  final bool isOutlined;

  const MagicButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.width,
    this.height = 56,
    Color? glowColor,
    this.icon,
    this.isOutlined = false,
  }) : glowColor = glowColor ?? AppColors.primary;

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton>
    with TickerProviderStateMixin {
  late AnimationController _magicCircleController;
  late AnimationController _glowController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // 魔法陣の回転アニメーション
    _magicCircleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // グローの脈動アニメーション
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    // 押下時のスケールアニメーション
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _magicCircleController.dispose();
    _glowController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedBuilder(
            animation: Listenable.merge([_glowController, _magicCircleController]),
            builder: (context, child) {
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // ネオングロー効果
                  boxShadow: [
                    // 内側のグロー
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.4 + _glowController.value * 0.3),
                      blurRadius: 8 + _glowController.value * 4,
                      spreadRadius: 1 + _glowController.value * 2,
                    ),
                    // 外側のグロー
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.2 + _glowController.value * 0.2),
                      blurRadius: 20 + _glowController.value * 10,
                      spreadRadius: 2 + _glowController.value * 3,
                    ),
                    // ホバー時の追加グロー
                    if (_isHovered || _isPressed) ...[
                      BoxShadow(
                        color: widget.glowColor.withValues(alpha: 0.6),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ],
                ),
                child: Stack(
                  children: [
                    // メインボタン
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: widget.isOutlined ? null : widget.gradient,
                        borderRadius: BorderRadius.circular(16),
                        border: widget.isOutlined 
                            ? Border.all(
                                color: widget.glowColor.withValues(alpha: 0.8),
                                width: 2 + _glowController.value,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.isOutlined 
                                    ? widget.glowColor 
                                    : Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: widget.isOutlined 
                                    ? widget.glowColor 
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 背景の魔法陣（低透明度）
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: _magicCircleController.value * 2 * math.pi,
                        child: CustomPaint(
                          painter: MagicCircleButtonPainter(
                            color: widget.glowColor,
                            opacity: 0.1 + _glowController.value * 0.1,
                            isHovered: _isHovered,
                            isPressed: _isPressed,
                          ),
                        ),
                      ),
                    ),
                    
                    // フォアグラウンドの魔法陣（逆回転）
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: -_magicCircleController.value * 1.5 * math.pi,
                        child: CustomPaint(
                          painter: MagicCircleButtonPainter(
                            color: widget.glowColor,
                            opacity: 0.05 + _glowController.value * 0.05,
                            isHovered: _isHovered,
                            isPressed: _isPressed,
                            isInner: true,
                          ),
                        ),
                      ),
                    ),
                    
                    // タップ時のリップルエフェクト
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: widget.glowColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MagicCircleButtonPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final bool isHovered;
  final bool isPressed;
  final bool isInner;

  MagicCircleButtonPainter({
    required this.color,
    required this.opacity,
    this.isHovered = false,
    this.isPressed = false,
    this.isInner = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * (isHovered || isPressed ? 2.0 : 1.0))
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 8;
    
    if (isInner) {
      // 内側の魔法陣（小さめ）
      _drawInnerMagicCircle(canvas, center, maxRadius * 0.6, paint);
    } else {
      // 外側の魔法陣
      _drawOuterMagicCircle(canvas, center, maxRadius * 0.8, paint);
    }
  }

  void _drawOuterMagicCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    // メインの円
    canvas.drawCircle(center, radius, paint);
    
    // 6角形
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final point = Offset(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      if (i == 0) {
        hexPath.moveTo(point.dx, point.dy);
      } else {
        hexPath.lineTo(point.dx, point.dy);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, paint);
    
    // 外側の装飾点
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final point = Offset(
        center.dx + radius * 1.1 * math.cos(angle),
        center.dy + radius * 1.1 * math.sin(angle),
      );
      canvas.drawCircle(point, 1.5, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  void _drawInnerMagicCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    // 内側の円
    canvas.drawCircle(center, radius, paint);
    
    // 三角形
    final trianglePath = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i * math.pi * 2) / 3 - math.pi / 2;
      final point = Offset(
        center.dx + radius * 0.8 * math.cos(angle),
        center.dy + radius * 0.8 * math.sin(angle),
      );
      if (i == 0) {
        trianglePath.moveTo(point.dx, point.dy);
      } else {
        trianglePath.lineTo(point.dx, point.dy);
      }
    }
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);
    
    // 中心の小さな円
    canvas.drawCircle(center, radius * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}