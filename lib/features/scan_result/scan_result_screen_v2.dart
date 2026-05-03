import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/share_service.dart';
import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/codex/codex_image_frame.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';

class ScanResultScreenV2 extends ConsumerStatefulWidget {
  final ScannedObject scannedObject;
  const ScanResultScreenV2({super.key, required this.scannedObject});

  @override
  ConsumerState<ScanResultScreenV2> createState() =>
      _ScanResultScreenV2State();
}

class _ScanResultScreenV2State extends ConsumerState<ScanResultScreenV2> {
  late final Future<String?> _imagePathFuture =
      widget.scannedObject.getFullImagePath();

  Color get _attribute =>
      AppColors.attributeColors[widget.scannedObject.attribute] ??
      AppColors.goldLeaf;

  Color get _rarityColor {
    final normalized = _normalizeRarity(widget.scannedObject.rarity);
    return AppColors.rarityColors[normalized] ?? AppColors.goldLeaf;
  }

  String get _rarityShort {
    final n = _normalizeRarity(widget.scannedObject.rarity);
    switch (n) {
      case 'コモン':
        return '常';
      case 'レア':
        return '稀';
      case 'エピック':
        return '叙';
      case 'レジェンダリー':
        return '伝';
      case 'ミシック':
        return '神';
      default:
        return '？';
    }
  }

  String _normalizeRarity(String rarity) {
    const map = {
      'Common': 'コモン', 'common': 'コモン', 'COMMON': 'コモン',
      'Rare': 'レア', 'rare': 'レア', 'RARE': 'レア',
      'Epic': 'エピック', 'epic': 'エピック', 'EPIC': 'エピック',
      'Legendary': 'レジェンダリー', 'legendary': 'レジェンダリー',
      'LEGENDARY': 'レジェンダリー',
      'Mythic': 'ミシック', 'mythic': 'ミシック', 'MYTHIC': 'ミシック',
      'Mythical': 'ミシック', 'mythical': 'ミシック',
    };
    return map[rarity] ?? rarity;
  }

  String get _rarityRomaji {
    final n = _normalizeRarity(widget.scannedObject.rarity);
    switch (n) {
      case 'コモン':
        return 'COMMON';
      case 'レア':
        return 'RARE';
      case 'エピック':
        return 'EPIC';
      case 'レジェンダリー':
        return 'LEGENDARY';
      case 'ミシック':
        return 'MYTHIC';
      default:
        return n.toUpperCase();
    }
  }

  Future<void> _share() async {
    await ShareService.shareScannedObject(context, widget.scannedObject);
  }

