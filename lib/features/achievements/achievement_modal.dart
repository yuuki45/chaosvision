import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'achievement_catalog.dart';

/// アチーブ解除モーダル。push 形式で表示。
/// バリア越しタップでは閉じない（中央の「結 ぶ」ボタンで閉じる）。
Future<void> showAchievementUnlockModal(
  BuildContext context,
  Achievement achievement,
) {
  HapticFeedback.mediumImpact();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.inkDeeper.withValues(alpha: 0.86),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, __, ___) => _AchievementUnlockDialog(achievement),
    transitionBuilder: (_, anim, __, child) {
      final eased = Curves.easeOutCubic.transform(anim.value);
      return Opacity(
        opacity: anim.value,
        child: Transform.scale(
          scale: 0.92 + 0.08 * eased,
          child: child,
        ),
      );
    },
  );
}

class _AchievementUnlockDialog extends StatefulWidget {
  final Achievement achievement;
  const _AchievementUnlockDialog(this.achievement);

  @override
  State<_AchievementUnlockDialog> createState() =>
      _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<_AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.inkBlack,
            border: Border.all(color: AppColors.goldTarnish, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _topTag(),
              const SizedBox(height: 22),
              SizedBox(
                width: 124,
                height: 124,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    painter: _SealStampPainter(progress: _ctrl.value),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _category(a.category),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  a.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 18,
                    color: AppColors.bone,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                a.englishTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.bodoniModa(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.goldLeaf,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 32,
                height: 1,
                color: AppColors.goldTarnish.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                a.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.shipporiMincho(
                  fontSize: 12,
                  color: AppColors.bone.withValues(alpha: 0.8),
                  letterSpacing: 2,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 26),
              _confirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topTag() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 18, height: 1, color: AppColors.goldTarnish),
          const SizedBox(width: 8),
          Text(
            '印 を 授 け ら れ し',
            style: GoogleFonts.shipporiMincho(
              fontSize: 10,
              color: AppColors.goldLeaf,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 8, height: 1, color: AppColors.goldTarnish),
          const SizedBox(width: 8),
          Text(
            'SEAL GRANTED',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: AppColors.goldTarnish,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 18, height: 1, color: AppColors.goldTarnish),
        ],
      ),
    );
  }

  Widget _category(AchievementCategory c) {
    final (jp, en) = switch (c) {
      AchievementCategory.quantity => ('蒐 集', 'GATHERING'),
      AchievementCategory.rarity => ('位 階', 'TIER'),
      AchievementCategory.attribute => ('属 性', 'ELEMENT'),
      AchievementCategory.event => ('刻 限', 'AUSPICE'),
      AchievementCategory.hidden => ('秘 印', 'OCCULT SEAL'),
    };
    return Text(
      '— $jp · $en —',
      style: GoogleFonts.bodoniModa(
        fontSize: 9,
        fontStyle: FontStyle.italic,
        color: AppColors.boneDim,
        letterSpacing: 3,
      ),
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.bloodBright, width: 1.2),
          color: AppColors.blood.withValues(alpha: 0.32),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '了',
                style: GoogleFonts.shipporiMincho(
                  fontSize: 16,
                  color: AppColors.bone,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              Container(width: 16, height: 1, color: AppColors.bloodBright),
              const SizedBox(width: 14),
              Text(
                'ACKNOWLEDGE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.bloodBright,
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 円形の封蝋スタンプ風ペインター。0..1 の progress で
/// 外周ライン → 内輪 → 中央漢字 の順にフェードイン。
class _SealStampPainter extends CustomPainter {
  final double progress;
  _SealStampPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;

    final t1 = (progress / 0.45).clamp(0.0, 1.0);
    final t2 = ((progress - 0.35) / 0.45).clamp(0.0, 1.0);
    final t3 = ((progress - 0.65) / 0.35).clamp(0.0, 1.0);

    // 外周: 12 段の刻み
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.goldTarnish.withValues(alpha: 0.85 * t1);
    canvas.drawCircle(center, r * 0.96, outerPaint);
    final tickPaint = Paint()
      ..color = AppColors.goldTarnish.withValues(alpha: 0.85 * t1)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 12; i++) {
      final a = (i / 12) * math.pi * 2;
      final p1 =
          Offset(center.dx + r * 0.96 * math.cos(a), center.dy + r * 0.96 * math.sin(a));
      final p2 =
          Offset(center.dx + r * 0.88 * math.cos(a), center.dy + r * 0.88 * math.sin(a));
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 内輪: 二重円 (蝋印の隆起)
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.bloodBright.withValues(alpha: 0.85 * t2);
    canvas.drawCircle(center, r * 0.74, innerPaint);
    final innerThin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = AppColors.bloodBright.withValues(alpha: 0.55 * t2);
    canvas.drawCircle(center, r * 0.66, innerThin);

    // 中央: 大漢字「印」
    final tp = TextPainter(
      text: TextSpan(
        text: '印',
        style: GoogleFonts.shipporiMincho(
          fontSize: r * 0.78,
          color: AppColors.bone.withValues(alpha: t3),
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );

    // 中央クロスヘア
    final cross = Paint()
      ..color = AppColors.goldLeaf.withValues(alpha: 0.55 * t1)
      ..strokeWidth = 0.6;
    canvas.drawLine(
      Offset(center.dx - r * 0.96, center.dy),
      Offset(center.dx - r * 0.82, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx + r * 0.82, center.dy),
      Offset(center.dx + r * 0.96, center.dy),
      cross,
    );
  }

  @override
  bool shouldRepaint(covariant _SealStampPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
