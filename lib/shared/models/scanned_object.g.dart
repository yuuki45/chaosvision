// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScannedObjectAdapter extends TypeAdapter<ScannedObject> {
  @override
  final int typeId = 0;

  @override
  ScannedObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScannedObject(
      id: fields[0] as String,
      objectCategory: fields[1] as String,
      alternateName: fields[2] as String,
      attribute: fields[3] as String,
      description: fields[4] as String,
      rarity: fields[5] as String,
      scannedAt: fields[6] as DateTime,
      imageUrl: fields[7] as String?,
      confidence: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ScannedObject obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.objectCategory)
      ..writeByte(2)
      ..write(obj.alternateName)
      ..writeByte(3)
      ..write(obj.attribute)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.rarity)
      ..writeByte(6)
      ..write(obj.scannedAt)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedObject _$ScannedObjectFromJson(Map<String, dynamic> json) =>
    ScannedObject(
      id: json['id'] as String,
      objectCategory: json['objectCategory'] as String,
      alternateName: json['alternateName'] as String,
      attribute: json['attribute'] as String,
      description: json['description'] as String,
      rarity: json['rarity'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ScannedObjectToJson(ScannedObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'objectCategory': instance.objectCategory,
      'alternateName': instance.alternateName,
      'attribute': instance.attribute,
      'description': instance.description,
      'rarity': instance.rarity,
      'scannedAt': instance.scannedAt.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'confidence': instance.confidence,
    };
