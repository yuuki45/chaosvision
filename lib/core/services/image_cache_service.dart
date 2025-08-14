import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class ImageCacheService {
  static ImageCacheService? _instance;
  static ImageCacheService get instance => _instance ??= ImageCacheService._();
  ImageCacheService._();

  // キャッシュサイズ制限（大幅削減）
  static const int _maxCacheSize = 20 * 1024 * 1024; // 20MB（50MB→20MB）
  static const int _maxCacheCount = 50; // 最大50枚（100枚→50枚）
  
  final Map<String, _CacheEntry> _cache = {};
  int _currentCacheSize = 0;

  /// 画像をキャッシュに追加
  void addToCache(String path, Uint8List imageData) {
    if (_cache.containsKey(path)) {
      // 既にキャッシュされている場合はアクセス時間を更新
      _cache[path]!.lastAccessed = DateTime.now();
      return;
    }

    final size = imageData.length;
    
    // キャッシュサイズが制限を超える場合は古いものを削除
    _evictOldEntries(size);

    _cache[path] = _CacheEntry(
      data: imageData,
      size: size,
      lastAccessed: DateTime.now(),
    );
    _currentCacheSize += size;

    debugPrint('Image cached: $path (Size: ${size}B, Total: ${_currentCacheSize}B)');
  }

  /// キャッシュから画像を取得
  Uint8List? getFromCache(String path) {
    final entry = _cache[path];
    if (entry != null) {
      entry.lastAccessed = DateTime.now();
      return entry.data;
    }
    return null;
  }

  /// 古いキャッシュエントリを削除
  void _evictOldEntries(int newEntrySize) {
    // 個数制限チェック
    while (_cache.length >= _maxCacheCount) {
      _removeOldestEntry();
    }

    // サイズ制限チェック
    while (_currentCacheSize + newEntrySize > _maxCacheSize && _cache.isNotEmpty) {
      _removeOldestEntry();
    }
  }

  /// 最も古いエントリを削除
  void _removeOldestEntry() {
    if (_cache.isEmpty) return;

    // 最も古いアクセス時間のエントリを見つける
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestTime = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      final removedEntry = _cache.remove(oldestKey)!;
      _currentCacheSize -= removedEntry.size;
      debugPrint('Evicted old cache entry: $oldestKey (Size: ${removedEntry.size}B)');
    }
  }

  /// 特定のパスのキャッシュを削除
  void removeFromCache(String path) {
    final entry = _cache.remove(path);
    if (entry != null) {
      _currentCacheSize -= entry.size;
      debugPrint('Removed from cache: $path (Size: ${entry.size}B)');
    }
  }

  /// キャッシュをクリア
  void clearCache() {
    _cache.clear();
    _currentCacheSize = 0;
    debugPrint('Image cache cleared');
  }

  /// キャッシュ統計
  Map<String, dynamic> getCacheStats() {
    return {
      'entryCount': _cache.length,
      'totalSize': _currentCacheSize,
      'maxSize': _maxCacheSize,
      'maxCount': _maxCacheCount,
      'usage': (_currentCacheSize / _maxCacheSize * 100).toStringAsFixed(1) + '%',
    };
  }

  /// メモリ圧迫時のキャッシュクリーンアップ
  void onMemoryPressure() {
    // メモリ圧迫時は半分のキャッシュを削除
    final targetCount = _cache.length ~/ 2;
    
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

    for (int i = 0; i < targetCount && i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      _cache.remove(entry.key);
      _currentCacheSize -= entry.value.size;
    }

    debugPrint('Memory pressure cleanup: removed $targetCount entries');
  }

  /// Flutter の ImageCache と連携してサイズ制限
  void optimizeFlutterImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    // Flutter の ImageCache のサイズを制限（さらに削減）
    imageCache.maximumSize = 25; // 25枚まで（50枚→25枚）
    imageCache.maximumSizeBytes = 15 * 1024 * 1024; // 15MB まで（30MB→15MB）
    
    debugPrint('Flutter ImageCache optimized: ${imageCache.maximumSize} images, ${imageCache.maximumSizeBytes}B');
  }

  /// 初期化時に呼び出す
  void initialize() {
    optimizeFlutterImageCache();
    
    // メモリ警告の監視（iOS/Android）
    if (!kIsWeb) {
      // アプリのライフサイクル監視は呼び出し元で実装
    }
  }
}

class _CacheEntry {
  final Uint8List data;
  final int size;
  DateTime lastAccessed;

  _CacheEntry({
    required this.data,
    required this.size,
    required this.lastAccessed,
  });
}