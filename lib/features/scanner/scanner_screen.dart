import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_colors.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/magic_circle_widget.dart';
import '../scan_result/scan_result_screen.dart';
import '../../shared/models/scanned_object.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final AIService _aiService = AIService();
  final StorageService _storageService = StorageService.instance;

  bool _isInitialized = false;
  bool _isScanning = false;
  
  late AnimationController _scanAnimationController;
  late AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimationController.dispose();
    _pulseAnimationController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // シンプルなライフサイクル管理
    if (state == AppLifecycleState.paused && _isInitialized) {
      _cameraService.dispose();
      setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed && !_isInitialized) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('カメラを初期化中...');
      final initialized = await _cameraService.initialize();
      
      if (initialized) {
        setState(() => _isInitialized = true);
        debugPrint('カメラ初期化完了');
      } else {
        _showCameraPermissionDialog();
      }
    } catch (e) {
      debugPrint('カメラ初期化エラー: $e');
      _showError('カメラの初期化に失敗しました');
    }
  }

  Future<String?> _saveImageToAppDirectory(String sourcePath) async {
    try {
      // アプリ専用のドキュメントディレクトリを取得
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'scanned_images'));
      
      // ディレクトリが存在しない場合は作成
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // ユニークなファイル名を生成
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'scanned_$timestamp.jpg';
      final savedImagePath = path.join(imagesDir.path, fileName);
      
      // 元画像をコピー
      final sourceFile = File(sourcePath);
      await sourceFile.copy(savedImagePath);
      
      debugPrint('画像を保存しました: $savedImagePath');
      return savedImagePath;
    } catch (e) {
      debugPrint('画像保存エラー: $e');
      return null;
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isScanning || !_isInitialized) return;

    setState(() => _isScanning = true);
    _scanAnimationController.forward();

    try {
      debugPrint('写真撮影開始...');
      
      // 写真を撮影
      final image = await _cameraService.takePicture();
      if (image == null) {
        _showError('写真の撮影に失敗しました');
        return;
      }

      // 画像をアプリ専用ディレクトリに保存
      final savedImagePath = await _saveImageToAppDirectory(image.path);
      if (savedImagePath == null) {
        _showError('画像の保存に失敗しました');
        return;
      }

      debugPrint('神器の真名を解読中...');
      
      // AIで画像を解析して物体認識 + 中二病名前生成
      final aiResult = await _aiService.analyzeImageAndGenerate(image.path);
      
      if (aiResult == null) {
        _showError('画像の解析に失敗しました。もう一度お試しください。');
        return;
      }

      // スキャン結果を作成（保存した画像パスを使用）
      final scannedObject = ScannedObject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        objectCategory: aiResult['objectCategory'] ?? '未知の物体',
        alternateName: aiResult['alternateName'] ?? '謎めいた神器',
        attribute: aiResult['attribute'] ?? '無',
        description: aiResult['description'] ?? '不思議な力を秘めた神器',
        rarity: aiResult['rarity'] ?? 'コモン',
        scannedAt: DateTime.now(),
        imageUrl: savedImagePath, // 保存したパスを使用
        confidence: 0.95, // AI分析なので高い信頼度
      );

      // StorageServiceに保存
      await _storageService.saveScannedObject(scannedObject);

      // 結果画面に遷移
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(scannedObject: scannedObject),
          ),
        );
      }
    } catch (e) {
      debugPrint('スキャンエラー: $e');
      _showError('スキャンエラー: $e');
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
        _scanAnimationController.reset();
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCameraPermissionDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('カメラ権限が必要です'),
          content: const Text(
            'CHAOS VISIONでは物体をスキャンするためにカメラを使用します。\n\n'
            'アプリを削除して再インストールすると、カメラ権限の許可画面が再表示されます。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('戻る'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeCamera();
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラプレビューまたはローディング画面
          if (_isInitialized && _cameraService.controller != null)
            SizedBox.expand(
              child: CameraPreview(_cameraService.controller!),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      _isInitialized ? '神器探知装置準備中...' : '異界の扉を開いています...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    if (!_isInitialized) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        child: const Text('再試行'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // 中央のスキャンフレーム
          if (_isInitialized)
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // コーナー装飾
                    ...List.generate(4, (index) {
                      return Positioned(
                        top: index < 2 ? 8 : null,
                        bottom: index >= 2 ? 8 : null,
                        left: index == 0 || index == 3 ? 8 : null,
                        right: index == 1 || index == 2 ? 8 : null,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: index == 0 ? const Radius.circular(4) : Radius.zero,
                              topRight: index == 1 ? const Radius.circular(4) : Radius.zero,
                              bottomRight: index == 2 ? const Radius.circular(4) : Radius.zero,
                              bottomLeft: index == 3 ? const Radius.circular(4) : Radius.zero,
                            ),
                          ),
                        ),
                      );
                    }),

                    // スキャンライン（スキャン中のみ表示）
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _scanAnimationController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (240 * _scanAnimationController.value),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

          // 魔法陣エフェクト（スキャン中）
          if (_isScanning)
            Center(
              child: AnimatedBuilder(
                animation: _scanAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_scanAnimationController.value * 0.5),
                    child: Transform.rotate(
                      angle: _scanAnimationController.value * 3.14159 * 4,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: MagicCircleWidget(
                          size: 200,
                          animate: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 上部UI
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
                children: [
                  // 戻るボタン
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // タイトル
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isScanning ? '真理を解読中...' : '次元通信術式端末\n起動中',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 右側のスペース（バランス用）
                  SizedBox(width: 56), // IconButtonと同じ幅

                ],
              ),
          ),

          // 下部UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // スキャンボタン
                    AnimatedBuilder(
                      animation: _pulseAnimationController,
                      builder: (context, child) {
                        return Container(
                          width: 80 + (_pulseAnimationController.value * 20),
                          height: 80 + (_pulseAnimationController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.primary.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: _isScanning ? null : _captureAndAnalyze,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isScanning
                                      ? AppColors.primary.withValues(alpha: 0.5)
                                      : AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: _isScanning
                                    ? const MagicCircleWidget(
                                        size: 40,
                                        animate: true,
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // 説明テキスト
                    Text(
                      _isScanning ? '神器の封印を解読中...' : '異界の神器を発見せよ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}