import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MantraBlock extends StatelessWidget {
  const MantraBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '「',
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 28,
                    color: AppColors.bloodBright.withValues(alpha: 0.7),
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '現実は── 此の眼に映る幻にすぎぬ',
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: AppColors.bone,
                    letterSpacing: 1.5,
                    height: 1.6,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(width: 4),
                Text(
                  '」',
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 28,
                    color: AppColors.bloodBright.withValues(alpha: 0.7),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'WITNESS  ―  THE  TRUE  FORM',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.goldTarnish,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}