  String _twoDigit(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final obj = widget.scannedObject;
    final ts = obj.scannedAt;
    final timeStr =
        '${ts.year}.${_twoDigit(ts.month)}.${_twoDigit(ts.day)}  ${_twoDigit(ts.hour)}:${_twoDigit(ts.minute)}';
    final entryNo = ((ts.millisecondsSinceEpoch ~/ 1000) % 999) + 1;
    final entryStr = entryNo.toString().padLeft(3, '0');

    return Scaffold(
      backgroundColor: AppColors.inkDeeper,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.3),
                radius: 1.3,
                colors: [
                  _attribute.withValues(alpha: 0.18),
                  AppColors.inkBlack,
                  AppColors.inkDeeper,
                ],
                stops: const [0.0, 0.55, 1.0],
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
                    onBack: () => Navigator.of(context).pop(),
                    onShare: _share,
                    accent: _attribute,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _MetaLine(entry: entryStr, timestamp: timeStr)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 14),
                      CodexImageFrame(
                        imagePathFuture: _imagePathFuture,
                        accent: _attribute,
                        rarityLabel: _rarityShort,
                        rarityColor: _rarityColor,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 150.ms)
                          .slideY(
                            begin: -0.05,
                            end: 0,
                            duration: 700.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 28),
                      _TrueNameBlock(
                        original: obj.objectCategory,
                        name: obj.alternateName,
                        accent: _attribute,
                      ),
                      const SizedBox(height: 22),
                      _ChipRow(
                        attribute: obj.attribute,
                        attributeColor: _attribute,
                        rarityNormalized:
                            _normalizeRarity(obj.rarity),
                        rarityRomaji: _rarityRomaji,
                        rarityColor: _rarityColor,
                      )
                          .animate()
                          .fadeIn(
                            duration: 500.ms,
                            delay: 1100.ms,
                          )
                          .slideY(begin: 0.1, end: 0, duration: 600.ms),
                      const SizedBox(height: 26),
                      _LoreBlock(description: obj.description)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 1300.ms),
                      const SizedBox(height: 26),
                      _Readings(
                        timestamp: timeStr,
                        confidence: obj.confidence,
                        accent: _attribute,
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 1500.ms),
                      const SizedBox(height: 32),
                      _ActionTiles(
                        onRescan: () => Navigator.of(context).pop(),
                        onHome: () => Navigator.of(context)
                            .popUntil((r) => r.isFirst),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 1700.ms)
                          .slideY(begin: 0.15, end: 0, duration: 600.ms),
                      const SizedBox(height: 22),
                      _Footer(entry: entryStr),
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
  final VoidCallback onShare;
  final Color accent;
  const _Header({
    required this.onBack,
    required this.onShare,
    required this.accent,
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
                Icons.close,
                color: AppColors.bone,
                size: 18,
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
                    '封 印 解 除',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 16,
                      color: AppColors.bone,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 16, height: 1, color: accent),
                  const SizedBox(width: 12),
                  Text(
                    'SEAL  UNDONE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: accent,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onShare,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.inkBlack.withValues(alpha: 0.7),
                border: Border.all(
                  color: AppColors.bloodBright.withValues(alpha: 0.7),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: AppColors.bone,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final String entry;
  final String timestamp;
  const _MetaLine({required this.entry, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            '// ENTRY ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.boneDim,
              letterSpacing: 2,
            ),
          ),
          Text(
            'No.$entry',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.bone,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 18, height: 1, color: AppColors.goldTarnish),
          const SizedBox(width: 10),
          Text(
            'XI.MMXXVI',
            style: GoogleFonts.bodoniModa(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.goldTarnish,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 18, height: 1, color: AppColors.goldTarnish),
          const SizedBox(width: 10),
          Text(
            timestamp,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.boneDim,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrueNameBlock extends StatefulWidget {
  final String original;
  final String name;
  final Color accent;

  const _TrueNameBlock({
    required this.original,
    required this.name,
    required this.accent,
  });

  @override
  State<_TrueNameBlock> createState() => _TrueNameBlockState();
}

class _TrueNameBlockState extends State<_TrueNameBlock> {
  late final String _primary;
  late final String _secondary;
  int _primaryShown = 0;
  int _secondaryShown = 0;

  @override
  void initState() {
    super.initState();
    _splitName();
    _typeOut();
  }

  void _splitName() {
    final raw = widget.name;
    final brackets = ['《', '〈', '«', '<', '("'];
    int idx = -1;
    for (final b in brackets) {
      final i = raw.indexOf(b);
      if (i > 0 && (idx < 0 || i < idx)) idx = i;
    }
    if (idx > 0) {
      _primary = raw.substring(0, idx).trim();
      _secondary = raw.substring(idx).trim();
    } else {
      _primary = raw;
      _secondary = '';
    }
  }

  Future<void> _typeOut() async {
    await Future.delayed(const Duration(milliseconds: 700));
    for (int i = 1; i <= _primary.length; i++) {
      if (!mounted) return;
      setState(() => _primaryShown = i);
      await Future.delayed(const Duration(milliseconds: 75));
    }
    if (_secondary.isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 220));
    for (int i = 1; i <= _secondary.length; i++) {
      if (!mounted) return;
      setState(() => _secondaryShown = i);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryVisible = _primary.substring(0, _primaryShown);
    final secondaryVisible = _secondary.isEmpty
        ? ''
        : _secondary.substring(0, _secondaryShown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 28, height: 1, color: AppColors.goldTarnish),
            const SizedBox(width: 12),
            Text(
              '真   名',
              style: GoogleFonts.shipporiMincho(
                fontSize: 11,
                color: AppColors.boneDim,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 28, height: 1, color: AppColors.goldTarnish),
          ],
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            primaryVisible.isEmpty ? ' ' : primaryVisible,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.shipporiMincho(
              fontSize: 30,
              color: widget.accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              height: 1.05,
              shadows: [
                Shadow(
                  color: widget.accent.withValues(alpha: 0.6),
                  blurRadius: 22,
                ),
              ],
            ),
          ),
        ),
        if (_secondary.isNotEmpty) ...[
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              secondaryVisible.isEmpty ? ' ' : secondaryVisible,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.shipporiMincho(
                fontSize: 16,
                color: widget.accent.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
                letterSpacing: 3,
                height: 1.2,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '※  元 の 姿  ─  ${widget.original}',
          style: GoogleFonts.shipporiMincho(
            fontSize: 11,
            color: AppColors.boneDim,
            letterSpacing: 2,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String attribute;
  final Color attributeColor;
  final String rarityNormalized;
  final String rarityRomaji;
  final Color rarityColor;
  const _ChipRow({
    required this.attribute,
    required this.attributeColor,
    required this.rarityNormalized,
    required this.rarityRomaji,
    required this.rarityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ChipCard(
            label: '属  性',
            valueJp: attribute,
            valueEn: _attributeRomaji(attribute),
            accent: attributeColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChipCard(
            label: '階  級',
            valueJp: rarityNormalized,
            valueEn: rarityRomaji,
            accent: rarityColor,
          ),
        ),
      ],
    );
  }

  String _attributeRomaji(String a) {
    switch (a) {
      case '炎':
        return 'INFERNO';
      case '氷':
        return 'GLACIER';
      case '雷':
        return 'TEMPEST';
      case '闇':
        return 'ABYSS';
      case '光':
        return 'RADIANCE';
      case '風':
        return 'GALE';
      case '地':
        return 'TERRA';
      case '水':
        return 'TIDE';
      case '無':
        return 'VOID';
      default:
        return a.toUpperCase();
    }
  }
}

class _ChipCard extends StatelessWidget {
  final String label;
  final String valueJp;
  final String valueEn;
  final Color accent;

  const _ChipCard({
    required this.label,
    required this.valueJp,
    required this.valueEn,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.inkBlack.withValues(alpha: 0.6),
        border: Border.all(
          color: accent.withValues(alpha: 0.7),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.shipporiMincho(
              fontSize: 10,
              color: AppColors.boneDim,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 22, height: 1, color: accent),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueJp,
              style: GoogleFonts.shipporiMincho(
                fontSize: 22,
                color: AppColors.bone,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueEn,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: accent.withValues(alpha: 0.95),
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoreBlock extends StatelessWidget {
  final String description;
  const _LoreBlock({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '異   聞',
              style: GoogleFonts.shipporiMincho(
                fontSize: 11,
                color: AppColors.bone,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
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
              'LORE',
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
          child: Text(
            description,
            style: GoogleFonts.shipporiMincho(
              fontSize: 14,
              color: AppColors.bone.withValues(alpha: 0.9),
              height: 1.85,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _Readings extends StatelessWidget {
  final String timestamp;
  final double confidence;
  final Color accent;
  const _Readings({
    required this.timestamp,
    required this.confidence,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).clamp(0, 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '計   測',
              style: GoogleFonts.shipporiMincho(
                fontSize: 11,
                color: AppColors.bone,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
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
              'READINGS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: AppColors.goldTarnish,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _row('TIMESTAMP', timestamp, valueColor: AppColors.bone),
        const SizedBox(height: 8),
        _confidenceRow(pct),
        const SizedBox(height: 8),
        _row(
          'ARCHIVED',
          '✦  STORED IN GRIMOIRE',
          valueColor: AppColors.bloodBright,
        ),
      ],
    );
  }

  Widget _row(String label, String value, {required Color valueColor}) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: AppColors.boneDim,
              letterSpacing: 2.2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: valueColor,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _confidenceRow(int pct) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            'CONFIDENCE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: AppColors.boneDim,
              letterSpacing: 2.2,
            ),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: pct / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.goldTarnish.withValues(alpha: 0.6),
                        width: 0.6,
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.4),
                            accent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.55),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$pct%',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: AppColors.bone,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionTiles extends StatelessWidget {
  final VoidCallback onRescan;
  final VoidCallback onHome;
  const _ActionTiles({required this.onRescan, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            kanji: '視',
            label: 'RESCAN',
            subLabel: '再 観 測',
            accent: AppColors.bloodBright,
            onTap: onRescan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            kanji: '帰',
            label: 'RETURN',
            subLabel: '帰   還',
            accent: AppColors.goldLeaf,
            onTap: onHome,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatefulWidget {
  final String kanji;
  final String label;
  final String subLabel;
  final Color accent;
  final VoidCallback onTap;
  const _ActionTile({
    required this.kanji,
    required this.label,
    required this.subLabel,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
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
              color: widget.accent.withValues(alpha: _hovered ? 0.95 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: _hovered ? 0.32 : 0.14),
                blurRadius: _hovered ? 22 : 12,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                widget.kanji,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 26,
                  color: widget.accent,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 0.6,
                height: 30,
                color: widget.accent.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.bodoniModa(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w800,
                          color: AppColors.bone,
                          letterSpacing: -0.3,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.subLabel,
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 10,
                          color: widget.accent,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: widget.accent,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String entry;
  const _Footer({required this.entry});

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
              '― Ⅲ ―',
              style: GoogleFonts.bodoniModa(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.boneDim,
                letterSpacing: 4,
              ),
            ),
            const Spacer(),
            Text(
              'ENTRY $entry',
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

