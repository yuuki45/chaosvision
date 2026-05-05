import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';

import '../contact/contact_screen_v2.dart';
import '../legal/privacy_policy_screen_v2.dart';
import '../legal/terms_of_service_screen_v2.dart';

class AppInfoScreenV2 extends StatelessWidget {
  const AppInfoScreenV2({super.key});

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
                  center: Alignment(0.0, -0.4),
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
                  child: _Header(onBack: () => Navigator.of(context).pop())
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 500.ms),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _Frontispiece()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 100.ms),
                      const SizedBox(height: 36),
                      _Section(
                        kanji: '概  念',
                        roman: 'DOCTRINE',
                        body:
                            '現実世界に存在する あらゆる物体に "異 名" と "裏 設 定" を 付 与 し、'
                            '中二病的視点で 再解釈する AR スキャンアプリ。\n\n'
                            'スマホをかざすだけで、 此の世界の "真 の 姿" が 露わになる。 '
                            'AI技術により、 身の回りの物体は 神秘的な異名と設定を持つようになる。',
                      ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
                      const SizedBox(height: 32),
                      _Section(
                        kanji: '儀  式',
                        roman: 'RITUAL',
                        child: const _RitualSteps(),
                      ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                      const SizedBox(height: 32),
                      _Section(
                        kanji: '顕  現',
                        roman: 'EMERGENCE',
                        child: const _Emergence(),
                      ).animate().fadeIn(duration: 500.ms, delay: 550.ms),
                      const SizedBox(height: 32),
                      _Section(
                        kanji: '属  性',
                        roman: 'ATTRIBUTES',
                        child: const _AttributeRoster(),
                      ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                      const SizedBox(height: 32),
                      _Section(
                        kanji: '書  類',
                        roman: 'TOMES',
                        child: _LegalTiles(
                          onPrivacy: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreenV2(),
                            ),
                          ),
                          onTerms: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TermsOfServiceScreenV2(),
                            ),
                          ),
                          onContact: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ContactScreenV2(),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 850.ms),
                      const SizedBox(height: 32),
                      const _Colophon()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 1000.ms),
                      const SizedBox(height: 22),
                      const _Footer(),
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
  final VoidCallback onBack;
  const _Header({required this.onBack});

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
                    '起 源 覚 書',
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
                    'ARCANUM',
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

