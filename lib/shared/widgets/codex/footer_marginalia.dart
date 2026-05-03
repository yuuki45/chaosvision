import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class FooterMarginalia extends StatelessWidget {
  const FooterMarginalia({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.goldTarnish.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '― Ⅰ ―',
                style: GoogleFonts.bodoniModa(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.boneDim,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              Text(
                'v1.0.2',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.boneDim,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 10,
                color: AppColors.boneDim.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'BUILD 1',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.boneDim,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.goldTarnish.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
