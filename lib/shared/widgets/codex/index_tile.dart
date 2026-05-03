import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

enum TileTone { primary, secondary, tertiary }

class IndexTile extends StatefulWidget {
  final String index;
  final String kanji;
  final String label;
  final String subLabel;
  final String description;
  final VoidCallback onPressed;
  final TileTone tone;

  const IndexTile({
    super.key,
    required this.index,
    required this.kanji,
    required this.label,
    required this.subLabel,
    required this.description,
    required this.onPressed,
    this.tone = TileTone.secondary,
  });

  @override
  State<IndexTile> createState() => _IndexTileState();
}

class _IndexTileState extends State<IndexTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.tone) {
      case TileTone.primary:
        return AppColors.bloodBright;
      case TileTone.secondary:
        return AppColors.goldLeaf;
      case TileTone.tertiary:
        return AppColors.violetDeep;
    }
  }

  Color get _accentDim {
    switch (widget.tone) {
      case TileTone.primary:
        return AppColors.blood;
      case TileTone.secondary:
        return AppColors.goldTarnish;
      case TileTone.tertiary:
        return AppColors.boneDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shifted = _hovered || _press.isAnimating;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) => _press.reverse(),
        onTapCancel: () => _press.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, _) {
            final pressed = _press.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translateByDouble(shifted ? 10.0 : 0.0, 0.0, 0.0, 1.0)
                ..scaleByDouble(
                    1 - 0.02 * pressed, 1 - 0.02 * pressed, 1, 1),
              decoration: BoxDecoration(
                color: AppColors.inkBlack.withValues(alpha: 0.65),
                border: Border.all(
                  color: _accentDim.withValues(alpha: shifted ? 0.9 : 0.55),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: shifted ? 0.35 : 0.12),
                    blurRadius: shifted ? 28 : 14,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _InnerRulePainter(color: _accentDim),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 56,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.index,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppColors.boneDim,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 22,
                                height: 0.6,
                                color: _accentDim,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.kanji,
                                style: GoogleFonts.shipporiMincho(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: _accent,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 0.6,
                          height: 60,
                          color: _accentDim.withValues(alpha: 0.5),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.label,
                                style: GoogleFonts.bodoniModa(
                                  fontSize: 26,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.bone,
                                  height: 1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subLabel,
                                style: GoogleFonts.shipporiMincho(
                                  fontSize: 12,
                                  color: _accent.withValues(alpha: 0.85),
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                style: GoogleFonts.bodoniModa(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.boneDim,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: shifted ? 36 : 24,
                          child: CustomPaint(
                            painter: _ArrowPainter(color: _accent),
                            size: Size(shifted ? 36 : 24, 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InnerRulePainter extends CustomPainter {
  final Color color;
  _InnerRulePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      paint,
    );
    final dotPaint = Paint()..color = color.withValues(alpha: 0.6);
    for (final corner in [
      const Offset(6, 6),
      Offset(size.width - 6, 6),
      Offset(6, size.height - 6),
      Offset(size.width - 6, size.height - 6),
    ]) {
      canvas.drawCircle(corner, 1.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InnerRulePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final midY = size.height / 2;
    canvas.drawLine(Offset(0, midY), Offset(size.width - 4, midY), paint);
    canvas.drawLine(
      Offset(size.width - 4, midY),
      Offset(size.width - 4 - 6, midY - 5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 4, midY),
      Offset(size.width - 4 - 6, midY + 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
