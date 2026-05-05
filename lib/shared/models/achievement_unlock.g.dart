// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_unlock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementUnlockAdapter extends TypeAdapter<AchievementUnlock> {
  @override
  final int typeId = 1;

  @override
  AchievementUnlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementUnlock(
      id: fields[0] as String,
      unlockedAt: fields[1] as DateTime,
      scannedObjectId: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementUnlock obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unlockedAt)
      ..writeByte(2)
      ..write(obj.scannedObjectId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementUnlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
