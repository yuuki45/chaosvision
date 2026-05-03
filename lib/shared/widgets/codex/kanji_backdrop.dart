import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class KanjiBackdrop extends StatelessWidget {
  const KanjiBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 80,
            right: -60,
            child: Transform.rotate(
              angle: -0.14,
              child: Text(
                '禁',
                style: GoogleFonts.shipporiMincho(
                  fontSize: 480,
                  fontWeight: FontWeight.w900,
                  color: AppColors.goldTarnish.withValues(alpha: 0.045),
                  height: 0.85,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -40,
            child: Transform.rotate(
              angle: 0.18,
              child: Text(
                '視',
                style: GoogleFonts.shipporiMincho(
                  fontSize: 320,
                  fontWeight: FontWeight.w900,
                  color: AppColors.blood.withValues(alpha: 0.05),
                  height: 0.85,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
