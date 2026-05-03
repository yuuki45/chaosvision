import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/storage_service.dart';

import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/hud_meta_bar.dart';
import '../../shared/widgets/codex/rite_loading.dart';
import '../../shared/widgets/codex/ritual_shutter.dart';
import '../../shared/widgets/codex/rune_frame.dart';

import '../scan_result/scan_result_screen_v2.dart';

class ScannerScreenV2 extends ConsumerStatefulWidget {
  const ScannerScreenV2({super.key});

  @override
  ConsumerState<ScannerScreenV2> createState() => _ScannerScreenV2State();
}

class _ScannerScreenV2State extends ConsumerState<ScannerScreenV2>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final AIService _aiService = AIService();
  final StorageService _storageService = StorageService.instance;

  bool _isInitialized = false;
  bool _isScanning = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && _isInitialized) {
      _cameraService.dispose();
      if (mounted) setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed && !_isInitialized) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (mounted) setState(() => _permissionDenied = false);
    try {
      final ok = await _cameraService.initialize();
      if (!mounted) return;
      if (ok) {
        setState(() => _isInitialized = true);
      } else {
        setState(() => _permissionDenied = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _permissionDenied = true);
        _toast('カメラの初期化に失敗しました');
      }
    }
  }

  Future<String?> _persistImage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'scanned_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final fileName = 'scanned_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dest = path.join(imagesDir.path, fileName);
      await File(sourcePath).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isScanning || !_isInitialized) return;
    setState(() => _isScanning = true);

    try {
      final image = await _cameraService.takePicture();
      if (image == null) {
        _toast('写真の撮影に失敗しました');
        return;
      }

      final saved = await _persistImage(image.path);
      if (saved == null) {
        _toast('画像の保存に失敗しました');
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final basePath =
          appDir.path.endsWith('/') ? appDir.path : '${appDir.path}/';
      final relative = saved.startsWith(basePath)
          ? saved.substring(basePath.length)
          : saved.replaceFirst('${appDir.path}/', '');

      final ai = await _aiService.analyzeImageAndGenerate(image.path);
      if (ai == null) {
        _toast('画像の解析に失敗しました');
        return;
      }

      final obj = ScannedObject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        objectCategory: ai['objectCategory'] ?? '未知の物体',
        alternateName: ai['alternateName'] ?? '謎めいた神器',
        attribute: ai['attribute'] ?? '無',
        description: ai['description'] ?? '不思議な力を秘めた神器',
        rarity: ai['rarity'] ?? 'コモン',
        scannedAt: DateTime.now(),
        imageRelativePath: relative,
        confidence: 0.95,
      );

      await _storageService.saveScannedObject(obj);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultScreenV2(scannedObject: obj),
        ),
      );
    } catch (e) {
      _toast('スキャンエラー: $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.shipporiMincho()),
        backgroundColor: AppColors.blood,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkDeeper,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_permissionDenied)
            RiteLoading(
              headline: '視 力 が 封 じ ら れ て い る',
              englishHeadline: 'THE EYE IS SEALED',
              retryAvailable: true,
              onRetry: _initializeCamera,
            )
          else if (_isInitialized && _cameraService.controller != null) ...[
            _CameraSurface(controller: _cameraService.controller!),
            const Positioned.fill(child: _Vignette()),
            const Positioned.fill(
              child: GrainOverlay(opacity: 0.05, density: 1400),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HudMetaBar(
                    onBack: () => Navigator.of(context).pop(),
                    scanning: _isScanning,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0, duration: 500.ms),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final byW = c.maxWidth - 48;
                            final byH = c.maxHeight - 48;
                            final s = byW < byH ? byW : byH;
                            final size = s.clamp(200.0, 360.0);
                            return RuneFrame(
                              size: size,
                              scanning: _isScanning,
                            )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                  duration: 700.ms,
                                  curve: Curves.easeOutCubic,
                                );
                          },
                        ),
                      ),
                    ),
                  ),
                  _RiteCaption(scanning: _isScanning),
                  const SizedBox(height: 18),
                  Center(
                    child: RitualShutter(
                      busy: _isScanning,
                      onPressed: _captureAndAnalyze,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _PageMark(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ] else
            const RiteLoading(),
        ],
      ),
    );
  }
}

class _CameraSurface extends StatelessWidget {
  final CameraController controller;
  const _CameraSurface({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          1.05, 0, 0, 0, -10,
          0, 1.0, 0, 0, -8,
          0, 0, 0.92, 0, -12,
          0, 0, 0, 1, 0,
        ]),
        child: SizedBox.expand(child: CameraPreview(controller)),
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.05,
            colors: [
              Colors.transparent,
              AppColors.inkDeeper.withValues(alpha: 0.55),
              AppColors.inkDeeper.withValues(alpha: 0.92),
            ],
            stops: const [0.55, 0.85, 1.0],
          ),
        ),
      ),
    );
  }
}

class _RiteCaption extends StatelessWidget {
  final bool scanning;
  const _RiteCaption({required this.scanning});

  @override
  Widget build(BuildContext context) {
    final accent =
        scanning ? AppColors.bloodBright : AppColors.goldLeaf;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            height: 22,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 18, height: 1, color: AppColors.goldTarnish),
                  const SizedBox(width: 12),
                  Text(
                    scanning ? '神 器 の 真 名 を 解 読 中' : '異 界 の 神 器 を 視 よ',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 14,
                      color: AppColors.bone,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      height: 1.0,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 18, height: 1, color: AppColors.goldTarnish),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 14,
            child: Text(
              scanning
                  ? 'DECODING THE TRUE NAME...'
                  : 'WITNESS THE ARTIFACT BEYOND',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: accent.withValues(alpha: 0.85),
                letterSpacing: 3.5,
                height: 1.0,
              ),
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                height: 1.0,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageMark extends StatelessWidget {
  const _PageMark();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '― Ⅱ ―',
        style: GoogleFonts.bodoniModa(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: AppColors.boneDim,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
