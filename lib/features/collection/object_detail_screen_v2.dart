import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/share_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/codex/codex_image_frame.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';

class ObjectDetailScreenV2 extends StatefulWidget {
  final ScannedObject object;
  const ObjectDetailScreenV2({super.key, required this.object});

  @override
  State<ObjectDetailScreenV2> createState() => _ObjectDetailScreenV2State();
}

class _ObjectDetailScreenV2State extends State<ObjectDetailScreenV2> {
  late final Future<String?> _imagePathFuture =
      widget.object.getFullImagePath();
  late final ({int position, int total}) _archiveStats = _computeArchiveStats();

  ({int position, int total}) _computeArchiveStats() {
    final all = StorageService.instance.getAllScannedObjects()
      ..sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
    final idx = all.indexWhere((o) => o.id == widget.object.id);
    return (
      position: idx >= 0 ? idx + 1 : all.length,
      total: all.length,
    );
  }

  Color get _attribute =>
      AppColors.attributeColors[widget.object.attribute] ??
      AppColors.goldLeaf;

  Color get _rarityColor {
    final n = _normalizeRarity(widget.object.rarity);
    return AppColors.rarityColors[n] ?? AppColors.goldLeaf;
  }

  String get _rarityShort {
    switch (_normalizeRarity(widget.object.rarity)) {
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
    switch (_normalizeRarity(widget.object.rarity)) {
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
        return _normalizeRarity(widget.object.rarity).toUpperCase();
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

  Future<void> _share() async {
    await ShareService.shareScannedObject(context, widget.object);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.blood,
        content: Text(
          msg,
          style: GoogleFonts.shipporiMincho(
            color: AppColors.bone,
            letterSpacing: 1.5,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        object: widget.object,
        accent: _attribute,
        onConfirm: () {
          Navigator.of(context).pop();
          _deleteObject();
        },
      ),
    );
  }

  Future<void> _deleteObject() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Container(
        color: AppColors.inkDeeper.withValues(alpha: 0.85),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: AppColors.bloodBright,
        ),
      ),
    );
    try {
      if (widget.object.imageRelativePath != null) {
        final fullPath = await widget.object.getFullImagePath();
        if (fullPath != null) {
          final file = File(fullPath);
          if (await file.exists()) await file.delete();
        }
      }
      final ok =
          await StorageService.instance.deleteScannedObject(widget.object.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (ok) {
        Navigator.of(context).pop({
          'deleted': true,
          'objectName': widget.object.alternateName,
        });
      } else {
        _toast('削除に失敗しました');
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _toast('削除エラー: $e');
    }
  }

  String _twoDigit(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final obj = widget.object;
    final ts = obj.scannedAt;
    final timeStr =
        '${ts.year}.${_twoDigit(ts.month)}.${_twoDigit(ts.day)}  ${_twoDigit(ts.hour)}:${_twoDigit(ts.minute)}';
    final entryNo = ((int.tryParse(obj.id) ?? ts.millisecondsSinceEpoch) ~/
                1000 %
            999) +
        1;
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
                    onDelete: _showDeleteDialog,
                    accent: _attribute,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 500.ms),
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
                        archivePosition: _archiveStats.position,
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
                      ).animate().fadeIn(duration: 500.ms, delay: 350.ms),
                      const SizedBox(height: 22),
                      _ChipRow(
                        attribute: obj.attribute,
                        attributeColor: _attribute,
                        attributeRomaji:
                            _attributeRomaji(obj.attribute),
                        rarityNormalized:
                            _normalizeRarity(obj.rarity),
                        rarityRomaji: _rarityRomaji,
                        rarityColor: _rarityColor,
                      ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                      const SizedBox(height: 26),
                      _LoreBlock(description: obj.description)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 650.ms),
                      const SizedBox(height: 26),
                      _Readings(
                        timestamp: timeStr,
                        aether: obj.aetherDensity,
                        resonance: obj.resonance,
                        archivePosition: _archiveStats.position,
                        archiveTotal: _archiveStats.total,
                        accent: _attribute,
                      ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                      const SizedBox(height: 32),
                      _ActionTiles(
                        onShare: _share,
                        onReturn: () => Navigator.of(context).pop(),
                      ).animate().fadeIn(duration: 500.ms, delay: 950.ms),
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
  final VoidCallback onDelete;
  final Color accent;
  const _Header({
    required this.onBack,
    required this.onDelete,
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
                    '神 器 詳 録',
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
                    'SPECIMEN RECORD',
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
            onTap: onDelete,
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
                Icons.delete_outline,
                color: AppColors.bloodBright,
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
            '// ARCHIVE ',
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

class _TrueNameBlock extends StatelessWidget {
  final String original;
  final String name;
  final Color accent;

  const _TrueNameBlock({
    required this.original,
    required this.name,
    required this.accent,
  });

  ({String primary, String secondary}) _split() {
    final brackets = ['《', '〈', '«', '<'];
    int idx = -1;
    for (final b in brackets) {
      final i = name.indexOf(b);
      if (i > 0 && (idx < 0 || i < idx)) idx = i;
    }
    if (idx > 0) {
      return (
        primary: name.substring(0, idx).trim(),
        secondary: name.substring(idx).trim(),
      );
    }
    return (primary: name, secondary: '');
  }

  @override
  Widget build(BuildContext context) {
    final parts = _split();
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
            parts.primary,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.shipporiMincho(
              fontSize: 30,
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              height: 1.05,
              shadows: [
                Shadow(
                  color: accent.withValues(alpha: 0.6),
                  blurRadius: 22,
                ),
              ],
            ),
          ),
        ),
        if (parts.secondary.isNotEmpty) ...[
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              parts.secondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.shipporiMincho(
                fontSize: 16,
                color: accent.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
                letterSpacing: 3,
                height: 1.2,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '※  元 の 姿  ─  $original',
          style: GoogleFonts.shipporiMincho(
            fontSize: 11,
            color: AppColors.bone.withValues(alpha: 0.72),
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
  final String attributeRomaji;
  final String rarityNormalized;
  final String rarityRomaji;
  final Color rarityColor;
  const _ChipRow({
    required this.attribute,
    required this.attributeColor,
    required this.attributeRomaji,
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
            valueEn: attributeRomaji,
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
  final double aether;
  final double resonance;
  final int archivePosition;
  final int archiveTotal;
  final Color accent;
  const _Readings({
    required this.timestamp,
    required this.aether,
    required this.resonance,
    required this.archivePosition,
    required this.archiveTotal,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final aetherPct = (aether * 100).clamp(0, 100).toInt();
    final resonancePct = (resonance * 100).clamp(0, 100).toInt();
    final pos = archivePosition.toString().padLeft(3, '0');
    final tot = archiveTotal.toString().padLeft(3, '0');
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
        _row('SEALED', timestamp, AppColors.bone),
        const SizedBox(height: 8),
        _gauge('AETHER', aetherPct, accent),
        const SizedBox(height: 8),
        _gauge('RESONANCE', resonancePct, AppColors.goldLeaf),
        const SizedBox(height: 8),
        _row('STATUS', '✦  №.$pos  /  $tot', AppColors.bloodBright),
      ],
    );
  }

  Widget _row(String label, String value, Color valueColor) {
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

  Widget _gauge(String label, int pct, Color barColor) {
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
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: pct / 100),
            duration: const Duration(milliseconds: 1100),
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
                            barColor.withValues(alpha: 0.4),
                            barColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.55),
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
  final VoidCallback onShare;
  final VoidCallback onReturn;
  const _ActionTiles({required this.onShare, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            kanji: '共',
            label: 'SHARE',
            subLabel: '伝   令',
            accent: AppColors.bloodBright,
            onTap: onShare,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            kanji: '帰',
            label: 'RETURN',
            subLabel: '帰   還',
            accent: AppColors.goldLeaf,
            onTap: onReturn,
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
              '― Ⅴ ―',
              style: GoogleFonts.bodoniModa(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.boneDim,
                letterSpacing: 4,
              ),
            ),
            const Spacer(),
            Text(
              'ARCHIVE $entry',
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

class _DeleteDialog extends StatelessWidget {
  final ScannedObject object;
  final Color accent;
  final VoidCallback onConfirm;
  const _DeleteDialog({
    required this.object,
    required this.accent,
    required this.onConfirm,
  });

  String _previewName() {
    final raw = object.alternateName;
    final cut = raw.indexOf('《');
    return cut > 0 ? raw.substring(0, cut).trim() : raw;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inkBlack,
          border: Border.all(
            color: AppColors.bloodBright.withValues(alpha: 0.7),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blood.withValues(alpha: 0.3),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.bloodBright,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '神  器  消  去',
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 15,
                    color: AppColors.bone,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.bloodBright.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '此の神器の封を解き、灰塵に帰す',
              style: GoogleFonts.shipporiMincho(
                fontSize: 13,
                color: AppColors.bone.withValues(alpha: 0.9),
                letterSpacing: 1.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.inkDeeper.withValues(alpha: 0.8),
                border: Border.all(
                  color: accent.withValues(alpha: 0.6),
                  width: 0.7,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 28,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _previewName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.shipporiMincho(
                            fontSize: 13,
                            color: accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '元の姿: ${object.objectCategory}',
                          style: GoogleFonts.shipporiMincho(
                            fontSize: 10,
                            color: AppColors.bone.withValues(alpha: 0.72),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: AppColors.bloodBright,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  '此 の 業 は 還 ら ぬ',
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 11,
                    color: AppColors.bloodBright,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.goldTarnish
                              .withValues(alpha: 0.6),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        '止     む',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 13,
                          color: AppColors.bone,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.blood.withValues(alpha: 0.4),
                        border: Border.all(
                          color: AppColors.bloodBright,
                          width: 0.9,
                        ),
                      ),
                      child: Text(
                        '断     つ',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 13,
                          color: AppColors.bone,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
