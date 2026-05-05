import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'kanji_backdrop.dart';
import 'magic_aura_circle.dart';

class RiteLoading extends StatefulWidget {
  final bool retryAvailable;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSettings;
  final String headline;
  final String englishHeadline;

  const RiteLoading({
    super.key,
    this.retryAvailable = false,
    this.onRetry,
    this.onOpenSettings,
    this.headline = '異 界 へ 接 続 中',
    this.englishHeadline = 'CONNECTING TO THE OTHER REALM',
  });

  @override
  State<RiteLoading> createState() => _RiteLoadingState();
}

class _RiteLoadingState extends State<RiteLoading> {
  static const _steps = <String>[
    'SUMMONING SIGHT',
    'BINDING APERTURE',
    'INVOKING GRIMOIRE',
    'STANDBY',
  ];
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (mounted) setState(() => _step = (_step + 1) % _steps.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.inkDeeper,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: KanjiBackdrop()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MagicAuraCircle(size: 220),
              const SizedBox(height: 36),
              Text(
                widget.headline,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 18,
                  color: AppColors.bone,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.englishHeadline,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.goldTarnish,
                  letterSpacing: 3.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final active = i == _step;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 6,
                    height: 2,
                    color: active
                        ? AppColors.bloodBright
                        : AppColors.boneDim.withValues(alpha: 0.5),
                  );
                }),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 14,
                child: Text(
                  _steps[_step],
                  key: ValueKey(_step),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.bone,
                    letterSpacing: 3,
                  ),
                ),
              ),
              if (widget.retryAvailable) ...[
                const SizedBox(height: 28),
                _CodexButton(
                  onTap: widget.onRetry,
                  jp: '再 び 視 を 開 く',
                  en: 'RETRY',
                  accent: AppColors.bloodBright,
                  fill: AppColors.blood.withValues(alpha: 0.22),
                ),
              ],
              if (widget.onOpenSettings != null) ...[
                const SizedBox(height: 14),
                _CodexButton(
                  onTap: widget.onOpenSettings,
                  jp: '設 定 を 開 く',
                  en: 'OPEN SETTINGS',
                  accent: AppColors.goldLeaf,
                  fill: AppColors.goldTarnish.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '設 定 ＞ プ ラ イ バ シ ー ＞ カ メ ラ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 11,
                      color: AppColors.boneDim,
                      letterSpacing: 3,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CodexButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String jp;
  final String en;
  final Color accent;
  final Color fill;

  const _CodexButton({
    required this.onTap,
    required this.jp,
    required this.en,
    required this.accent,
    required this.fill,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: accent, width: 1),
          color: fill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              jp,
              style: GoogleFonts.shipporiMincho(
                fontSize: 13,
                color: AppColors.bone,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 14, height: 1, color: accent),
            const SizedBox(width: 10),
            Text(
              en,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: accent,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
