import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/achievement_service.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/storage_service.dart';

import '../achievements/achievement_catalog.dart';
import '../achievements/achievement_modal.dart';
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
      // permanentlyDenied / restricted のときだけ早期に拒否画面へ。
      // iOS の `denied` は notDetermined (未確認) も含むため、
      // ここで弾くと初回ダイアログ自体が出なくなる。未確認は素直に
      // _cameraService.initialize() に進めて OS にダイアログを出させる。
      final status = await Permission.camera.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }
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

      // ビューファインダーは画面中央よりやや上にあるため、
      // カメラの full FOV を中央クロップすると被写体が上にズレて見える。
      // 撮影画像を正方形でクロップ + 上方向に少しバイアスして保存し、
      // 保存・表示・共有がビューファインダーで見た構図と一致するようにする。
      final originalBytes = await File(sourcePath).readAsBytes();
      final original = img.decodeImage(originalBytes);
      if (original == null) {
        await File(sourcePath).copy(dest);
        return dest;
      }

      final w = original.width;
      final h = original.height;
      final size = w < h ? w : h;
      final offsetX = ((w - size) / 2).round();
      // 画像が縦長なら、上方向に約 22% バイアスして上半分を多めに残す。
      // 横長 (rare) なら水平方向のバイアスは無し (中央で OK)。
      int offsetY;
      if (h > w) {
        final verticalMargin = h - size;
        const upwardBias = 0.22; // 0.0 = 中央, 0.5 = 完全に上寄り
        offsetY = (verticalMargin * (0.5 - upwardBias)).round();
      } else {
        offsetY = ((h - size) / 2).round();
      }

      final cropped = img.copyCrop(
        original,
        x: offsetX.clamp(0, w - size),
        y: offsetY.clamp(0, h - size),
        width: size,
        height: size,
      );
      final croppedBytes = img.encodeJpg(cropped, quality: 92);
      await File(dest).writeAsBytes(croppedBytes);
      return dest;
    } catch (_) {
      return null;
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isScanning || !_isInitialized) return;
    HapticFeedback.heavyImpact();
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
      HapticFeedback.mediumImpact();
      await Navigator.of(context).push(_revealRoute(obj));

      // 結果画面から戻ってきたタイミングでアチーブメントを評価。
      // 評価には保存済みのスキャン履歴全体を使う（今回スキャン分も含む）。
      if (!mounted) return;
      final all = _storageService.getAllScannedObjects();
      final newly = await AchievementService.instance.evaluateAndUnlock(
        AchievementCheckContext(all),
        scannedObjectId: obj.id,
      );
      if (!mounted) return;
      for (final a in newly) {
        if (!mounted) break;
        await showAchievementUnlockModal(context, a);
      }
    } catch (e) {
      _toast('スキャンエラー: $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Route<dynamic> _revealRoute(ScannedObject obj) {
    return PageRouteBuilder<dynamic>(
      transitionDuration: const Duration(milliseconds: 720),
      reverseTransitionDuration: const Duration(milliseconds: 480),
      pageBuilder: (_, __, ___) => ScanResultScreenV2(scannedObject: obj),
      transitionsBuilder: (context, animation, secondary, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t =
                Curves.easeOutCubic.transform(animation.value.clamp(0.0, 1.0));
            return Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.inkDeeper.withValues(alpha: t),
                  ),
                ),
                Positioned.fill(
                  child: ClipPath(
                    clipper: _CircularRevealClipper(progress: t),
                    child: Opacity(opacity: t, child: child),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
              onOpenSettings: () => openAppSettings(),
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
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                RuneFrame(
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
                                    ),
                                SizedBox(
                                  width: size,
                                  height: size,
                                  child: _ScanRitual(active: _isScanning),
                                ),
                              ],
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
          if (_isInitialized)
            Positioned.fill(
              child: IgnorePointer(child: _ScanFlash(trigger: _isScanning)),
            ),
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

class _RiteCaption extends StatefulWidget {
  final bool scanning;
  const _RiteCaption({required this.scanning});

  @override
  State<_RiteCaption> createState() => _RiteCaptionState();
}

class _RiteCaptionState extends State<_RiteCaption> {
  static const _phases = <(String, String)>[
    ('霊 視 受 信 中', 'RECEIVING APPARITION'),
    ('真 名 解 読 中', 'DECODING TRUE NAME'),
    ('属 性 鑑 定 中', 'APPRAISING ATTRIBUTE'),
    ('封 印 生 成 中', 'FORGING SEAL'),
  ];

  int _phase = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.scanning) _start();
  }

  @override
  void didUpdateWidget(covariant _RiteCaption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scanning && !oldWidget.scanning) {
      _start();
    } else if (!widget.scanning && oldWidget.scanning) {
      _stop();
    }
  }

  void _start() {
    _phase = 0;
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (!mounted || !widget.scanning) return;
      // Pin on the final phase rather than looping.
      if (_phase < _phases.length - 1) {
        setState(() => _phase++);
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _phase = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.scanning ? AppColors.bloodBright : AppColors.goldLeaf;
    final jp = widget.scanning
        ? _phases[_phase].$1
        : '異 界 の 神 器 を 視 よ';
    final en = widget.scanning
        ? '${_phases[_phase].$2}...'
        : 'WITNESS THE ARTIFACT BEYOND';

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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      jp,
                      key: ValueKey('jp-$jp'),
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                en,
                key: ValueKey('en-$en'),
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

class _ScanFlash extends StatefulWidget {
  final bool trigger;
  const _ScanFlash({required this.trigger});

  @override
  State<_ScanFlash> createState() => _ScanFlashState();
}

class _ScanFlashState extends State<_ScanFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.trigger) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _ScanFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.value == 0 || _ctrl.value == 1) {
          return const SizedBox.shrink();
        }
        // Two-stage curve: rapid rise (0..0.15) then slow fade (0.15..1)
        final v = _ctrl.value;
        double opacity;
        if (v < 0.15) {
          opacity = v / 0.15;
        } else {
          opacity = 1 - (v - 0.15) / 0.85;
        }
        return ColoredBox(
          color: AppColors.bloodBright.withValues(alpha: 0.28 * opacity),
        );
      },
    );
  }
}

