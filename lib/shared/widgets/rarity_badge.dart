import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RarityBadge extends StatelessWidget {
  final String rarity;
  final double size;

  const RarityBadge({
    super.key,
    required this.rarity,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedRarity = _normalizeRarity(rarity);
    final color = AppColors.rarityColors[normalizedRarity] ?? AppColors.primary;
    final starCount = _getStarCount(rarity);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.4,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size * 0.4),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            starCount,
            (index) => Icon(
              Icons.star,
              color: color,
              size: size * 0.6,
            ),
          ),
          if (starCount > 0) SizedBox(width: size * 0.2),
          Text(
            normalizedRarity,
            style: TextStyle(
              color: color,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeRarity(String rarity) {
    // 英語のレア度を日本語にマッピング
    const rarityMap = {
      'Common': 'コモン',
      'common': 'コモン',
      'COMMON': 'コモン',
      'Rare': 'レア',
      'rare': 'レア',
      'RARE': 'レア',
      'Epic': 'エピック',
      'epic': 'エピック',
      'EPIC': 'エピック',
      'Legendary': 'レジェンダリー',
      'legendary': 'レジェンダリー',
      'LEGENDARY': 'レジェンダリー',
      'Mythic': 'ミシック',
      'mythic': 'ミシック',
      'MYTHIC': 'ミシック',
      'Mythical': 'ミシック',
      'mythical': 'ミシック',
      'MYTHICAL': 'ミシック',
    };

    // 英語マッピングをチェック
    if (rarityMap.containsKey(rarity)) {
      return rarityMap[rarity]!;
    }

    // 既に日本語の場合はそのまま返す
    return rarity;
  }

  int _getStarCount(String rarity) {
    final normalizedRarity = _normalizeRarity(rarity);
    switch (normalizedRarity) {
      case 'コモン':
        return 1;
      case 'レア':
        return 2;
      case 'エピック':
        return 3;
      case 'レジェンダリー':
        return 4;
      case 'ミシック':
        return 5;
      default:
        return 0;
    }
  }
}