class _Frontispiece extends StatelessWidget {
  const _Frontispiece();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.goldTarnish.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '禁  書  ・  序  文',
              style: GoogleFonts.shipporiMincho(
                fontSize: 10,
                color: AppColors.boneDim,
                letterSpacing: 6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.goldTarnish.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'CHAOS  VISION',
            style: GoogleFonts.bodoniModa(
              fontSize: 38,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              color: AppColors.bone,
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: AppColors.bloodBright.withValues(alpha: 0.3),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.appSubtitle,
          style: GoogleFonts.shipporiMincho(
            fontSize: 14,
            color: AppColors.goldLeaf,
            letterSpacing: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 0.8,
          color: AppColors.bloodBright.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 12),
        Text(
          '"  現  実  は  ── 此  の  眼  に  映  る  幻  に  す  ぎ  ぬ  "',
          textAlign: TextAlign.center,
          style: GoogleFonts.shipporiMincho(
            fontSize: 11,
            color: AppColors.bone.withValues(alpha: 0.85),
            letterSpacing: 1.5,
            fontStyle: FontStyle.italic,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String kanji;
  final String roman;
  final String? body;
  final Widget? child;

  const _Section({
    required this.kanji,
    required this.roman,
    this.body,
    this.child,
  }) : assert(body != null || child != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              kanji,
              style: GoogleFonts.shipporiMincho(
                fontSize: 13,
                color: AppColors.bone,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
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
            Text(
              roman,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: AppColors.goldTarnish,
                letterSpacing: 3.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: child ??
              Text(
                body!,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 13,
                  color: AppColors.bone.withValues(alpha: 0.9),
                  height: 1.95,
                  letterSpacing: 1.2,
                ),
              ),
        ),
      ],
    );
  }
}

class _RitualSteps extends StatelessWidget {
  const _RitualSteps();

  static const _steps = [
    ('ホ ー ム ょ り 「 視 」 を 押 す', 'OPEN THE EYE'),
    ('対 象 物 を 視 界 に 捉 え', 'CAPTURE THE FORM'),
    ('魔 法 陣 が 顕 れ た 時 、 シ ャ ッ タ ー', 'PRESS THE SHUTTER'),
    ('A I が 異 名 と 裏 設 定 を 解 読', 'AI DECODES THE TRUE NAME'),
    ('神 器 図 鑑 に 自 動 で 封 ぜ ら る る', 'AUTO-SEALED INTO GRIMOIRE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          _StepRow(
            index: i + 1,
            jp: _steps[i].$1,
            en: _steps[i].$2,
          ),
          if (i < _steps.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String jp;
  final String en;
  const _StepRow({
    required this.index,
    required this.jp,
    required this.en,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                index.toString().padLeft(2, '0'),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: AppColors.goldLeaf,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 16,
                height: 0.6,
                color: AppColors.goldTarnish,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jp,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 13,
                  color: AppColors.bone,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                en,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.goldTarnish,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Emergence extends StatelessWidget {
  const _Emergence();

  static const _events = [
    (
      label: '呪  わ  れ  た  時  刻',
      time: '04:44 / 13:13 / 23:23',
      note: '現実と異界の境界が最も薄くなる瞬間',
      accent: AppColors.bloodBright,
    ),
    (
      label: '十 三 日 ・ 金 曜',
      time: 'FRIDAY THE 13TH',
      note: '不吉な力が高まる恐怖の日',
      accent: AppColors.violetDeep,
    ),
    (
      label: '聖  な  る  日  付',
      time: 'OCT.31 / DEC.24 / JAN.01',
      note: 'ハロウィン、 聖夜、 新年',
      accent: AppColors.goldLeaf,
    ),
    (
      label: '次  元  歪  曲',
      time: 'DIMENSIONAL DISTORTION',
      note: '時空の歪みにより異界の神器が顕現',
      accent: AppColors.bloodBright,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '下 記 の 刻 限 に 観 測 を 行 う と、'
          ' よ り 高 位 の 神 器 が 顕 現 す る 確 率 が 上 が る。',
          style: GoogleFonts.shipporiMincho(
            fontSize: 13,
            color: AppColors.bone.withValues(alpha: 0.9),
            height: 1.85,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'During these moments, scans are more likely to yield rare artifacts.',
          style: GoogleFonts.bodoniModa(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: AppColors.goldTarnish,
            letterSpacing: 0.6,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < _events.length; i++) ...[
          _EventRow(
            label: _events[i].label,
            time: _events[i].time,
            note: _events[i].note,
            accent: _events[i].accent,
          ),
          if (i < _events.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final String label;
  final String time;
  final String note;
  final Color accent;

  const _EventRow({
    required this.label,
    required this.time,
    required this.note,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.inkBlack.withValues(alpha: 0.55),
        border: Border(
          left: BorderSide(color: accent, width: 2.4),
          top: BorderSide(
              color: AppColors.goldTarnish.withValues(alpha: 0.3), width: 0.6),
          right: BorderSide(
              color: AppColors.goldTarnish.withValues(alpha: 0.3), width: 0.6),
          bottom: BorderSide(
              color: AppColors.goldTarnish.withValues(alpha: 0.3), width: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 12,
                    color: AppColors.bone,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: accent,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: GoogleFonts.shipporiMincho(
              fontSize: 11,
              color: AppColors.bone.withValues(alpha: 0.85),
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeRoster extends StatelessWidget {
  const _AttributeRoster();

  static const _items = [
    ('炎', 'INFERNO', '燃 え 盛 る 力 を 宿 す'),
    ('氷', 'GLACIER', '凍 て つ く 静 寂 の 力'),
    ('雷', 'TEMPEST', '電 撃 の 破 壊 力'),
    ('風', 'GALE', '疾 風 の 機 動 力'),
    ('地', 'TERRA', '大 地 の 頑 強 さ'),
    ('水', 'TIDE', '流 れ る 癒 し の 力'),
    ('光', 'RADIANCE', '聖 な る 浄 化 力'),
    ('闇', 'ABYSS', '深 淵 の 神 秘 力'),
    ('無', 'VOID', '虚 ろ な る 中 立 性'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _items.length; i++) ...[
          _AttrRow(
            kanji: _items[i].$1,
            roman: _items[i].$2,
            note: _items[i].$3,
          ),
          if (i < _items.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 0.5,
                color: AppColors.goldTarnish.withValues(alpha: 0.2),
              ),
            ),
        ],
      ],
    );
  }
}

class _AttrRow extends StatelessWidget {
  final String kanji;
  final String roman;
  final String note;
  const _AttrRow({
    required this.kanji,
    required this.roman,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.attributeColors[kanji] ?? AppColors.goldLeaf;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          kanji,
          style: GoogleFonts.shipporiMincho(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 84,
          child: Text(
            roman,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: color.withValues(alpha: 0.95),
              letterSpacing: 2.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(width: 1, height: 14, color: AppColors.goldTarnish),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            note,
            style: GoogleFonts.shipporiMincho(
              fontSize: 12,
              color: AppColors.bone.withValues(alpha: 0.9),
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalTiles extends StatelessWidget {
  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onContact;

  const _LegalTiles({
    required this.onPrivacy,
    required this.onTerms,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LegalTile(
          kanji: '誓',
          jp: '個 人 情 報 取 扱 い',
          en: 'PRIVACY  POLICY',
          onTap: onPrivacy,
        ),
        const SizedBox(height: 10),
        _LegalTile(
          kanji: '律',
          jp: '利 用 規 約',
          en: 'TERMS  OF  SERVICE',
          onTap: onTerms,
        ),
        const SizedBox(height: 10),
        _LegalTile(
          kanji: '伝',
          jp: '問 ひ 合 は せ',
          en: 'CONTACT',
          onTap: onContact,
        ),
      ],
    );
  }
}

class _LegalTile extends StatefulWidget {
  final String kanji;
  final String jp;
  final String en;
  final VoidCallback onTap;
  const _LegalTile({
    required this.kanji,
    required this.jp,
    required this.en,
    required this.onTap,
  });

  @override
  State<_LegalTile> createState() => _LegalTileState();
}

class _LegalTileState extends State<_LegalTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.inkBlack.withValues(alpha: 0.7),
            border: Border.all(
              color: AppColors.goldTarnish
                  .withValues(alpha: _hovered ? 0.95 : 0.55),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldTarnish
                    .withValues(alpha: _hovered ? 0.22 : 0.08),
                blurRadius: _hovered ? 18 : 10,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                widget.kanji,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 22,
                  color: AppColors.goldLeaf,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 0.6,
                height: 26,
                color: AppColors.goldTarnish.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.jp,
                      style: GoogleFonts.shipporiMincho(
                        fontSize: 13,
                        color: AppColors.bone,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.en,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: AppColors.goldTarnish,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.goldLeaf,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Colophon extends StatelessWidget {
  const _Colophon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.inkBlack.withValues(alpha: 0.55),
        border: Border.all(
          color: AppColors.goldTarnish.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 14, height: 1, color: AppColors.goldTarnish),
              const SizedBox(width: 10),
              Text(
                '奥  付',
                style: GoogleFonts.shipporiMincho(
                  fontSize: 10,
                  color: AppColors.boneDim,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 14, height: 1, color: AppColors.goldTarnish),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'CHAOS  VISION',
            style: GoogleFonts.bodoniModa(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              color: AppColors.bone,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '中 二 ス キ ャ ナ ー',
            style: GoogleFonts.shipporiMincho(
              fontSize: 10,
              color: AppColors.boneDim,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'EDITION  ${AppConstants.appVersion}  ─  XI.MMXXVI',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: AppColors.goldTarnish,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

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
            children: [
              Text(
                '― Ⅵ ―',
                style: GoogleFonts.bodoniModa(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.boneDim,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              Text(
                'ARCANUM',
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
      ),
    );
  }
}
