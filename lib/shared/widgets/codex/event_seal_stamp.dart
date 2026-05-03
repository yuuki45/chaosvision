import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/special_event_service.dart';

class EventSealStamp extends StatelessWidget {
  final SpecialEvent event;
  final int? remainingMinutes;

  const EventSealStamp({
    super.key,
    required this.event,
    this.remainingMinutes,
  });

  String _remaining() {
    if (remainingMinutes == null) return '';
    final h = remainingMinutes! ~/ 60;
    final m = remainingMinutes! % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.018,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.blood.withValues(alpha: 0.18),
          border: Border.all(
            color: AppColors.bloodBright.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blood.withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.bloodBright,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '禁書解放',
              style: GoogleFonts.shipporiMincho(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.bone,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 14, height: 1, color: AppColors.bloodBright),
            const SizedBox(width: 12),
            Text(
              event.name.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.bone,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (remainingMinutes != null) ...[
              const SizedBox(width: 12),
              Container(width: 14, height: 1, color: AppColors.bloodBright),
              const SizedBox(width: 12),
              Text(
                '残 ${_remaining()}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.bloodBright,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
