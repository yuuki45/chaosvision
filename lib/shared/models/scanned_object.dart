import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'scanned_object.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ScannedObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String objectCategory;
  
  @HiveField(2)
  final String alternateName;
  
  @HiveField(3)
  final String attribute;
  
  @HiveField(4)
  final String description;
  
  @HiveField(5)
  final String rarity;
  
  @HiveField(6)
  final DateTime scannedAt;
  
  @HiveField(7)
  final String? imageRelativePath; // 相対パスに変更
  
  @HiveField(8)
  final double confidence;

  const ScannedObject({
    required this.id,
    required this.objectCategory,
    required this.alternateName,
    required this.attribute,
    required this.description,
    required this.rarity,
    required this.scannedAt,
    this.imageRelativePath,
    this.confidence = 0.0,
  });

  factory ScannedObject.fromJson(Map<String, dynamic> json) =>
      _$ScannedObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedObjectToJson(this);

  ScannedObject copyWith({
    String? id,
    String? objectCategory,
    String? alternateName,
    String? attribute,
    String? description,
    String? rarity,
    DateTime? scannedAt,
    String? imageRelativePath,
    double? confidence,
  }) {
    return ScannedObject(
      id: id ?? this.id,
      objectCategory: objectCategory ?? this.objectCategory,
      alternateName: alternateName ?? this.alternateName,
      attribute: attribute ?? this.attribute,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      scannedAt: scannedAt ?? this.scannedAt,
      imageRelativePath: imageRelativePath ?? this.imageRelativePath,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScannedObject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 相対パスから絶対パスを動的に解決
  Future<String?> getFullImagePath() async {
    if (imageRelativePath == null) return null;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      // パス区切り文字を正規化
      final basePath = appDir.path.endsWith('/') ? appDir.path : '${appDir.path}/';
      final fullPath = '$basePath$imageRelativePath';
      
      debugPrint('ScannedObject: パス解決');
      debugPrint('  相対パス: $imageRelativePath');
      debugPrint('  ベースパス: $basePath');
      debugPrint('  絶対パス: $fullPath');
      
      // ファイルが存在するかチェック
      if (await File(fullPath).exists()) {
        debugPrint('  ファイル存在: true');
        return fullPath;
      }
      debugPrint('  ファイル存在: false');
      return null;
    } catch (e) {
      debugPrint('  エラー: $e');
      return null;
    }
  }

  /// 画像ファイルが存在するかチェック
  Future<bool> imageExists() async {
    final path = await getFullImagePath();
    return path != null;
  }

  /// 霊力濃度 (AETHER DENSITY) — 0.0..1.0
  ///
  /// 旧 confidence フィールドの代わりに、神器固有の "霊的測定値" を
  /// 演出用に算出する。同じ神器なら何度開いても同じ値が出るよう、
  /// id のハッシュとレア度ランクから決定論的に導出している。
  double get aetherDensity {
    final hash = id.hashCode.abs();
    final base = 55 + (hash % 26); // 55..80
    final rarityBoost = _rarityRank() * 5; // 0..25
    final value = (base + rarityBoost).clamp(0, 99);
    return value / 100.0;
  }

  /// 共鳴強度 (RESONANCE) — 0.0..1.0
  ///
  /// 神器が属性と共鳴する強さの演出値。aether とは別の hash 基底を
  /// 使って独立した値を出す。属性が「無」のときはやや低め。
  double get resonance {
    final hash = ((id.hashCode.abs()) >> 7) ^ attribute.hashCode;
    final base = 40 + (hash.abs() % 41); // 40..80
    final voidPenalty = attribute == '無' ? -10 : 0;
    final value = (base + voidPenalty).clamp(20, 95);
    return value / 100.0;
  }

  int _rarityRank() {
    final normalized = _normalizeRarityForRank(rarity);
    switch (normalized) {
      case 'ミシック':
        return 5;
      case 'レジェンダリー':
        return 4;
      case 'エピック':
        return 3;
      case 'レア':
        return 2;
      case 'コモン':
        return 1;
      default:
        return 0;
    }
  }

  String _normalizeRarityForRank(String r) {
    const map = {
      'Common': 'コモン', 'common': 'コモン', 'COMMON': 'コモン',
      'Rare': 'レア', 'rare': 'レア', 'RARE': 'レア',
      'Epic': 'エピック', 'epic': 'エピック', 'EPIC': 'エピック',
      'Legendary': 'レジェンダリー', 'legendary': 'レジェンダリー',
      'LEGENDARY': 'レジェンダリー',
      'Mythic': 'ミシック', 'mythic': 'ミシック', 'MYTHIC': 'ミシック',
      'Mythical': 'ミシック', 'mythical': 'ミシック',
    };
    return map[r] ?? r;
  }
}