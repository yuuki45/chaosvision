import 'package:flutter/material.dart';

class AppColors {
  // メインカラー（ダークテーマ）
  static const Color primary = Color(0xFFD4AF37); // ゴールド
  static const Color primaryDark = Color(0xFFB8860B); // ダークゴールド
  static const Color secondary = Color(0xFF9370DB); // 紫
  static const Color secondaryDark = Color(0xFF663399); // ダーク紫
  
  // 背景色
  static const Color background = Color(0xFF0D0D0D); // ダークブラック
  static const Color surface = Color(0xFF1A1A1A); // ダークグレー
  static const Color surfaceVariant = Color(0xFF2D2D2D); // ミディアムグレー
  
  // テキスト色
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFE0E0E0);
  
  // 属性カラー
  static const Map<String, Color> attributeColors = {
    '炎': Color(0xFFFF4444), // 赤
    '氷': Color(0xFF44AAFF), // 青
    '雷': Color(0xFFFFFF44), // 黄
    '闇': Color(0xFF9966CC), // 明るい紫
    '光': Color(0xFFFFFFAA), // 明黄
    '風': Color(0xFF44FF88), // 緑
    '地': Color(0xFFAA7744), // 茶
    '水': Color(0xFF4488FF), // 水色
    '無': Color(0xFF888888), // グレー
  };
  
  // レア度カラー
  static const Map<String, Color> rarityColors = {
    'コモン': Color(0xFF888888),
    'レア': Color(0xFF4488FF),
    'エピック': Color(0xFF8844FF),
    'レジェンダリー': Color(0xFFFF8844),
    'ミシック': Color(0xFFFF4488),
  };
  
  // UI状態
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);
  
  // エフェクト
  static const Color magicCircle = Color(0xFFD4AF37);
  static const Color scanBeam = Color(0xFF9370DB);
  static const Color glowEffect = Color(0xFFFFFFFF);

  // ─── Forbidden Codex palette (v2 home) ───
  static const Color inkBlack = Color(0xFF0A0805);
  static const Color inkDeeper = Color(0xFF050302);
  static const Color blood = Color(0xFF8B1A1A);
  static const Color bloodBright = Color(0xFFC8102E);
  static const Color goldTarnish = Color(0xFFA18540);
  static const Color goldLeaf = Color(0xFFD4AF37);
  static const Color bone = Color(0xFFE8DCC4);
  static const Color boneDim = Color(0xFF6B5F4D);
  static const Color violetDeep = Color(0xFF2D1A4F);
  static const Color frost = Color(0xFF7FBED1);
  static const Color frostDeep = Color(0xFF3A6B7E);
}