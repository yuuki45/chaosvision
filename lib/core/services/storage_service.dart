import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/scanned_object.dart';
import '../constants/app_constants.dart';

// ページネーション結果クラス
class PaginatedResult {
  final List<ScannedObject> objects;
  final int totalCount;
  final bool hasMore;

  PaginatedResult({
    required this.objects,
    required this.totalCount,
    required this.hasMore,
  });
}

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  Box<ScannedObject>? _scannedObjectsBox;
  SharedPreferences? _prefs;

  Future<bool> initialize() async {
    try {
      // Hiveを初期化
      await Hive.initFlutter();
      
      // ScannedObjectアダプターを登録（既に登録されていない場合のみ）
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ScannedObjectAdapter());
      }

      // Boxを開く
      _scannedObjectsBox = await Hive.openBox<ScannedObject>('scanned_objects');

      // SharedPreferencesを初期化
      _prefs = await SharedPreferences.getInstance();

      debugPrint('Storage service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing storage service: $e');
      return false;
    }
  }

  // スキャンしたオブジェクトを保存
  Future<bool> saveScannedObject(ScannedObject object) async {
    try {
      if (_scannedObjectsBox == null) {
        debugPrint('Storage not initialized');
        return false;
      }

      await _scannedObjectsBox!.put(object.id, object);
      debugPrint('Scanned object saved: ${object.alternateName}');
      return true;
    } catch (e) {
      debugPrint('Error saving scanned object: $e');
      return false;
    }
  }

  // 全てのスキャンオブジェクトを取得（ページネーション対応）
  List<ScannedObject> getAllScannedObjects({int? limit, int? offset}) {
    if (_scannedObjectsBox == null) {
      return [];
    }

    final allObjects = _scannedObjectsBox!.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    
    if (limit == null) {
      return allObjects;
    }
    
    final startIndex = offset ?? 0;
    final endIndex = (startIndex + limit).clamp(0, allObjects.length);
    
    if (startIndex >= allObjects.length) {
      return [];
    }
    
    return allObjects.sublist(startIndex, endIndex);
  }

  // 総数を取得
  int getTotalObjectCount() {
    if (_scannedObjectsBox == null) {
      return 0;
    }
    return _scannedObjectsBox!.length;
  }

  // フィルタリング付きページネーション（メモリ節約のため削減）
  PaginatedResult getObjectsWithFilters({
    int limit = 10, // 20 → 10に削減
    int offset = 0,
    String? attributeFilter,
    String? rarityFilter,
    String? searchQuery,
  }) {
    if (_scannedObjectsBox == null) {
      return PaginatedResult(objects: [], totalCount: 0, hasMore: false);
    }

    // 全オブジェクトを取得してソート
    final allObjects = _scannedObjectsBox!.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

    // フィルタリング適用
    final filteredObjects = allObjects.where((object) {
      // 属性フィルター
      bool attributeMatch = attributeFilter == null || 
                          attributeFilter == 'すべて' || 
                          object.attribute == attributeFilter;
      
      // レア度フィルター（正規化対応）
      bool rarityMatch = rarityFilter == null || 
                       rarityFilter == 'すべて' || 
                       _normalizeRarity(object.rarity) == rarityFilter;
      
      // 検索クエリフィルター
      bool searchMatch = searchQuery == null ||
                       searchQuery.isEmpty ||
                       object.objectCategory.contains(searchQuery) ||
                       object.alternateName.contains(searchQuery) ||
                       object.description.contains(searchQuery);
      
      return attributeMatch && rarityMatch && searchMatch;
    }).toList();

    // ページネーション適用
    final totalCount = filteredObjects.length;
    final startIndex = offset;
    final endIndex = (startIndex + limit).clamp(0, totalCount);
    
    List<ScannedObject> pageObjects = [];
    if (startIndex < totalCount) {
      pageObjects = filteredObjects.sublist(startIndex, endIndex);
    }
    
    final hasMore = endIndex < totalCount;

    return PaginatedResult(
      objects: pageObjects,
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }

  // IDでスキャンオブジェクトを取得
  ScannedObject? getScannedObjectById(String id) {
    if (_scannedObjectsBox == null) {
      return null;
    }

    return _scannedObjectsBox!.get(id);
  }

  // スキャンオブジェクトを削除
  Future<bool> deleteScannedObject(String id) async {
    try {
      if (_scannedObjectsBox == null) {
        return false;
      }

      await _scannedObjectsBox!.delete(id);
      debugPrint('Scanned object deleted: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting scanned object: $e');
      return false;
    }
  }

  // 属性でフィルタリング
  List<ScannedObject> getObjectsByAttribute(String attribute) {
    final allObjects = getAllScannedObjects();
    return allObjects.where((obj) => obj.attribute == attribute).toList();
  }

  // レア度でフィルタリング（正規化対応）
  List<ScannedObject> getObjectsByRarity(String rarity) {
    final allObjects = getAllScannedObjects();
    return allObjects.where((obj) => _normalizeRarity(obj.rarity) == rarity).toList();
  }

  // カテゴリでフィルタリング
  List<ScannedObject> getObjectsByCategory(String category) {
    final allObjects = getAllScannedObjects();
    return allObjects.where((obj) => obj.objectCategory == category).toList();
  }

  // 設定値を保存
  Future<bool> setBool(String key, bool value) async {
    try {
      if (_prefs == null) return false;
      return await _prefs!.setBool(key, value);
    } catch (e) {
      debugPrint('Error setting bool preference: $e');
      return false;
    }
  }

  // 設定値を取得
  bool getBool(String key, {bool defaultValue = false}) {
    if (_prefs == null) return defaultValue;
    return _prefs!.getBool(key) ?? defaultValue;
  }

  // 文字列設定値を保存
  Future<bool> setString(String key, String value) async {
    try {
      if (_prefs == null) return false;
      return await _prefs!.setString(key, value);
    } catch (e) {
      debugPrint('Error setting string preference: $e');
      return false;
    }
  }

  // 文字列設定値を取得
  String getString(String key, {String defaultValue = ''}) {
    if (_prefs == null) return defaultValue;
    return _prefs!.getString(key) ?? defaultValue;
  }

  // アプリが初回起動かどうか
  bool get isFirstLaunch => getBool(AppConstants.prefKeyFirstLaunch, defaultValue: true);

  // 初回起動フラグを更新
  Future<void> setFirstLaunchCompleted() async {
    await setBool(AppConstants.prefKeyFirstLaunch, false);
  }

  // 音声効果の設定
  bool get isSoundEnabled => getBool(AppConstants.prefKeySoundEnabled, defaultValue: true);

  Future<void> setSoundEnabled(bool enabled) async {
    await setBool(AppConstants.prefKeySoundEnabled, enabled);
  }

  // 視覚効果の設定
  bool get isEffectsEnabled => getBool(AppConstants.prefKeyEffectsEnabled, defaultValue: true);

  Future<void> setEffectsEnabled(bool enabled) async {
    await setBool(AppConstants.prefKeyEffectsEnabled, enabled);
  }

  // 統計情報
  int get totalScannedCount => getTotalObjectCount();

  Map<String, int> get attributeStats {
    final objects = getAllScannedObjects();
    final stats = <String, int>{};
    
    for (final attribute in AppConstants.attributes) {
      stats[attribute] = objects.where((obj) => obj.attribute == attribute).length;
    }
    
    return stats;
  }

  Map<String, int> get rarityStats {
    final objects = getAllScannedObjects();
    final stats = <String, int>{};
    
    for (final rarity in AppConstants.rarityLevels) {
      stats[rarity] = objects.where((obj) => _normalizeRarity(obj.rarity) == rarity).length;
    }
    
    return stats;
  }

  // データベースをクリア（開発用）
  Future<bool> clearAllData() async {
    try {
      if (_scannedObjectsBox == null) return false;
      
      await _scannedObjectsBox!.clear();
      debugPrint('All scanned objects cleared');
      return true;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }

  /// レア度を日本語に正規化
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

  void dispose() {
    _scannedObjectsBox?.close();
  }
}