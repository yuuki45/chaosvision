import 'package:hive/hive.dart';

part 'achievement_unlock.g.dart';

@HiveType(typeId: 1)
class AchievementUnlock {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime unlockedAt;

  @HiveField(2)
  final String? scannedObjectId;

  const AchievementUnlock({
    required this.id,
    required this.unlockedAt,
    this.scannedObjectId,
  });
}