class _ScanRitual extends StatefulWidget {
  final bool active;
  const _ScanRitual({required this.active});

  @override
  State<_ScanRitual> createState() => _ScanRitualState();
}

class _ScanRitualState extends State<_ScanRitual>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _outer;
  late final AnimationController _middle;
  late final AnimationController _inner;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _outer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
    _middle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _inner = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.active) _start();
  }

  void _start() {
    _outer.repeat();
    _middle.repeat();
    _inner.repeat();
    _pulse.repeat(reverse: true);
    _enter.forward(from: 0);
  }

  void _stop() {
    _enter.reverse();
    Future.delayed(_enter.duration ?? const Duration(milliseconds: 600), () {
      if (!mounted || widget.active) return;
      _outer.stop();
      _middle.stop();
      _inner.stop();
      _pulse.stop();
    });
  }

  @override
  void didUpdateWidget(covariant _ScanRitual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _start();
    if (!widget.active && oldWidget.active) _stop();
  }

  @override
  void dispose() {
    _enter.dispose();
    _outer.dispose();
    _middle.dispose();
    _inner.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_enter, _outer, _middle, _inner, _pulse]),
        builder: (context, _) {
          if (_enter.value == 0) return const SizedBox.shrink();
          final eased = Curves.easeOutCubic.transform(_enter.value);
          return Opacity(
            opacity: eased,
            child: Transform.scale(
              scale: 0.55 + 0.45 * eased,
              child: CustomPaint(
                painter: _RitualPainter(
                  outerRot: _outer.value,
                  midRot: _middle.value,
                  innerRot: _inner.value,
                  pulse: _pulse.value,
                ),
                size: Size.infinite,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RitualPainter extends CustomPainter {
  final double outerRot;
  final double midRot;
  final double innerRot;
  final double pulse;

  _RitualPainter({
    required this.outerRot,
    required this.midRot,
    required this.innerRot,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;

    // Center pulsing aura (blood-red glow)
    final glow = Paint()
      ..color = AppColors.bloodBright.withValues(alpha: 0.28 + 0.18 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);
    canvas.drawCircle(
      center,
      maxR * (0.32 + 0.05 * pulse),
      glow,
    );

    // ── OUTER RING (CW): dashed + 12 sigil dots + 24 ticks
    _drawRotated(canvas, center, outerRot * 2 * math.pi, () {
      final ringPaint = Paint()
        ..color = AppColors.bloodBright.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      _drawDashedCircle(
        canvas,
        center,
        maxR * 0.95,
        ringPaint,
        dashCount: 56,
        dashRatio: 0.55,
      );

      final tickPaint = Paint()
        ..color = AppColors.bloodBright.withValues(alpha: 0.85)
        ..strokeWidth = 0.8;
      for (int i = 0; i < 24; i++) {
        final a = (i / 24) * math.pi * 2;
        final pOuter = Offset(
          center.dx + maxR * 0.92 * math.cos(a),
          center.dy + maxR * 0.92 * math.sin(a),
        );
        final pInner = Offset(
          center.dx + maxR * 0.86 * math.cos(a),
          center.dy + maxR * 0.86 * math.sin(a),
        );
        canvas.drawLine(pOuter, pInner, tickPaint);
      }

      final dotPaint = Paint()..color = AppColors.bloodBright;
      for (int i = 0; i < 12; i++) {
        final a = (i / 12) * math.pi * 2;
        final p = Offset(
          center.dx + maxR * 0.95 * math.cos(a),
          center.dy + maxR * 0.95 * math.sin(a),
        );
        canvas.drawCircle(p, 3.0, dotPaint);
      }
    });

    // ── MIDDLE RING (CCW): hexagram + gold ring + 6 vertex dots
    _drawRotated(canvas, center, -midRot * 2 * math.pi, () {
      final ringPaint = Paint()
        ..color = AppColors.goldLeaf.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, maxR * 0.7, ringPaint);

      // Hexagram (Star of David — two overlapping triangles)
      _drawTriangle(canvas, center, maxR * 0.62, 0, ringPaint);
      _drawTriangle(canvas, center, maxR * 0.62, math.pi / 3, ringPaint);

      // 6 vertex dots
      final dotPaint = Paint()..color = AppColors.goldLeaf;
      for (int i = 0; i < 6; i++) {
        final a = (i / 6) * math.pi * 2 - math.pi / 2;
        final p = Offset(
          center.dx + maxR * 0.7 * math.cos(a),
          center.dy + maxR * 0.7 * math.sin(a),
        );
        canvas.drawCircle(p, 3.5, dotPaint);
      }
    });

    // ── INNER RING (CW fast): blood inverted triangle + small ring
    _drawRotated(canvas, center, innerRot * 2 * math.pi, () {
      final ringPaint = Paint()
        ..color = AppColors.bloodBright
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, maxR * 0.42, ringPaint);

      _drawTriangle(canvas, center, maxR * 0.34, math.pi, ringPaint);

      // 3 small filled vertices
      final dotPaint = Paint()..color = AppColors.bloodBright;
      for (int i = 0; i < 3; i++) {
        final a = (i / 3) * math.pi * 2 - math.pi / 2 + math.pi;
        final p = Offset(
          center.dx + maxR * 0.34 * math.cos(a),
          center.dy + maxR * 0.34 * math.sin(a),
        );
        canvas.drawCircle(p, 2.6, dotPaint);
      }
    });

    // ── CENTER CROSSHAIR (static, bone color)
    final cross = Paint()
      ..color = AppColors.bone.withValues(alpha: 0.9)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      cross,
    );
    canvas.drawCircle(center, 2.6, Paint()..color = AppColors.bone);
  }

  void _drawRotated(
    Canvas canvas,
    Offset center,
    double angle,
    VoidCallback paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    paint();
    canvas.restore();
  }

  void _drawTriangle(
    Canvas canvas,
    Offset center,
    double radius,
    double rotationOffset,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final a =
          (i / 3) * math.pi * 2 - math.pi / 2 + rotationOffset;
      final p = Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    required int dashCount,
    required double dashRatio,
  }) {
    final segmentAngle = (math.pi * 2) / dashCount;
    final dashAngle = segmentAngle * dashRatio;
    for (int i = 0; i < dashCount; i++) {
      final start = i * segmentAngle;
      final end = start + dashAngle;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, start, end - start, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RitualPainter oldDelegate) =>
      oldDelegate.outerRot != outerRot ||
      oldDelegate.midRot != midRot ||
      oldDelegate.innerRot != innerRot ||
      oldDelegate.pulse != pulse;
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double progress;
  _CircularRevealClipper({required this.progress});

  @override
  Path getClip(Size size) {
    // Origin: roughly the viewfinder center on the scanner screen.
    final center = Offset(size.width / 2, size.height * 0.42);
    final maxRadius = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    ).toDouble();
    final radius = maxRadius * progress;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}
