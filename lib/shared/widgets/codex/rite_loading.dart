import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'kanji_backdrop.dart';
import 'magic_aura_circle.dart';

class RiteLoading extends StatefulWidget {
  final bool retryAvailable;
  final VoidCallback? onRetry;
  final String headline;
  final String englishHeadline;

  const RiteLoading({
    super.key,
    this.retryAvailable = false,
    this.onRetry,
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
                GestureDetector(
                  onTap: widget.onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.bloodBright,
                        width: 1,
                      ),
                      color: AppColors.blood.withValues(alpha: 0.22),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '再 び 視 を 開 く',
                          style: GoogleFonts.shipporiMincho(
                            fontSize: 13,
                            color: AppColors.bone,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 14,
                          height: 1,
                          color: AppColors.bloodBright,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'RETRY',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: AppColors.bloodBright,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
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
