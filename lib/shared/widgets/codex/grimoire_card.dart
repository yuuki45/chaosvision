import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../models/scanned_object.dart';
import '../lazy_image.dart';
import 'wax_stamp.dart';

class GrimoireCard extends StatelessWidget {
  final ScannedObject object;
  final int index;
  final VoidCallback onTap;

  const GrimoireCard({
    super.key,
    required this.object,
    required this.index,
    required this.onTap,
  });

  Color get _attribute =>
      AppColors.attributeColors[object.attribute] ?? AppColors.goldLeaf;

  Color get _rarityColor {
    final n = _normalizeRarity(object.rarity);
    return AppColors.rarityColors[n] ?? AppColors.goldLeaf;
  }

  String get _rarityShort {
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

  String get _displayName {
    final raw = object.alternateName;
    final cut = raw.indexOf('《');
    return cut > 0 ? raw.substring(0, cut).trim() : raw;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inkBlack.withValues(alpha: 0.7),
          border: Border.all(
            color: _rarityColor.withValues(alpha: 0.6),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: _rarityColor.withValues(alpha: 0.16),
              blurRadius: 14,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.goldTarnish.withValues(alpha: 0.55),
                            width: 0.5,
                          ),
                        ),
                        child: ClipRect(
                          child: LazyImage(
                            key: ValueKey(
                                '${object.id}_${object.imageRelativePath}'),
                            imagePath: object.imageRelativePath,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorWidget: _Placeholder(color: _attribute),
                            placeholder: Container(
                              color: AppColors.inkDeeper,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _BracketPainter(color: _attribute),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: WaxStamp(
                      label: _rarityShort,
                      color: _rarityColor,
                      size: 38,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      color: AppColors.inkDeeper.withValues(alpha: 0.7),
                      child: Text(
                        'No.${(index + 1).toString().padLeft(3, '0')}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppColors.bone.withValues(alpha: 0.85),
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.shipporiMincho(
                        fontSize: 13,
                        color: _attribute,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 0.6,
                      color: AppColors.goldTarnish.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          object.attribute,
                          style: GoogleFonts.shipporiMincho(
                            fontSize: 13,
                            color: _attribute,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 1,
                          height: 10,
                          color: AppColors.goldTarnish.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _rarityRomaji,
                              maxLines: 1,
                              softWrap: false,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: _rarityColor,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;

    const tick = 14.0;
    const inset = 4.0;
    void corner(Offset o, Offset h, Offset v) {
      canvas.drawLine(o, o + h, paint);
      canvas.drawLine(o, o + v, paint);
    }

    corner(
      const Offset(inset, inset),
      const Offset(tick, 0),
      const Offset(0, tick),
    );
    corner(
      Offset(size.width - inset, inset),
      const Offset(-tick, 0),
      const Offset(0, tick),
    );
    corner(
      Offset(inset, size.height - inset),
      const Offset(tick, 0),
      const Offset(0, -tick),
    );
    corner(
      Offset(size.width - inset, size.height - inset),
      const Offset(-tick, 0),
      const Offset(0, -tick),
    );
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Placeholder extends StatelessWidget {
  final Color color;
  const _Placeholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            AppColors.inkDeeper,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.auto_awesome_outlined,
        size: 36,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}
