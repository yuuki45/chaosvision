import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class RuneButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final double? width;
  final double height;
  final Color glowColor;
  final IconData? icon;
  final bool isOutlined;

  const RuneButton({
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
  State<RuneButton> createState() => _RuneButtonState();
}

class _RuneButtonState extends State<RuneButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  // 古代ルーン文字
  final List<String> _runeSymbols = [
    'ᚠ', 'ᚢ', 'ᚦ', 'ᚨ', 'ᚱ', 'ᚲ', 'ᚷ', 'ᚹ', 'ᚺ', 'ᚾ', 'ᛁ', 'ᛃ'
  ];

  @override
  void initState() {
    super.initState();
    
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

  String _getRandomRune() {
    return _runeSymbols[(DateTime.now().millisecondsSinceEpoch ~/ 100) % _runeSymbols.length];
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
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.isOutlined ? null : widget.gradient,
              borderRadius: BorderRadius.circular(16),
              border: widget.isOutlined 
                  ? Border.all(
                      color: widget.glowColor.withOpacity(0.8),
                      width: 2,
                    )
                  : Border.all(
                      color: widget.glowColor.withOpacity(0.2),
                      width: 1,
                    ),
              // ソフトなグロー効果
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(_isHovered ? 0.3 : 0.15),
                  blurRadius: _isHovered ? 15 : 10,
                  spreadRadius: _isHovered ? 3 : 1,
                ),
                // タップ時の追加グロー
                if (_isPressed) ...[
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ],
            ),
            child: Stack(
              children: [
                // メインボタンコンテンツ
                Center(
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
                
                // 左端の魔法陣
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(20, 20),
                      painter: MiniMagicCirclePainter(
                        color: widget.isOutlined 
                            ? widget.glowColor.withOpacity(0.6)
                            : Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                
                // 右端の魔法陣
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(20, 20),
                      painter: MiniMagicCirclePainter(
                        color: widget.isOutlined 
                            ? widget.glowColor.withOpacity(0.6)
                            : Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                
                // タップ時のリップルエフェクト
                if (_isPressed)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: widget.glowColor.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MiniMagicCirclePainter extends CustomPainter {
  final Color color;

  MiniMagicCirclePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 1;
    
    // 外側の円
    canvas.drawCircle(center, radius, paint);
    
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
    canvas.drawPath(trianglePath, paint);
    
    // 中心点
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}