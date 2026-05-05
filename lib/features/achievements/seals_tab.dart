import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/achievement_service.dart';
import '../../shared/models/achievement_unlock.dart';
import 'achievement_catalog.dart';

/// コレクション画面の「印璽」タブ。
/// 解除済み印璽 + 未解除（プレビュー or 秘印マスク）を一覧表示する。
class SealsTab extends StatefulWidget {
  const SealsTab({super.key});

  @override
  State<SealsTab> createState() => _SealsTabState();
}

class _SealsTabState extends State<SealsTab> {
  // null = すべて
  AchievementCategory? _selected;

  @override
  Widget build(BuildContext context) {
    final svc = AchievementService.instance;
    final unlocks = {
      for (final u in svc.allUnlocks()) u.id: u,
    };

    final visible = achievementCatalog.where((a) {
      if (_selected == null) return true;
      return a.category == _selected;
    }).toList();

    final unlockedCount =
        achievementCatalog.where((a) => unlocks.containsKey(a.id)).length;
    final total = achievementCatalog.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressPanel(unlocked: unlockedCount, total: total)
            .animate()
            .fadeIn(duration: 360.ms),
        const SizedBox(height: 12),
        _CategoryFilterRow(
          selected: _selected,
          onSelect: (c) => setState(() => _selected = c),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: visible.isEmpty
              ? const _SealEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  itemBuilder: (_, i) {
                    final a = visible[i];
                    final unlock = unlocks[a.id];
                    return _SealRow(
                      achievement: a,
                      unlock: unlock,
                    )
                        .animate()
                        .fadeIn(duration: 360.ms, delay: (i * 30).ms)
                        .slideX(
                          begin: 0.04,
                          end: 0,
                          duration: 360.ms,
                          delay: (i * 30).ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: visible.length,
                ),
        ),
      ],
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  final int unlocked;
  final int total;
  const _ProgressPanel({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inkBlack.withValues(alpha: 0.62),
          border: Border.all(
            color: AppColors.goldTarnish.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: CustomPaint(
                size: const Size(36, 36),
                painter: _MiniSealPainter(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '授 印',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 12,
                          color: AppColors.bone,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(width: 12, height: 1, color: AppColors.goldLeaf),
                      const SizedBox(width: 10),
                      Text(
                        'SEALS GRANTED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppColors.goldLeaf,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.boneDim.withValues(alpha: 0.4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct.clamp(0.0, 1.0),
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.goldLeaf,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '$unlocked／$total',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: AppColors.bone,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  final AchievementCategory? selected;
  final ValueChanged<AchievementCategory?> onSelect;
  const _CategoryFilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = <(AchievementCategory?, String)>[
      (null, '全'),
      (AchievementCategory.quantity, '蒐'),
      (AchievementCategory.rarity, '位'),
      (AchievementCategory.attribute, '属'),
      (AchievementCategory.event, '刻'),
      (AchievementCategory.hidden, '秘'),
    ];
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemBuilder: (_, i) {
          final (cat, label) = items[i];
          final active = selected == cat;
          return GestureDetector(
            onTap: () => onSelect(cat),
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.goldTarnish.withValues(alpha: 0.18)
                    : Colors.transparent,
                border: Border.all(
                  color: active
                      ? AppColors.goldLeaf
                      : AppColors.goldTarnish.withValues(alpha: 0.45),
                  width: 0.8,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 12,
                  color: active ? AppColors.bone : AppColors.boneDim,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _SealRow extends StatelessWidget {
  final Achievement achievement;
  final AchievementUnlock? unlock;
  const _SealRow({required this.achievement, required this.unlock});

  bool get _unlocked => unlock != null;
  bool get _hideContent => achievement.secret && !_unlocked;

  @override
  Widget build(BuildContext context) {
    final accent = _unlocked ? AppColors.goldLeaf : AppColors.boneDim;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkBlack
            .withValues(alpha: _unlocked ? 0.66 : 0.42),
        border: Border.all(
          color: accent.withValues(alpha: _unlocked ? 0.7 : 0.35),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _RowSealPainter(unlocked: _unlocked),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _hideContent ? '？ ？ ？' : achievement.title,
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 14,
                          color: _unlocked
                              ? AppColors.bone
                              : AppColors.boneDim.withValues(alpha: 0.85),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _categoryBadge(achievement.category, _unlocked),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _hideContent ? 'SEALED' : achievement.englishTitle,
                  style: GoogleFonts.bodoniModa(
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                    color: _unlocked
                        ? AppColors.goldLeaf
                        : AppColors.boneDim.withValues(alpha: 0.7),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _hideContent
                      ? '— 条 件 不 詳 —'
                      : achievement.description,
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 11,
                    color: AppColors.bone.withValues(
                      alpha: _unlocked ? 0.85 : 0.5,
                    ),
                    height: 1.55,
                    letterSpacing: 1.2,
                  ),
                ),
                if (_unlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatUnlockedAt(unlock!.unlockedAt),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: AppColors.goldTarnish,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBadge(AchievementCategory c, bool unlocked) {
    final label = switch (c) {
      AchievementCategory.quantity => '蒐',
      AchievementCategory.rarity => '位',
      AchievementCategory.attribute => '属',
      AchievementCategory.event => '刻',
      AchievementCategory.hidden => '秘',
    };
    final color =
        unlocked ? AppColors.goldLeaf : AppColors.boneDim.withValues(alpha: 0.6);
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 0.7),
      ),
      child: Text(
        label,
        style: GoogleFonts.shipporiMincho(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static String _formatUnlockedAt(DateTime t) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${t.year}.${pad(t.month)}.${pad(t.day)}  ${pad(t.hour)}:${pad(t.minute)}';
  }
}

class _SealEmpty extends StatelessWidget {
  const _SealEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          '該 当 す る 印 璽 が 無 い',
          textAlign: TextAlign.center,
          style: GoogleFonts.shipporiMincho(
            fontSize: 13,
            color: AppColors.boneDim,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

class _MiniSealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = AppColors.goldTarnish;
    canvas.drawCircle(c, r * 0.92, outer);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.bloodBright.withValues(alpha: 0.85);
    canvas.drawCircle(c, r * 0.62, inner);
    final tp = TextPainter(
      text: TextSpan(
        text: '印',
        style: GoogleFonts.shipporiMincho(
          fontSize: r * 0.85,
          color: AppColors.bone,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RowSealPainter extends CustomPainter {
  final bool unlocked;
  _RowSealPainter({required this.unlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;

    final outerColor = unlocked
        ? AppColors.goldTarnish
        : AppColors.boneDim.withValues(alpha: 0.45);
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = outerColor;
    canvas.drawCircle(c, r * 0.94, outer);
    // 8 段の刻み
    for (int i = 0; i < 8; i++) {
      final a = (i / 8) * math.pi * 2;
      final p1 =
          Offset(c.dx + r * 0.94 * math.cos(a), c.dy + r * 0.94 * math.sin(a));
      final p2 =
          Offset(c.dx + r * 0.84 * math.cos(a), c.dy + r * 0.84 * math.sin(a));
      canvas.drawLine(p1, p2, outer);
    }

    final innerColor = unlocked
        ? AppColors.bloodBright.withValues(alpha: 0.85)
        : AppColors.boneDim.withValues(alpha: 0.45);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = innerColor;
    canvas.drawCircle(c, r * 0.62, inner);

    final tp = TextPainter(
      text: TextSpan(
        text: unlocked ? '印' : '？',
        style: GoogleFonts.shipporiMincho(
          fontSize: r * 0.85,
          color: unlocked
              ? AppColors.bone
              : AppColors.boneDim.withValues(alpha: 0.7),
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RowSealPainter oldDelegate) =>
      oldDelegate.unlocked != unlocked;
}
