import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../models/scanned_object.dart';
import '../magic_circle_widget.dart';
import 'wax_stamp.dart';

/// Composed share-image card. Designed at 360 × 360 logical pixels
/// (1080 × 1080 at pixelRatio 3) — a 1:1 square that displays fully
/// on X / Instagram / Threads previews without cropping.
class ShareCard extends StatelessWidget {
  final ScannedObject object;
  final Uint8List? imageBytes;

  const ShareCard({
    super.key,
    required this.object,
    this.imageBytes,
  });

  Color get _attribute =>
      AppColors.attributeColors[object.attribute] ?? AppColors.goldLeaf;

  Color get _rarityColor {
    final n = _normalizeRarity(object.rarity);
    return AppColors.rarityColors[n] ?? AppColors.goldLeaf;
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

  String get _rarityKanji {
    switch (_normalizeRarity(object.rarity)) {
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

  String get _rarityRomaji {
    switch (_normalizeRarity(object.rarity)) {
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
        return _normalizeRarity(object.rarity).toUpperCase();
    }
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

  String _twoDigit(int v) => v.toString().padLeft(2, '0');

  ({String primary, String secondary}) _splitName() {
    final raw = object.alternateName;
    final brackets = ['《', '〈', '«', '<'];
    int idx = -1;
    for (final b in brackets) {
      final i = raw.indexOf(b);
      if (i > 0 && (idx < 0 || i < idx)) idx = i;
    }
    if (idx > 0) {
      return (
        primary: raw.substring(0, idx).trim(),
        secondary: raw.substring(idx).trim(),
      );
    }
    return (primary: raw, secondary: '');
  }

  @override
  Widget build(BuildContext context) {
    final ts = object.scannedAt;
    final timeStr =
        '${ts.year}.${_twoDigit(ts.month)}.${_twoDigit(ts.day)}';
    final entryNo =
        ((int.tryParse(object.id) ?? ts.millisecondsSinceEpoch) ~/ 1000 % 999) +
            1;
    final entryStr = entryNo.toString().padLeft(3, '0');
    final parts = _splitName();

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 360,
        height: 360,
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _meta(entryStr, timeStr),
                const SizedBox(height: 8),
                Center(child: _photo()),
                const SizedBox(height: 10),
                _trueName(parts.primary, parts.secondary),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _chip(
                        label: '属  性',
                        valueJp: object.attribute,
                        valueEn: _attributeRomaji(object.attribute),
                        accent: _attribute,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _chip(
                        label: '階  級',
                        valueJp: _normalizeRarity(object.rarity),
                        valueEn: _rarityRomaji,
                        accent: _rarityColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _signature(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(String entry, String date) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            '// CHAOS VISION ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.bone,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 14, height: 1, color: AppColors.goldTarnish),
          const SizedBox(width: 8),
          Text(
            'No.$entry',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.bone,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 14, height: 1, color: AppColors.goldTarnish),
          const SizedBox(width: 8),
          Text(
            date,
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

  Widget _photo() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.inkBlack.withValues(alpha: 0.7),
                border: Border.all(
                  color: _attribute.withValues(alpha: 0.5),
                  width: 0.7,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _attribute.withValues(alpha: 0.3),
                    blurRadius: 28,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.goldTarnish.withValues(alpha: 0.6),
                    width: 0.6,
                  ),
                ),
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _attribute.withValues(alpha: 0.4),
                          BlendMode.color,
                        ),
                        child: imageBytes != null
                            ? Image.memory(
                                imageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Container(
                                color: AppColors.inkDeeper,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.boneDim,
                                ),
                              ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.78,
                              heightFactor: 0.78,
                              child: Opacity(
                                opacity: 0.22,
                                child: MagicCircleWidget(
                                  color: _attribute,
                                  animate: false,
                                  strokeWidth: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _BracketPainter(color: _attribute)),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: WaxStamp(
              label: _rarityKanji,
              sublabel: 'SIGIL',
              color: _rarityColor,
              size: 48,
            ),
          ),
          Positioned(
            left: 6,
            bottom: 5,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: AppColors.inkDeeper.withValues(alpha: 0.7),
              child: Text(
                'PROOF.JPG',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 7,
                  color: AppColors.boneDim,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trueName(String primary, String secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 18, height: 1, color: AppColors.goldTarnish),
            const SizedBox(width: 8),
            Text(
              '真   名',
              style: GoogleFonts.shipporiMincho(
                fontSize: 9,
                color: AppColors.boneDim,
                letterSpacing: 5,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 18, height: 1, color: AppColors.goldTarnish),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            primary,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: GoogleFonts.shipporiMincho(
              fontSize: 19,
              color: _attribute,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              height: 1.0,
              shadows: [
                Shadow(
                  color: _attribute.withValues(alpha: 0.6),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              secondary,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.shipporiMincho(
                fontSize: 11,
                color: _attribute.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                height: 1.0,
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          '※  元の姿  ─  ${object.objectCategory}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.shipporiMincho(
            fontSize: 9,
            color: AppColors.boneDim,
            letterSpacing: 1.2,
            fontStyle: FontStyle.italic,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required String valueJp,
    required String valueEn,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
      decoration: BoxDecoration(
        color: AppColors.inkBlack.withValues(alpha: 0.6),
        border: Border.all(
          color: accent.withValues(alpha: 0.7),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.shipporiMincho(
              fontSize: 8,
              color: AppColors.boneDim,
              letterSpacing: 3,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Container(width: 16, height: 1, color: accent),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueJp,
              style: GoogleFonts.shipporiMincho(
                fontSize: 15,
                color: AppColors.bone,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueEn,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 7,
                color: accent.withValues(alpha: 0.95),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signature() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 14, height: 1, color: AppColors.goldTarnish),
            const SizedBox(width: 8),
            Text(
              'CHAOS  VISION',
              style: GoogleFonts.bodoniModa(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                color: AppColors.bone,
                letterSpacing: 1.4,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 14, height: 1, color: AppColors.goldTarnish),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '中  二  ス  キ  ャ  ナ  ー',
          style: GoogleFonts.shipporiMincho(
            fontSize: 7,
            color: AppColors.boneDim,
            letterSpacing: 4,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    const tick = 14.0;
    void corner(Offset o, Offset h, Offset v) {
      canvas.drawLine(o, o + h, paint);
      canvas.drawLine(o, o + v, paint);
    }

    corner(Offset.zero, const Offset(tick, 0), const Offset(0, tick));
    corner(
      Offset(size.width, 0),
      const Offset(-tick, 0),
      const Offset(0, tick),
    );
    corner(
      Offset(0, size.height),
      const Offset(tick, 0),
      const Offset(0, -tick),
    );
    corner(
      Offset(size.width, size.height),
      const Offset(-tick, 0),
      const Offset(0, -tick),
    );

    final dotFill = Paint()..color = color;
    for (final p in [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      canvas.drawCircle(p, 2.4, dotFill);
    }
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) =>
      oldDelegate.color != color;
}
