import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/codex/codex_loader.dart';
import '../../shared/widgets/codex/share_card.dart';
import '../constants/app_colors.dart';

/// Renders a [ShareCard] off-screen, captures it as PNG via a
/// [RepaintBoundary], writes it to a temp file, and hands it to the
/// system share sheet alongside a chuuni-flavoured caption.
class ShareService {
  ShareService._();

  static Future<void> shareScannedObject(
    BuildContext context,
    ScannedObject object,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final origin = _shareOrigin(context);

    OverlayEntry? loader;
    if (overlay != null) {
      loader = OverlayEntry(builder: (_) => const _ShareLoader());
      overlay.insert(loader);
    }

    try {
      debugPrint('ShareService: 1) reading image bytes');
      final imageBytes = await _readImageBytes(object);
      debugPrint('ShareService:    bytes=${imageBytes?.length ?? 0}');

      if (imageBytes != null) {
        debugPrint('ShareService: 2) precaching image for decode');
        await _precacheBytes(imageBytes);
      }

      if (overlay == null) {
        _toast(messenger, '共有エラー: overlay 取得失敗');
        return;
      }

      debugPrint('ShareService: 3) capturing share card');
      final pngBytes = await _captureCard(overlay, object, imageBytes);
      debugPrint('ShareService:    png=${pngBytes?.length ?? 0}');

      if (pngBytes == null) {
        _toast(messenger, '共有エラー: 画像生成失敗');
        return;
      }

      debugPrint('ShareService: 4) writing temp file');
      final file = await _writeTempPng(pngBytes, object.id);
      debugPrint('ShareService:    path=${file.path}');

      // Dismiss the codex loader before the system sheet appears so we
      // don't fight UIActivityViewController's modal.
      loader?.remove();
      loader = null;

      debugPrint('ShareService: 5) invoking system share sheet');
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: _buildCaption(object),
        subject: 'CHAOS VISION - ${object.alternateName}',
        sharePositionOrigin: origin,
      );
      debugPrint('ShareService: done');
    } catch (e, st) {
      debugPrint('ShareService: error: $e');
      debugPrint('$st');
      _toast(messenger, '共有エラー: $e');
    } finally {
      loader?.remove();
    }
  }

  static Future<void> _precacheBytes(Uint8List bytes) async {
    final completer = Completer<void>();
    final stream =
        MemoryImage(bytes).resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete();
        stream.removeListener(listener);
      },
      onError: (err, _) {
        if (!completer.isCompleted) completer.completeError(err);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  static Future<Uint8List?> _readImageBytes(ScannedObject object) async {
    if (object.imageRelativePath == null) return null;
    final fullPath = await object.getFullImagePath();
    if (fullPath == null) return null;
    final f = File(fullPath);
    if (!await f.exists()) return null;
    return f.readAsBytes();
  }

  static Future<Uint8List?> _captureCard(
    OverlayState overlay,
    ScannedObject object,
    Uint8List? imageBytes,
  ) async {
    final captureKey = GlobalKey();

    final entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: -20000,
          top: 0,
          child: Material(
            color: Colors.transparent,
            child: RepaintBoundary(
              key: captureKey,
              child: ShareCard(
                object: object,
                imageBytes: imageBytes,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Uint8List? bytes;
    try {
      // Allow the overlay to lay out and the image / fonts to settle.
      for (int i = 0; i < 4; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 40));
      }

      final ctx = captureKey.currentContext;
      if (ctx == null) {
        debugPrint('ShareService: capture key context null');
        return null;
      }
      // ignore: use_build_context_synchronously
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('ShareService: boundary not found');
        return null;
      }

      // Wait for paint to flush.
      int retries = 0;
      while (boundary.debugNeedsPaint && retries < 8) {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        retries++;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      bytes = byteData?.buffer.asUint8List();
      image.dispose();
    } catch (e, st) {
      debugPrint('ShareService: capture failed: $e');
      debugPrint('$st');
    } finally {
      entry.remove();
    }
    return bytes;
  }

  static Future<File> _writeTempPng(Uint8List bytes, String objectId) async {
    final tempDir = await getTemporaryDirectory();
    final shareDir = Directory(p.join(tempDir.path, 'share'));
    if (!await shareDir.exists()) {
      await shareDir.create(recursive: true);
    }
    final file = File(p.join(shareDir.path, 'chaos_vision_$objectId.png'));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// iOS の UIActivityViewController が popover アンカーとして必要とする矩形。
  /// iPhone では実際には使われないが share_plus が non-zero の値を要求する。
  /// 画面右上のシェアボタン付近を指定。
  static Rect _shareOrigin(BuildContext context) {
    final size = MediaQuery.maybeSizeOf(context) ?? const Size(375, 667);
    return Rect.fromLTWH(size.width - 80, 60, 60, 60);
  }

  static String _buildCaption(ScannedObject object) {
    final desc = object.description;
    final shortDesc = desc.length > 80 ? '${desc.substring(0, 80)}...' : desc;
    final body = '''🔮 ${object.alternateName}

【${object.objectCategory}】
属性:${object.attribute} レア度:${object.rarity}

$shortDesc

#CHAOSVISION #中二スキャナー''';
    if (body.length <= 250) return body;
    return '''🔮 ${object.alternateName}

【${object.objectCategory}】
属性:${object.attribute} レア度:${object.rarity}

#CHAOSVISION #中二スキャナー''';
  }

  // ─── Loading overlay ────────────────────────────────────────────────
  static void _toast(ScaffoldMessengerState? messenger, String msg) {
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.blood,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        content: Text(
          msg,
          style: GoogleFonts.shipporiMincho(
            color: AppColors.bone,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ShareLoader extends StatelessWidget {
  const _ShareLoader();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inkDeeper.withValues(alpha: 0.78),
      child: const Center(
        child: CodexLoader(
          label: '封 を 解 い て お る',
          sublabel: 'PREPARING THE DISPATCH',
          size: 96,
        ),
      ),
    );
  }
}
