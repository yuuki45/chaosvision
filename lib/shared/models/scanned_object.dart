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
}