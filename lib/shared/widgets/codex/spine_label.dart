import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class SpineLabel extends StatelessWidget {
  const SpineLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 14),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.goldTarnish.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldTarnish.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: RotatedBox(
                quarterTurns: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Text(
                        '禁忌教典 ',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 11,
                          letterSpacing: 4,
                          color: AppColors.boneDim,
                        ),
                      ),
                      _hairline(width: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Ⅰ',
                        style: GoogleFonts.bodoniModa(
                          fontSize: 11,
                          color: AppColors.goldTarnish,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _hairline(width: 18),
                      const SizedBox(width: 8),
                      Text(
                        'CHAOS VISION',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          letterSpacing: 3,
                          color: AppColors.bone.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _hairline(width: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Ⅺ.MMXXVI',
                        style: GoogleFonts.bodoniModa(
                          fontSize: 10,
                          color: AppColors.boneDim,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.blood.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.bloodBright.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hairline({required double width}) => Container(
        width: width,
        height: 1,
        color: AppColors.goldTarnish.withValues(alpha: 0.35),
      );
}
