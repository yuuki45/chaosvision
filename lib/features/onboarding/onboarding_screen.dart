import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';
import '../../shared/widgets/magic_circle_widget.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool persistCompletion;
  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.persistCompletion = true,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  static const _pageKanjiNumbers = ['一', '二', '三', '四'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete(requestPermission: true);
    }
  }

  Future<void> _complete({required bool requestPermission}) async {
    if (requestPermission) {
      // Best-effort: ask for the camera permission. If denied, the user
      // can still browse the home screen and re-trigger from the scanner.
      try {
        await Permission.camera.request();
      } catch (_) {
        // ignore — permission_handler can throw on some sims
      }
    }
    if (widget.persistCompletion) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefKeyFirstLaunch, false);
    }
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkDeeper,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 1.3,
                  colors: [
                    Color(0xFF14110B),
                    AppColors.inkBlack,
                    AppColors.inkDeeper,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: KanjiBackdrop()),
          const Positioned.fill(child: ScanlineOverlay()),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  kanjiNumber: _pageKanjiNumbers[_currentPage],
                  onSkip: () => _complete(requestPermission: false),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: const [
                      _PageSummoning(),
                      _PageTheEye(),
                      _PageTiers(),
                      _PageBegin(),
                    ],
                  ),
                ),
                _BottomBar(
                  pageIndex: _currentPage,
                  totalPages: _totalPages,
                  onNext: _next,
                ),
              ],
            ),
          ),
          const Positioned.fill(
            child: GrainOverlay(opacity: 0.06, density: 1800),
          ),
        ],
      ),
    );
  }
}

// ─── Top / Bottom chrome ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String kanjiNumber;
  final VoidCallback onSkip;
  const _TopBar({required this.kanjiNumber, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 6),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '禁  忌  教  典',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 11,
                      color: AppColors.boneDim,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 14, height: 1, color: AppColors.goldTarnish),
                  const SizedBox(width: 10),
                  Text(
                    '第  $kanjiNumber  頁',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 11,
                      color: AppColors.bone,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Text(
                    '略',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 12,
                      color: AppColors.bone.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SKIP',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: AppColors.boneDim,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int pageIndex;
  final int totalPages;
  final VoidCallback onNext;
  const _BottomBar({
    required this.pageIndex,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = pageIndex == totalPages - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Page indicators (4 hex-shaped dots)
          for (int i = 0; i < totalPages; i++) ...[
            CustomPaint(
              size: const Size(10, 10),
              painter: _HexDotPainter(active: i == pageIndex),
            ),
            if (i < totalPages - 1) const SizedBox(width: 8),
          ],
          const SizedBox(width: 12),
          Flexible(
            child: GestureDetector(
              onTap: onNext,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isLast ? 18 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isLast
                      ? AppColors.blood.withValues(alpha: 0.32)
                      : AppColors.inkBlack.withValues(alpha: 0.7),
                  border: Border.all(
                    color: isLast
                        ? AppColors.bloodBright
                        : AppColors.goldLeaf,
                    width: isLast ? 1.0 : 0.8,
                  ),
                  boxShadow: isLast
                      ? [
                          BoxShadow(
                            color:
                                AppColors.bloodBright.withValues(alpha: 0.3),
                            blurRadius: 18,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? '視 を 開 け' : '次',
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 13,
                          color: AppColors.bone,
                          fontWeight: FontWeight.w700,
                          letterSpacing: isLast ? 3 : 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 14,
                        color: AppColors.goldTarnish.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLast ? 'OPEN THE EYE' : 'NEXT',
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: isLast
                              ? AppColors.bloodBright
                              : AppColors.goldLeaf,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: isLast
                            ? AppColors.bloodBright
                            : AppColors.goldLeaf,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HexDotPainter extends CustomPainter {
  final bool active;
  _HexDotPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2 - math.pi / 2;
      final p = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    if (active) {
      canvas.drawPath(
        path,
        Paint()..color = AppColors.goldLeaf,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.goldLeaf.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.goldTarnish.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HexDotPainter oldDelegate) =>
      oldDelegate.active != active;
}

// ─── Page bodies ────────────────────────────────────────────────────

class _PageSummoning extends StatelessWidget {
  const _PageSummoning();

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: ('召   喚', 'SUMMONING'),
      visual: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer aura
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bloodBright.withValues(alpha: 0.32),
                    blurRadius: 60,
                    spreadRadius: -8,
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 1500.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.04, 1.04),
                  duration: 2200.ms,
                ),
            const MagicCircleWidget(size: 220, strokeWidth: 1.4),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 700.ms, delay: 100.ms)
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1, 1),
            duration: 900.ms,
            curve: Curves.easeOutCubic,
          ),
      jpHeadline: '汝、 選 ば れ し 者 よ',
      enHeadline: 'THOU HAST BEEN CHOSEN',
      jpBody: '禁 書 が そ な た に 渡 る。\n'
          'こ の 眼 を 以 て、 世 の 真 の 姿 を 視 よ。',
      enBody: 'The forbidden grimoire opens before thee.\n'
          'Behold the world as it truly is.',
    );
  }
}

class _PageTheEye extends StatelessWidget {
  const _PageTheEye();

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: ('視', 'THE EYE'),
      visual: SizedBox(
        width: 220,
        height: 220,
        child: CustomPaint(painter: _EyeSigilPainter()),
      )
          .animate()
          .fadeIn(duration: 700.ms, delay: 100.ms)
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1, 1),
            duration: 900.ms,
            curve: Curves.easeOutCubic,
          ),
      jpHeadline: '視 を 以 て\n真 名 を 解 読 す る',
      enHeadline: 'READ THE TRUE NAME\nWITH THE INNER EYE',
      jpBody: 'カ メ ラ を 物 体 に 向 け、\n'
          'A I が 異 名 ・ 属 性 ・ 裏 設 定 を 紡 ぐ。',
      enBody: 'Aim the lens at any object.\n'
          'The AI weaves its hidden name and lore.',
    );
  }
}

