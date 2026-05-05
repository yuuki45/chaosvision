import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/achievements/achievement_catalog.dart';
import '../../shared/models/achievement_unlock.dart';

class AchievementService {
  static AchievementService? _instance;
  static AchievementService get instance =>
      _instance ??= AchievementService._();
  AchievementService._();

  static const _boxName = 'achievement_unlocks';

  Box<AchievementUnlock>? _box;

  Future<bool> initialize() async {
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(AchievementUnlockAdapter());
      }
      _box = await Hive.openBox<AchievementUnlock>(_boxName);
      debugPrint('AchievementService initialized: ${_box?.length} unlocks');
      return true;
    } catch (e) {
      debugPrint('AchievementService init error: $e');
      return false;
    }
  }

  bool isUnlocked(String id) => _box?.containsKey(id) ?? false;

  AchievementUnlock? unlockOf(String id) => _box?.get(id);

  /// 解除済みアチーブを返す（unlockedAt 降順）
  List<AchievementUnlock> allUnlocks() {
    if (_box == null) return const [];
    final list = _box!.values.toList();
    list.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return list;
  }

  int get unlockedCount => _box?.length ?? 0;
  int get totalCount => achievementCatalog.length;

  /// 全アチーブを評価し、新規解除された Achievement のリストを返す。
  /// 既に解除済みのものはスキップ。
  Future<List<Achievement>> evaluateAndUnlock(
    AchievementCheckContext ctx, {
    String? scannedObjectId,
  }) async {
    if (_box == null) return const [];
    final newly = <Achievement>[];
    final now = DateTime.now();
    for (final a in achievementCatalog) {
      if (isUnlocked(a.id)) continue;
      if (!a.check(ctx)) continue;
      await _box!.put(
        a.id,
        AchievementUnlock(
          id: a.id,
          unlockedAt: now,
          scannedObjectId: scannedObjectId,
        ),
      );
      newly.add(a);
      debugPrint('Achievement unlocked: ${a.id} / ${a.title}');
    }
    return newly;
  }

  /// 開発用 — 全解除を消去
  Future<void> clearAll() async {
    await _box?.clear();
  }
}
