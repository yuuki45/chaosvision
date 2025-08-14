import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/memory_monitor_service.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ストレージサービスを初期化
  await StorageService.instance.initialize();
  
  // 画像キャッシュサービスを初期化
  ImageCacheService.instance.initialize();
  
  // メモリ監視サービスを初期化（積極的なメモリ管理）
  MemoryMonitorService.instance.initialize();
  // MemoryMonitorService.instance.startPeriodicMemoryCheck(); // フルチェックは無効（重いため）
  // MemoryMonitorService.instance.startAutoRecoveryCheck(); // 自動回復も無効化
  
  // iOSでのメモリ制限に対応するため、積極的に低メモリモードを有効化
  // MemoryMonitorService.instance.enableLowMemoryMode(); // 通常動作に戻すため無効化
  
  runApp(const ProviderScope(child: ChaosVisionApp()));
}

class ChaosVisionApp extends StatefulWidget {
  const ChaosVisionApp({super.key});

  @override
  State<ChaosVisionApp> createState() => _ChaosVisionAppState();
}

class _ChaosVisionAppState extends State<ChaosVisionApp> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    // メモリ警告時のクリーンアップのみ実行（節約モード切り替えは無効化）
    MemoryMonitorService.instance.forceMemoryCleanup();
    // MemoryMonitorService.instance.enableLowMemoryMode(); // 強制節約モード切り替えを無効化
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