class _PageTiers extends StatelessWidget {
  const _PageTiers();

  static const _tiers = [
    ('常', 'COMMON', AppColors.boneDim),
    ('稀', 'RARE', Color(0xFF4488FF)),
    ('叙', 'EPIC', Color(0xFF8844FF)),
    ('伝', 'LEGEND', Color(0xFFFF8844)),
    ('神', 'MYTHIC', Color(0xFFFF4488)),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: ('五   階   位', 'FIVE TIERS'),
      visual: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_tiers.length, (i) {
              final tier = _tiers[i];
              return _TierBadge(
                kanji: tier.$1,
                roman: tier.$2,
                color: tier.$3,
              )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: (200 + i * 130).ms,
                  )
                  .slideY(
                    begin: 0.25,
                    end: 0,
                    duration: 600.ms,
                    delay: (200 + i * 130).ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ),
        ),
      ),
      jpHeadline: '稀 少 な る 程、\n強 大 な る 力 が 宿 る',
      enHeadline: 'THE RARER THE SEAL,\nTHE GREATER THE POWER',
      jpBody: '五 種 の 階 位 が 神 器 を 隔 て る。\n'
          '神 を 引 き 当 て し 時、 図 鑑 は 焔 と な る。',
      enBody: 'Five tiers separate the artifacts.\n'
          'When MYTHIC manifests, the codex ignites.',
    );
  }
}

class _PageBegin extends StatelessWidget {
  const _PageBegin();

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: ('始   ま   り', 'COMMENCEMENT'),
      visual: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bloodBright.withValues(alpha: 0.4),
                    blurRadius: 50,
                    spreadRadius: -6,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
                  duration: 1200.ms,
                ),
            CustomPaint(
              size: const Size(160, 160),
              painter: _EyeSigilPainter(crimson: true),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 700.ms, delay: 100.ms)
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1, 1),
            duration: 900.ms,
            curve: Curves.easeOutCubic,
          ),
      jpHeadline: '儀 式 を 始 め よ',
      enHeadline: 'BEGIN THE RITE',
      jpBody: '現 実 と 異 界 の 境 界 を 視 抜 く た め、\n'
          'カ メ ラ へ の 接 続 を 許 可 せ よ。',
      enBody: 'To pierce the veil between worlds,\n'
          'grant the rite access to thy lens.',
    );
  }
}

// ─── Page body shell ────────────────────────────────────────────────

class _PageBody extends StatelessWidget {
  final (String, String) header;
  final Widget visual;
  final String jpHeadline;
  final String enHeadline;
  final String jpBody;
  final String enBody;

