import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

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
  final String? imageUrl;
  
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
    this.imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
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
}