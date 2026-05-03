import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'wax_stamp.dart';

class CodexImageFrame extends StatelessWidget {
  final Future<String?> imagePathFuture;
  final Color accent;
  final String? rarityLabel;
  final Color? rarityColor;
  final double aspectRatio;

  const CodexImageFrame({
    super.key,
    required this.imagePathFuture,
    required this.accent,
    this.rarityLabel,
    this.rarityColor,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.inkBlack.withValues(alpha: 0.7),
                border: Border.all(
                  color: accent.withValues(alpha: 0.5),
                  width: 0.7,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.goldTarnish.withValues(alpha: 0.6),
                    width: 0.6,
                  ),
                ),
                child: ClipRect(
                  child: FutureBuilder<String?>(
                    future: imagePathFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container(
                          color: AppColors.inkDeeper,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.boneDim,
                            size: 32,
                          ),
                        );
                      }
                      return Image.file(
                        File(snapshot.data!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.inkDeeper,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.boneDim,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _BracketPainter(color: accent)),
            ),
          ),
          if (rarityLabel != null && rarityColor != null)
            Positioned(
              top: 12,
              right: 12,
              child: WaxStamp(
                label: rarityLabel!,
                sublabel: 'SIGIL',
                color: rarityColor!,
                size: 72,
              ),
            ),
          Positioned(
            left: 10,
            bottom: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: AppColors.inkDeeper.withValues(alpha: 0.7),
              child: const Text(
                'PROOF.JPG',
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: AppColors.boneDim,
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    const tick = 22.0;
    void corner(Offset o, Offset h, Offset v) {
      canvas.drawLine(o, o + h, paint);
      canvas.drawLine(o, o + v, paint);
    }

    corner(Offset.zero, const Offset(tick, 0), const Offset(0, tick));
    corner(
      Offset(size.width, 0),
      const Offset(-tick, 0),
      const Offset(0, tick),
    );
    corner(
      Offset(0, size.height),
      const Offset(tick, 0),
      const Offset(0, -tick),
    );
    corner(
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
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) =>
      oldDelegate.color != color;
}