  const _PageBody({
    required this.header,
    required this.visual,
    required this.jpHeadline,
    required this.enHeadline,
    required this.jpBody,
    required this.enBody,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ChapterHeader(kanji: header.$1, roman: header.$2)
              .animate()
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 18),
          Center(child: visual),
          const SizedBox(height: 24),
          Text(
            jpHeadline,
            textAlign: TextAlign.center,
            style: GoogleFonts.shipporiMincho(
              fontSize: 22,
              color: AppColors.bone,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              height: 1.55,
              shadows: [
                Shadow(
                  color: AppColors.goldLeaf.withValues(alpha: 0.18),
                  blurRadius: 14,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 250.ms)
              .slideY(begin: 0.1, end: 0, duration: 600.ms),
          const SizedBox(height: 8),
          Text(
            enHeadline,
            textAlign: TextAlign.center,
            style: GoogleFonts.bodoniModa(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.goldLeaf,
              letterSpacing: 2.5,
              height: 1.4,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
          const SizedBox(height: 22),
          Container(
            width: 80,
            height: 0.6,
            color: AppColors.goldTarnish.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 20),
          Text(
            jpBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.shipporiMincho(
              fontSize: 13,
              color: AppColors.bone.withValues(alpha: 0.9),
              letterSpacing: 1.2,
              height: 1.85,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 550.ms),
          const SizedBox(height: 8),
          Text(
            enBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.bodoniModa(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.boneDim,
              letterSpacing: 0.8,
              height: 1.55,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final String kanji;
  final String roman;
  const _ChapterHeader({required this.kanji, required this.roman});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 1, color: AppColors.goldTarnish),
            const SizedBox(width: 12),
            Text(
              kanji,
              style: GoogleFonts.shipporiMincho(
                fontSize: 14,
                color: AppColors.bone,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 12, height: 1, color: AppColors.goldTarnish),
            const SizedBox(width: 10),
            Text(
              roman,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.goldLeaf,
                letterSpacing: 3.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 28, height: 1, color: AppColors.goldTarnish),
          ],
        ),
      ),
    );
  }
}

// ─── Tier badge for page 3 ──────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  final String kanji;
  final String roman;
  final Color color;
  const _TierBadge({
    required this.kanji,
    required this.roman,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: CustomPaint(
            painter: _HexBadgePainter(color: color),
            child: Center(
              child: Text(
                kanji,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 22,
                  color: AppColors.bone,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          roman,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            color: color,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HexBadgePainter extends CustomPainter {
  final Color color;
  _HexBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    Path hex(double radius) {
      final p = Path();
      for (int i = 0; i < 6; i++) {
        final a = (i / 6) * math.pi * 2 - math.pi / 2;
        final pt = Offset(
          center.dx + radius * math.cos(a),
          center.dy + radius * math.sin(a),
        );
        if (i == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      p.close();
      return p;
    }

    final outerHex = hex(r);
    canvas.drawPath(
      outerHex,
      Paint()..color = AppColors.inkBlack.withValues(alpha: 0.92),
    );
    canvas.drawPath(
      outerHex,
      Paint()..color = color.withValues(alpha: 0.12),
    );

    canvas.drawPath(
      outerHex,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawPath(
      hex(r * 0.78),
      Paint()
        ..color = AppColors.goldTarnish.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Vertex dots
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2 - math.pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + r * math.cos(a),
          center.dy + r * math.sin(a),
        ),
        1.6,
        Paint()..color = color,
      );
    }

    // Subtle outer glow
    canvas.drawPath(
      outerHex,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _HexBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─── Eye sigil for pages 2 / 4 ──────────────────────────────────────

class _EyeSigilPainter extends CustomPainter {
  final bool crimson;
  _EyeSigilPainter({this.crimson = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final accent = crimson ? AppColors.bloodBright : AppColors.goldLeaf;

    // Outer hex frame
    final hex = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2 - math.pi / 2;
      final p = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      if (i == 0) {
        hex.moveTo(p.dx, p.dy);
      } else {
        hex.lineTo(p.dx, p.dy);
      }
    }
    hex.close();
    canvas.drawPath(
      hex,
      Paint()
        ..color = accent.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      r * 0.7,
      Paint()
        ..color = AppColors.goldTarnish.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Eye outline
    final eyeWidth = r * 1.05;
    final eyeHeight = r * 0.55;
    final eyePath = Path()
      ..moveTo(center.dx - eyeWidth / 2, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy - eyeHeight,
        center.dx + eyeWidth / 2,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + eyeHeight,
        center.dx - eyeWidth / 2,
        center.dy,
      )
      ..close();
    canvas.drawPath(
      eyePath,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Iris
    final irisR = eyeHeight * 0.78;
    canvas.drawCircle(
      center,
      irisR,
      Paint()..color = accent.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      center,
      irisR * 0.45,
      Paint()..color = AppColors.inkDeeper,
    );
    canvas.drawCircle(
      Offset(center.dx + irisR * 0.25, center.dy - irisR * 0.25),
      irisR * 0.18,
      Paint()..color = AppColors.bone,
    );

    // Vertex dots
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2 - math.pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + r * math.cos(a),
          center.dy + r * math.sin(a),
        ),
        2.2,
        Paint()..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EyeSigilPainter oldDelegate) =>
      oldDelegate.crimson != crimson;
}
