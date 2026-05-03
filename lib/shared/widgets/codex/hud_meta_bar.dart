import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class HudMetaBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool scanning;

  const HudMetaBar({
    super.key,
    required this.onBack,
    required this.scanning,
  });

  @override
  Widget build(BuildContext context) {
    final accent = scanning ? AppColors.bloodBright : AppColors.goldLeaf;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.inkDeeper.withValues(alpha: 0.55),
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldTarnish.withValues(alpha: 0.35),
            width: 0.7,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _backRune(onBack),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        '// ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: AppColors.boneDim,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '観 測 の 儀',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 14,
                          color: AppColors.bone,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 14,
                        height: 1,
                        color: AppColors.goldTarnish,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'RITE OF OBSERVATION',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppColors.goldTarnish,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusDots(scanning: scanning, accent: accent),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _meta('LENS', scanning ? 'BURNING' : 'ACTIVE', accent),
                _divider(),
                _meta('APERTURE', 'f／∞', AppColors.bone),
                _divider(),
                _meta('GRIMOIRE', 'READY', AppColors.bone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: AppColors.boneDim,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: valueColor,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 10,
        color: AppColors.goldTarnish.withValues(alpha: 0.4),
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );

  Widget _backRune(VoidCallback onBack) {
    return GestureDetector(
      onTap: onBack,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.inkBlack.withValues(alpha: 0.55),
          border: Border.all(
            color: AppColors.goldTarnish.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.bone,
          size: 22,
        ),
      ),
    );
  }
}

class _StatusDots extends StatefulWidget {
  final bool scanning;
  final Color accent;
  const _StatusDots({required this.scanning, required this.accent});

  @override
  State<_StatusDots> createState() => _StatusDotsState();
}

class _StatusDotsState extends State<_StatusDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final phase = (_ctrl.value * 4 + i) % 4;
            final on = widget.scanning ? phase < 1.5 : phase < 0.6;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: on
                      ? widget.accent
                      : widget.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
