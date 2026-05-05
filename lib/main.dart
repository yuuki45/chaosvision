import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/services/achievement_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/memory_monitor_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen_v2.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ストレージサービスを初期化
  await StorageService.instance.initialize();

  // アチーブメントサービスを初期化（StorageService の Hive.initFlutter 後に呼ぶ）
  await AchievementService.instance.initialize();

  // 画像キャッシュサービスを初期化
  ImageCacheService.instance.initialize();

  // メモリ監視サービスを初期化（積極的なメモリ管理）
  MemoryMonitorService.instance.initialize();
  // MemoryMonitorService.instance.startPeriodicMemoryCheck(); // フルチェックは無効（重いため）
  // MemoryMonitorService.instance.startAutoRecoveryCheck(); // 自動回復も無効化

  // iOSでのメモリ制限に対応するため、積極的に低メモリモードを有効化
  // MemoryMonitorService.instance.enableLowMemoryMode(); // 通常動作に戻すため無効化

  // 初回起動かどうかを起動前に確定して、splash → onboarding / home の
  // ちらつきを避ける。
  // FORCE_ONBOARDING=true の dart-define が指定されていれば、保存済みフラグを
  // 無視して常にオンボーディングを表示する（実機反復テスト用）。
  const forceOnboarding =
      bool.fromEnvironment('FORCE_ONBOARDING', defaultValue: false);
  bool isFirstLaunch;
  if (forceOnboarding) {
    isFirstLaunch = true;
  } else {
    try {
      final prefs = await SharedPreferences.getInstance();
      isFirstLaunch = prefs.getBool(AppConstants.prefKeyFirstLaunch) ?? true;
    } catch (_) {
      isFirstLaunch = true;
    }
  }

  runApp(
    ProviderScope(
      child: ChaosVisionApp(
        isFirstLaunch: isFirstLaunch,
        persistOnboardingCompletion: !forceOnboarding,
      ),
    ),
  );
}

class ChaosVisionApp extends StatefulWidget {
  final bool isFirstLaunch;
  final bool persistOnboardingCompletion;
  const ChaosVisionApp({
    super.key,
    required this.isFirstLaunch,
    this.persistOnboardingCompletion = true,
  });

  @override
  State<ChaosVisionApp> createState() => _ChaosVisionAppState();
}

class _ChaosVisionAppState extends State<ChaosVisionApp>
    with WidgetsBindingObserver {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _showOnboarding = widget.isFirstLaunch;
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

  void _onboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      color: AppColors.inkDeeper,
      home: _showOnboarding
          ? OnboardingScreen(
              onComplete: _onboardingComplete,
              persistCompletion: widget.persistOnboardingCompletion,
            )
          : const HomeScreenV2(),
      debugShowCheckedModeBanner: false,
    );
  }
}
