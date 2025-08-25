import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class SealedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final double? width;
  final double height;
  final Color glowColor;
  final IconData? icon;
  final bool isOutlined;

  const SealedButton({
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
  State<SealedButton> createState() => _SealedButtonState();
}

class _SealedButtonState extends State<SealedButton>
    with TickerProviderStateMixin {
  late AnimationController _runeController;
  late AnimationController _glowController;
  late AnimationController _pressController;
  late AnimationController _sealController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sealBreakAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // ルーン文字の回転アニメーション
    _runeController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    
    // グローの脈動アニメーション
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // 押下時のスケールアニメーション
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 封印解除エフェクトアニメーション
    _sealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    _sealBreakAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sealController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _runeController.dispose();
    _glowController.dispose();
    _pressController.dispose();
    _sealController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _pressController.forward();
    _sealController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _sealController.reverse();
    });
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _sealController.reverse();
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
            animation: Listenable.merge([
              _glowController, 
              _runeController, 
              _sealBreakAnimation
            ]),
            builder: (context, child) {
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // 封印解除時のグロー効果
                  boxShadow: [
                    // ベースグロー
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.3 + _glowController.value * 0.2),
                      blurRadius: 12 + _glowController.value * 6,
                      spreadRadius: 2 + _glowController.value * 2,
                    ),
                    // 封印解除エフェクト
                    if (_sealBreakAnimation.value > 0) ...[
                      BoxShadow(
                        color: widget.glowColor.withValues(alpha: 0.6 * _sealBreakAnimation.value),
                        blurRadius: 30 * _sealBreakAnimation.value,
                        spreadRadius: 8 * _sealBreakAnimation.value,
                      ),
                    ],
                    // ホバー時の追加グロー
                    if (_isHovered) ...[
                      BoxShadow(
                        color: widget.glowColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
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
                            : Border.all(
                                color: widget.glowColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
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
                    
                    // ルーン文字装飾（四隅）
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: _runeController.value * 2 * math.pi,
                        child: CustomPaint(
                          painter: RuneDecorationPainter(
                            color: widget.glowColor,
                            opacity: 0.4 + _glowController.value * 0.3,
                            isHovered: _isHovered,
                            isPressed: _isPressed,
                            sealBreakProgress: _sealBreakAnimation.value,
                          ),
                        ),
                      ),
                    ),
                    
                    // 封印解除エフェクト（クラック）
                    if (_sealBreakAnimation.value > 0)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SealBreakPainter(
                            color: widget.glowColor,
                            progress: _sealBreakAnimation.value,
                          ),
                        ),
                      ),
                    
                    // タップ時のリップルエフェクト
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: widget.glowColor.withValues(alpha: 0.15),
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

class RuneDecorationPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final bool isHovered;
  final bool isPressed;
  final double sealBreakProgress;

  RuneDecorationPainter({
    required this.color,
    required this.opacity,
    this.isHovered = false,
    this.isPressed = false,
    this.sealBreakProgress = 0.0,
  });

  // 古代ルーン文字
  final List<String> _runeSymbols = [
    'ᚠ', 'ᚢ', 'ᚦ', 'ᚨ', 'ᚱ', 'ᚲ', 'ᚷ', 'ᚹ'
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * (isHovered || isPressed ? 1.5 : 1.0))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    
    // 外周の装飾円
    canvas.drawCircle(center, radius * 0.85, paint);
    
    // 四隅のルーン文字
    final corners = [
      Offset(16, 16), // 左上
      Offset(size.width - 16, 16), // 右上
      Offset(16, size.height - 16), // 左下
      Offset(size.width - 16, size.height - 16), // 右下
    ];
    
    for (int i = 0; i < corners.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: _runeSymbols[i % _runeSymbols.length],
          style: TextStyle(
            color: color.withValues(alpha: opacity * (isHovered || isPressed ? 1.5 : 1.0)),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          corners[i].dx - textPainter.width / 2,
          corners[i].dy - textPainter.height / 2,
        ),
      );
    }
    
    // 中央の封印陣
    _drawSealCircle(canvas, center, radius * 0.4, paint);
  }

  void _drawSealCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    // 内側の円
    canvas.drawCircle(center, radius, paint);
    
    // 封印の十字線
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    
    // 中心点
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 2, paint);
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SealBreakPainter extends CustomPainter {
  final Color color;
  final double progress;

  SealBreakPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final maxLength = math.min(size.width, size.height) / 2;
    
    // 封印解除のクラック（放射状）
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final length = maxLength * progress * (0.5 + math.sin(progress * math.pi) * 0.5);
      
      final end = Offset(
        center.dx + length * math.cos(angle),
        center.dy + length * math.sin(angle),
      );
      
      canvas.drawLine(center, end, paint);
      
      // クラックの先端に小さな爆発エフェクト
      if (progress > 0.5) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(end, 2 * progress, paint);
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}