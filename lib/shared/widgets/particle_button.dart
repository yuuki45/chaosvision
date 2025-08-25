import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class ParticleButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final double? width;
  final double height;
  final Color particleColor;
  final IconData? icon;
  final bool isOutlined;
  final int particleCount;

  const ParticleButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.width,
    this.height = 56,
    Color? particleColor,
    this.icon,
    this.isOutlined = false,
    this.particleCount = 8,
  }) : particleColor = particleColor ?? AppColors.primary;

  @override
  State<ParticleButton> createState() => _ParticleButtonState();
}

class _ParticleButtonState extends State<ParticleButton>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late List<Particle> _particles;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // 粒子のアニメーション
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
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
    
    _initializeParticles();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        startAngle: (index * 2 * math.pi) / widget.particleCount,
        radius: 30 + random.nextDouble() * 20, // 30-50の範囲
        speed: 0.3 + random.nextDouble() * 0.4, // 0.3-0.7の範囲
        size: 2 + random.nextDouble() * 3, // 2-5の範囲
        opacity: 0.6 + random.nextDouble() * 0.4, // 0.6-1.0の範囲
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
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
          child: SizedBox(
            width: widget.width,
            height: widget.height + 60, // 粒子用の余白
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 浮遊する粒子
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(widget.width ?? 200, widget.height + 60),
                      painter: ParticlePainter(
                        particles: _particles,
                        animationValue: _particleController.value,
                        particleColor: widget.particleColor,
                        isHovered: _isHovered,
                        isPressed: _isPressed,
                        buttonHeight: widget.height,
                      ),
                    );
                  },
                ),
                
                // メインボタン
                Positioned(
                  left: 0,
                  right: 0,
                  top: 30, // 粒子用の余白
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: widget.isOutlined ? null : widget.gradient,
                      borderRadius: BorderRadius.circular(16),
                      border: widget.isOutlined 
                          ? Border.all(
                              color: widget.particleColor.withValues(alpha: 0.8),
                              width: 2,
                            )
                          : Border.all(
                              color: widget.particleColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                      // ソフトなグロー効果
                      boxShadow: [
                        BoxShadow(
                          color: widget.particleColor.withValues(alpha: _isHovered ? 0.3 : 0.15),
                          blurRadius: _isHovered ? 15 : 10,
                          spreadRadius: _isHovered ? 3 : 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isOutlined 
                                  ? widget.particleColor 
                                  : Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.isOutlined 
                                  ? widget.particleColor 
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
                ),
                
                // タップ時のリップルエフェクト
                if (_isPressed)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 30,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: widget.particleColor.withValues(alpha: 0.1),
                      ),
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

class Particle {
  final double startAngle;
  final double radius;
  final double speed;
  final double size;
  final double opacity;

  Particle({
    required this.startAngle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color particleColor;
  final bool isHovered;
  final bool isPressed;
  final double buttonHeight;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.particleColor,
    required this.isHovered,
    required this.isPressed,
    required this.buttonHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, (size.height / 2));
    
    for (final particle in particles) {
      // 粒子の現在位置を計算（楕円軌道）
      final currentAngle = particle.startAngle + (animationValue * particle.speed * 2 * math.pi);
      final radiusX = particle.radius;
      final radiusY = particle.radius * 0.7; // 楕円にする
      
      final x = center.dx + radiusX * math.cos(currentAngle);
      final y = center.dy + radiusY * math.sin(currentAngle);
      
      // 透明度の計算（ホバー時やプレス時に明るくする）
      double opacity = particle.opacity;
      if (isHovered) opacity *= 1.5;
      if (isPressed) opacity *= 2.0;
      
      // 粒子のサイズ（ホバー時に少し大きく）
      double size = particle.size;
      if (isHovered) size *= 1.2;
      if (isPressed) size *= 1.4;
      
      paint.color = particleColor.withValues(alpha: math.min(1.0, opacity));
      
      // 粒子を描画（内側の明るいコアと外側のグロー）
      // 外側のグロー
      paint.color = particleColor.withValues(alpha: math.min(0.3, opacity * 0.5));
      canvas.drawCircle(Offset(x, y), size * 1.5, paint);
      
      // 内側のコア
      paint.color = particleColor.withValues(alpha: math.min(1.0, opacity));
      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}