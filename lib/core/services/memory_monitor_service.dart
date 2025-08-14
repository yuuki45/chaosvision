import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'image_cache_service.dart';

class MemoryMonitorService {
  static MemoryMonitorService? _instance;
  static MemoryMonitorService get instance => _instance ??= MemoryMonitorService._();
  MemoryMonitorService._();

  bool _isLowMemoryMode = false;
  bool _isInitialized = false;
  
  // メモリ圧迫検出のコールバック
  final List<VoidCallback> _memoryPressureCallbacks = [];
  
  /// 低メモリモードかどうか
  bool get isLowMemoryMode => _isLowMemoryMode;
  
  /// 初期化
  void initialize() {
    if (_isInitialized) return;
    
    // iOS/Androidの場合のみメモリ監視を有効化
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      _setupMemoryMonitoring();
    }
    
    _isInitialized = true;
    debugPrint('Memory monitor service initialized');
  }
  
  /// メモリ監視の設定
  void _setupMemoryMonitoring() {
    // システムのメモリ警告を監視
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == 'AppLifecycleState.paused' || 
          message == 'AppLifecycleState.detached') {
        _triggerMemoryCleanup();
      }
      return null;
    });
  }
  
  /// 低メモリモードを強制的に有効化
  void enableLowMemoryMode() {
    if (_isLowMemoryMode) return;
    
    _isLowMemoryMode = true;
    debugPrint('🚨 Low memory mode ENABLED - Heavy features disabled');
    
    // 即座にメモリクリーンアップを実行
    _triggerMemoryCleanup();
  }
  
  /// 低メモリモードを無効化
  void disableLowMemoryMode() {
    _isLowMemoryMode = false;
    debugPrint('✅ Low memory mode disabled');
  }
  
  /// メモリ圧迫時のコールバックを登録
  void addMemoryPressureCallback(VoidCallback callback) {
    _memoryPressureCallbacks.add(callback);
  }
  
  /// メモリ圧迫時のコールバックを削除
  void removeMemoryPressureCallback(VoidCallback callback) {
    _memoryPressureCallbacks.remove(callback);
  }
  
  /// メモリクリーンアップを実行
  void _triggerMemoryCleanup() {
    debugPrint('🧹 Triggering aggressive memory cleanup');
    
    // 画像キャッシュをクリーンアップ
    ImageCacheService.instance.onMemoryPressure();
    
    // すべてのコールバックを実行
    for (final callback in _memoryPressureCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in memory pressure callback: $e');
      }
    }
    
    // ガベージコレクションを促す
    if (!kIsWeb) {
      SystemChannels.platform.invokeMethod('SystemNavigator.routeUpdated');
    }
  }
  
  /// 手動でメモリクリーンアップを実行
  void forceMemoryCleanup() {
    debugPrint('🔥 Manual memory cleanup requested');
    _triggerMemoryCleanup();
  }
  
  /// デバイスの利用可能メモリを取得（プラットフォーム依存）
  Future<Map<String, dynamic>> getMemoryInfo() async {
    try {
      if (Platform.isIOS) {
        // iOSの場合は簡易的な情報のみ
        return {
          'platform': 'iOS',
          'isLowMemoryMode': _isLowMemoryMode,
          'cacheStats': ImageCacheService.instance.getCacheStats(),
        };
      } else if (Platform.isAndroid) {
        // Androidの場合も簡易的な情報のみ
        return {
          'platform': 'Android',
          'isLowMemoryMode': _isLowMemoryMode,
          'cacheStats': ImageCacheService.instance.getCacheStats(),
        };
      }
    } catch (e) {
      debugPrint('Error getting memory info: $e');
    }
    
    return {
      'platform': 'Unknown',
      'isLowMemoryMode': _isLowMemoryMode,
    };
  }
  
  /// メモリ使用量の推定値を取得
  double getEstimatedMemoryUsage() {
    final cacheStats = ImageCacheService.instance.getCacheStats();
    final imageCacheSize = cacheStats['totalSize'] as int;
    
    // 画像キャッシュ + その他の推定使用量
    final totalBytes = imageCacheSize + (10 * 1024 * 1024); // +10MB for other components
    return totalBytes / (1024 * 1024); // MB単位で返す
  }
  
  /// メモリ使用量が危険レベルかチェック
  bool isDangerousMemoryLevel() {
    final usageMB = getEstimatedMemoryUsage();
    
    // iOS の場合、60MB以上は危険レベル
    if (Platform.isIOS && usageMB > 60.0) {
      return true;
    }
    
    // Android の場合は100MB以上
    if (Platform.isAndroid && usageMB > 100.0) {
      return true;
    }
    
    return false;
  }
  
  /// メモリ使用量が安全レベルかチェック（自動回復用）
  bool isSafeMemoryLevel() {
    final usageMB = getEstimatedMemoryUsage();
    
    // iOS の場合、40MB以下は安全レベル
    if (Platform.isIOS && usageMB <= 40.0) {
      return true;
    }
    
    // Android の場合は70MB以下
    if (Platform.isAndroid && usageMB <= 70.0) {
      return true;
    }
    
    return false;
  }
  
  /// 定期的なメモリチェックを開始（危険レベル検出＋自動回復）
  void startPeriodicMemoryCheck() {
    // 30秒ごとにメモリ使用量をチェック
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (isDangerousMemoryLevel() && !_isLowMemoryMode) {
        debugPrint('⚠️ Dangerous memory level detected, enabling low memory mode');
        enableLowMemoryMode();
      } else if (isSafeMemoryLevel() && _isLowMemoryMode) {
        debugPrint('✅ Safe memory level detected, disabling low memory mode');
        disableLowMemoryMode();
      }
    });
  }
  
  /// 自動回復機能のみの軽量な定期チェック
  void startAutoRecoveryCheck() {
    // 1分ごとに自動回復のみチェック（より軽量）
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      if (isSafeMemoryLevel() && _isLowMemoryMode) {
        debugPrint('🔄 Auto recovery: Safe memory level detected, disabling low memory mode');
        disableLowMemoryMode();
      }
    });
  }
}