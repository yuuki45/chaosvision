import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../magic_circle_widget.dart';

/// Codex-styled loading indicator — a magic circle with optional
/// japanese / romaji captions stacked beneath.
class CodexLoader extends StatelessWidget {
  final String? label;
  final String? sublabel;
  final double size;
  final Color color;

  const CodexLoader({
    super.key,
    this.label,
    this.sublabel,
    this.size = 84,
    this.color = AppColors.goldLeaf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.32),
                        blurRadius: size * 0.45,
                        spreadRadius: -size * 0.1,
                      ),
                    ],
                  ),
                ),
              ),
              MagicCircleWidget(
                size: size,
                color: color,
                strokeWidth: size > 50 ? 1.6 : 1.2,
              ),
            ],
          ),
        ),
        if (label != null) ...[
          SizedBox(height: size * 0.22),
          Text(
            label!,
            textAlign: TextAlign.center,
            style: GoogleFonts.shipporiMincho(
              fontSize: 12,
              color: AppColors.bone,
              letterSpacing: 5,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ],
        if (sublabel != null) ...[
          const SizedBox(height: 6),
          Text(
            sublabel!,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: color.withValues(alpha: 0.9),
              letterSpacing: 3,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}
