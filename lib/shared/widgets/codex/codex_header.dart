import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class CodexHeader extends StatelessWidget {
  final int collectedCount;

  const CodexHeader({super.key, this.collectedCount = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '// EDITION 1.0.2',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  color: AppColors.goldTarnish.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 24, height: 1, color: AppColors.boneDim),
              const SizedBox(width: 10),
              Text(
                'ENTRY ${(collectedCount + 1).toString().padLeft(3, '0')}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  color: AppColors.bone.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: const Offset(-2, 0),
              child: Text(
                'CHAOS',
                style: GoogleFonts.bodoniModa(
                  fontSize: 72,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bone,
                  height: 0.92,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: const Offset(36, -8),
              child: Text(
                'VISION',
                style: GoogleFonts.bodoniModa(
                  fontSize: 72,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bloodBright,
                  height: 0.92,
                  letterSpacing: -1.5,
                  shadows: [
                    Shadow(
                      color: AppColors.blood.withValues(alpha: 0.6),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 22, height: 1, color: AppColors.goldTarnish),
              const SizedBox(width: 12),
              Text(
                '中二スキャナー',
                style: GoogleFonts.shipporiMincho(
                  fontSize: 16,
                  letterSpacing: 6,
                  color: AppColors.goldLeaf,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 22, height: 1, color: AppColors.goldTarnish),
            ],
          ),
          const SizedBox(height: 18),
          _statusStrip(collectedCount: collectedCount),
        ],
      ),
    );
  }

  Widget _statusStrip({required int collectedCount}) {
    final cells = [
      _StatusCell(label: '解放', value: collectedCount > 99 ? '99+' : '$collectedCount／∞'),
      _StatusCell(label: '守護', value: 'ON', accent: AppColors.bloodBright),
      _StatusCell(label: '異界', value: 'STABLE'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.goldTarnish.withValues(alpha: 0.3),
          width: 0.7,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              cells[i],
              if (i < cells.length - 1) ...[
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 18,
                  color: AppColors.goldTarnish.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;
  const _StatusCell({required this.label, required this.value, this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '［$label］',
          style: GoogleFonts.shipporiMincho(
            fontSize: 10,
            color: AppColors.boneDim,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: accent ?? AppColors.bone,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
