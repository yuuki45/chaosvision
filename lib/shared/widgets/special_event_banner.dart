import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/services/special_event_service.dart';

class SpecialEventBanner extends StatefulWidget {
  final SpecialEvent? event;
  final int? remainingMinutes;

  const SpecialEventBanner({
    super.key,
    required this.event,
    this.remainingMinutes,
  });

  @override
  State<SpecialEventBanner> createState() => _SpecialEventBannerState();
}

class _SpecialEventBannerState extends State<SpecialEventBanner>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _distortionController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _distortionController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _distortionController.dispose();
    super.dispose();
  }

  Color _getEventColor() {
    if (widget.event == null) return AppColors.primary;
    
    switch (widget.event!.type) {
      case SpecialEventType.ultraRareArtifact:
        return const Color(0xFFFFD700); // ゴールド
      case SpecialEventType.dimensionDistortion:
        return const Color(0xFF9C27B0); // パープル
      case SpecialEventType.none:
        return AppColors.primary;
    }
  }

  IconData _getEventIcon() {
    if (widget.event == null) return Icons.star;
    
    switch (widget.event!.type) {
      case SpecialEventType.ultraRareArtifact:
        return Icons.auto_awesome;
      case SpecialEventType.dimensionDistortion:
        return Icons.blur_circular;
      case SpecialEventType.none:
        return Icons.star;
    }
  }

  String _formatRemainingTime() {
    if (widget.remainingMinutes == null) return '';
    
    final minutes = widget.remainingMinutes!;
    if (minutes < 60) {
      return '残り $minutes分';
    } else {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return '残り $hours時間$remainingMins分';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) return const SizedBox.shrink();
    
    final eventColor = _getEventColor();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _distortionController]),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: eventColor.withValues(alpha: _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: eventColor.withValues(alpha: _glowAnimation.value * 0.5),
                blurRadius: 15 * _glowAnimation.value,
                spreadRadius: 3 * _glowAnimation.value,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 背景
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      eventColor.withValues(alpha: 0.1),
                      eventColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
              
              // 次元歪曲エフェクト
              if (widget.event!.type == SpecialEventType.dimensionDistortion)
                Positioned.fill(
                  child: CustomPaint(
                    painter: DistortionEffectPainter(
                      distortionValue: _distortionController.value,
                      color: eventColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              
              // メインコンテンツ
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // イベントアイコン
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: eventColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: eventColor.withValues(alpha: _glowAnimation.value),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getEventIcon(),
                        color: eventColor,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // イベント情報
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event!.name,
                            style: TextStyle(
                              color: eventColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.event!.description,
                            style: TextStyle(
                              color: AppColors.onBackground.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (widget.remainingMinutes != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: eventColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatRemainingTime(),
                                style: TextStyle(
                                  color: eventColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // レア度倍率表示
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: eventColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: eventColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '×${widget.event!.rarityMultiplier.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: eventColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DistortionEffectPainter extends CustomPainter {
  final double distortionValue;
  final Color color;

  DistortionEffectPainter({
    required this.distortionValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 歪曲する波線を描画
    final path = Path();
    final waves = 5;
    final amplitude = 10 * math.sin(distortionValue * 2 * math.pi);
    
    for (int i = 0; i < waves; i++) {
      final y = (size.height / waves) * i + (size.height / waves / 2);
      
      for (double x = 0; x <= size.width; x += 2) {
        final waveY = y + amplitude * math.sin((x / size.width * 4 * math.pi) + (distortionValue * 2 * math.pi));
        
        if (x == 0) {
          path.moveTo(x, waveY);
        } else {
          path.lineTo(x, waveY);
        }
      }
    }
    
    canvas.drawPath(path, paint);
    
    // 歪曲する縦線
    for (int i = 1; i < 4; i++) {
      final x = (size.width / 4) * i;
      final distortion = 5 * math.sin(distortionValue * 3 * math.pi + i);
      
      canvas.drawLine(
        Offset(x + distortion, 0),
        Offset(x - distortion, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}