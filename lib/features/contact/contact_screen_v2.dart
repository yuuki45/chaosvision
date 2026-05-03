import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';

const _emailAddress = 'web-studio@ymail.ne.jp';

class ContactScreenV2 extends StatelessWidget {
  const ContactScreenV2({super.key});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _emailAddress));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.violetDeep,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        content: Text(
          '宛 先 を 写 し 取 っ た',
          style: GoogleFonts.shipporiMincho(
            color: AppColors.bone,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _emailAddress,
      query: 'subject=CHAOS VISION お問い合わせ',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        _toast(context, 'メールアプリが見つからぬ');
      }
    } catch (_) {
      if (context.mounted) _toast(context, 'メールアプリの起動に失敗');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.blood,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        content: Text(
          msg,
          style: GoogleFonts.shipporiMincho(
            color: AppColors.bone,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(onBack: () => Navigator.of(context).pop())
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 500.ms),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _Lede()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 100.ms),
                      const SizedBox(height: 28),
                      _Section(
                        kanji: '用  件',
                        roman: 'PURPOSE',
                        body:
                            'アプリの使用方法、 不具合の報告、 機能要望、 其の他の問ひ。'
                            ' \n何でも気兼ねなく書状を送るがよい。 '
                            '皆々様の言の葉は 此の禁書を磨き上げる為に用ふ。',
                      ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
                      const SizedBox(height: 28),
                      _Section(
                        kanji: '連  絡  先',
                        roman: 'EMISSARY',
                        child: _EmissaryBlock(
                          onCopy: () => _copy(context),
                          onOpen: () => _openMail(context),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                      const SizedBox(height: 28),
                      _Section(
                        kanji: '必  携',
                        roman: 'REQUIRED  CONTEXT',
                        child: const _RequirementsList(),
                      ).animate().fadeIn(duration: 500.ms, delay: 550.ms),
                      const SizedBox(height: 28),
                      _Section(
                        kanji: '但  し  書',
                        roman: 'CAVEATS',
                        child: const _CaveatsList(),
                      ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                      const SizedBox(height: 32),
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
                    '伝   令',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 16,
                      color: AppColors.bone,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 16, height: 1, color: AppColors.bloodBright),
                  const SizedBox(width: 12),
                  Text(
                    'DISPATCH',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.bloodBright,
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

class _Lede extends StatelessWidget {
  const _Lede();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.inkBlack.withValues(alpha: 0.7),
              border: Border.all(
                color: AppColors.bloodBright.withValues(alpha: 0.7),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blood.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Text(
              '書',
              style: GoogleFonts.shipporiMincho(
                fontSize: 30,
                color: AppColors.bone,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '"  書  を  寄  こ  す  が  よ  い  "',
            style: GoogleFonts.shipporiMincho(
              fontSize: 13,
              color: AppColors.bone,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CONVEY  THY  WORDS  TO  THE  KEEPERS',
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
                letterSpacing: 3,
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

class _EmissaryBlock extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  const _EmissaryBlock({required this.onCopy, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.inkBlack.withValues(alpha: 0.8),
            border: Border.all(
              color: AppColors.goldLeaf.withValues(alpha: 0.7),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldLeaf.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '@',
                style: GoogleFonts.bodoniModa(
                  fontSize: 26,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldLeaf,
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
                child: SelectableText(
                  _emailAddress,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: AppColors.bone,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(
                  Icons.content_copy,
                  color: AppColors.goldLeaf,
                  size: 16,
                ),
                tooltip: '宛先を写す',
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _OpenMailTile(onTap: onOpen),
      ],
    );
  }
}

class _OpenMailTile extends StatefulWidget {
  final VoidCallback onTap;
  const _OpenMailTile({required this.onTap});

  @override
  State<_OpenMailTile> createState() => _OpenMailTileState();
}

class _OpenMailTileState extends State<_OpenMailTile> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.inkBlack.withValues(alpha: 0.7),
            border: Border.all(
              color: AppColors.bloodBright
                  .withValues(alpha: _hovered ? 0.95 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.bloodBright
                    .withValues(alpha: _hovered ? 0.32 : 0.14),
                blurRadius: _hovered ? 22 : 12,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '送',
                style: GoogleFonts.shipporiMincho(
                  fontSize: 26,
                  color: AppColors.bloodBright,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 0.6,
                height: 30,
                color: AppColors.bloodBright.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'COMPOSE  DISPATCH',
                      style: GoogleFonts.bodoniModa(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bone,
                        letterSpacing: -0.3,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '書 状 を 認 む る',
                      style: GoogleFonts.shipporiMincho(
                        fontSize: 10,
                        color: AppColors.bloodBright,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.bloodBright,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementsList extends StatelessWidget {
  const _RequirementsList();

  static const _items = [
    ('機  種', 'iPhone 15 Pro 等'),
    ('iOS  版', 'iOS 26.4.2 等'),
    ('版  数', 'EDITION  1.0.2'),
    ('再  現  手  順', '事象に至る道筋を明らかに'),
    ('影  写', '画面の写し（該当する場合）'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _items.length; i++) ...[
          _ReqRow(label: _items[i].$1, hint: _items[i].$2),
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

class _ReqRow extends StatelessWidget {
  final String label;
  final String hint;
  const _ReqRow({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.goldLeaf,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: GoogleFonts.shipporiMincho(
              fontSize: 12,
              color: AppColors.bone,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
        Container(width: 1, height: 14, color: AppColors.goldTarnish),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hint,
            style: GoogleFonts.shipporiMincho(
              fontSize: 11,
              color: AppColors.boneDim,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _CaveatsList extends StatelessWidget {
  const _CaveatsList();

  static const _items = [
    '返書には 一 〜 三 日 を 要 す',
    '商用 ・ 宣伝の書状には 答えぬ',
    '内容によっては 答えかねる場合あり',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in _items) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: 4,
                    height: 4,
                    color: AppColors.bloodBright.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 12,
                      color: AppColors.bone.withValues(alpha: 0.8),
                      letterSpacing: 1.2,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
                '― Ⅶ ―',
                style: GoogleFonts.bodoniModa(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.boneDim,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              Text(
                'DISPATCH',
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
                  color: AppColors.bloodBright,
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
