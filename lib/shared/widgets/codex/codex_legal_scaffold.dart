import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'grain_overlay.dart';
import 'kanji_backdrop.dart';
import 'scanline_overlay.dart';

/// A scrollable codex page that hosts long-form text such as legal notices.
/// Provides the consistent header / atmosphere / footer chrome and the
/// typography helpers, while letting callers supply the body sections.
class CodexLegalScaffold extends StatelessWidget {
  final String headerKanji;
  final String headerRoman;
  final String? lede;
  final List<Widget> children;
  final String pageMark;
  final String footerLabel;

  const CodexLegalScaffold({
    super.key,
    required this.headerKanji,
    required this.headerRoman,
    this.lede,
    required this.children,
    required this.pageMark,
    required this.footerLabel,
  });

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    kanji: headerKanji,
                    roman: headerRoman,
                    onBack: () => Navigator.of(context).pop(),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 500.ms),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (lede != null) ...[
                        Text(
                          lede!,
                          style: GoogleFonts.shipporiMincho(
                            fontSize: 13,
                            color: AppColors.bone.withValues(alpha: 0.9),
                            height: 1.95,
                            letterSpacing: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 100.ms),
                        const SizedBox(height: 24),
                      ],
                      ...children,
                      const SizedBox(height: 24),
                      _Footer(pageMark: pageMark, label: footerLabel),
                      const SizedBox(height: 12),
                    ]),
                  ),
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

class _Header extends StatelessWidget {
  final String kanji;
  final String roman;
  final VoidCallback onBack;

  const _Header({
    required this.kanji,
    required this.roman,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.inkBlack.withValues(alpha: 0.7),
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
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    kanji,
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 16,
                      color: AppColors.bone,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 16, height: 1, color: AppColors.goldLeaf),
                  const SizedBox(width: 12),
                  Text(
                    roman,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.goldLeaf,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String pageMark;
  final String label;
  const _Footer({required this.pageMark, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1,
          color: AppColors.goldTarnish.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              pageMark,
              style: GoogleFonts.bodoniModa(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.boneDim,
                letterSpacing: 4,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: AppColors.boneDim,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.goldTarnish,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A section block with codex `kanji / ROMAN` rule header.
class CodexSection extends StatelessWidget {
  final String kanji;
  final String roman;
  final List<Widget> children;

  const CodexSection({
    super.key,
    required this.kanji,
    required this.roman,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                flex: 0,
                child: Text(
                  kanji,
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 13,
                    color: AppColors.bone,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.goldTarnish.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    roman,
                    maxLines: 1,
                    softWrap: false,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: AppColors.goldTarnish,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// A sub-heading inside a CodexSection (e.g., "1.1 カメラ画像").
class CodexSubheading extends StatelessWidget {
  final String text;
  const CodexSubheading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 14,
            color: AppColors.goldLeaf,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.shipporiMincho(
                fontSize: 13,
                color: AppColors.goldLeaf,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain body paragraph in Mincho, optimized for readability.
class CodexBody extends StatelessWidget {
  final String text;
  const CodexBody(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.shipporiMincho(
          fontSize: 13,
          color: AppColors.bone.withValues(alpha: 0.9),
          height: 1.85,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Bullet list styled with hairline ticks.
class CodexBullets extends StatelessWidget {
  final List<String> items;
  const CodexBullets({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.goldTarnish,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 12,
                      color: AppColors.bone.withValues(alpha: 0.85),
                      height: 1.7,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Footer block with revision date + copyright.
class CodexImprint extends StatelessWidget {
  final String? established;
  final String revised;
  final String copyright;
  const CodexImprint({
    super.key,
    this.established,
    required this.revised,
    required this.copyright,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inkBlack.withValues(alpha: 0.55),
        border: Border.all(
          color: AppColors.goldTarnish.withValues(alpha: 0.4),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (established != null)
            Text(
              '制 定  ─  $established',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.boneDim,
                letterSpacing: 2,
              ),
            ),
          if (established != null) const SizedBox(height: 4),
          Text(
            '改 訂  ─  $revised',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.boneDim,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 0.5,
            color: AppColors.goldTarnish.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 6),
          Text(
            copyright,
            style: GoogleFonts.bodoniModa(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.boneDim,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
