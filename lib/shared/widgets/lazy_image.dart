import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/app_colors.dart';
import '../../core/services/image_cache_service.dart';
import '../../core/services/memory_monitor_service.dart';

class LazyImage extends StatefulWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableResize; // 自動リサイズを有効化
  final int? cacheWidth; // Flutterエンジンレベルのデコードサイズ
  final int? cacheHeight;

  const LazyImage({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableResize = true, // デフォルトでリサイズ有効
    this.cacheWidth, // 自動計算する場合はnull
    this.cacheHeight,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage>
    with AutomaticKeepAliveClientMixin {
  
  bool _isVisible = false;
  bool _isLoaded = false;
  bool _hasError = false;
  Image? _image;

  @override
  bool get wantKeepAlive => _isLoaded && !_hasError;

  @override
  void initState() {
    super.initState();
    // 次のフレームで可視性チェック開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkVisibility();
      }
    });
  }

  @override
  void didUpdateWidget(LazyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 画像パスまたはサイズが変わった場合は状態をリセット
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.enableResize != widget.enableResize) {
      _resetState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkVisibility();
        }
      });
    }
  }

  void _resetState() {
    setState(() {
      _isVisible = false;
      _isLoaded = false;
      _hasError = false;
      _image?.image.evict();
      _image = null;
    });
  }

  void _checkVisibility() {
    if (!mounted) return;
    
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        // サイズが確定していない場合は少し待ってから再チェック
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _checkVisibility();
        });
        return;
      }

      // スクロール可能なウィジェットを探す
      final scrollableContext = Scrollable.of(context);
      if (scrollableContext == null) {
        // スクロール可能でない場合は即座に表示
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
          });
          _loadImage();
        }
        return;
      }

      final scrollableBox = scrollableContext.context.findRenderObject() as RenderBox?;
      if (scrollableBox == null) return;

      // ウィジェットの位置を取得
      final widgetPosition = renderBox.localToGlobal(Offset.zero);
      final scrollablePosition = scrollableBox.localToGlobal(Offset.zero);
      
      // 相対位置を計算
      final relativeTop = widgetPosition.dy - scrollablePosition.dy;
      final relativeBottom = relativeTop + renderBox.size.height;
      
      // ビューポートの範囲
      final viewportHeight = scrollableBox.size.height;
      
      // 300px のバッファを持って可視性判定
      final buffer = 300.0;
      final isVisible = relativeBottom >= -buffer && 
                       relativeTop <= viewportHeight + buffer;

      if (isVisible && !_isVisible) {
        setState(() {
          _isVisible = true;
        });
        _loadImage();
      }
    } catch (e) {
      // エラーが発生した場合は安全に表示
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
        _loadImage();
      }
    }
  }

  void _loadImage() async {
    if (widget.imagePath == null || _isLoaded || _hasError) return;

    // 低メモリモードの場合はプレースホルダーを表示
    if (MemoryMonitorService.instance.isLowMemoryMode) {
      _onImageError(); // エラーウィジェットを代わりに使用
      return;
    }

    try {
      final imagePath = widget.imagePath!;
      final cacheService = ImageCacheService.instance;
      
      // リサイズ用のキャッシュキーを生成
      final cacheKey = _generateCacheKey(imagePath);
      
      // まずリサイズ済みキャッシュをチェック
      final cachedData = cacheService.getFromCache(cacheKey);
      if (cachedData != null) {
        _createImageFromBytes(cachedData);
        return;
      }

      // ファイルから読み込み
      final file = File(imagePath);
      if (await file.exists()) {
        final originalImageBytes = await file.readAsBytes();
        
        // リサイズを適用（無限大の値は除外）
        final processedImageBytes = widget.enableResize && 
            widget.width != null && widget.height != null &&
            widget.width!.isFinite && widget.height!.isFinite &&
            widget.width! > 0 && widget.height! > 0
            ? await _resizeImage(originalImageBytes, widget.width!.toInt(), widget.height!.toInt())
            : originalImageBytes;
        
        // 低メモリモードでない場合のみキャッシュに追加
        if (!MemoryMonitorService.instance.isLowMemoryMode) {
          cacheService.addToCache(cacheKey, processedImageBytes);
        }
        
        _createImageFromBytes(processedImageBytes);
      } else {
        _onImageError();
      }
    } catch (e) {
      debugPrint('Image loading error: $e');
      _onImageError();
    }
  }
  
  /// キャッシュキーを生成（リサイズサイズを含む）
  String _generateCacheKey(String originalPath) {
    if (!widget.enableResize || widget.width == null || widget.height == null) {
      return originalPath; // リサイズ無しの場合は元のパス
    }
    final w = widget.width!.toInt();
    final h = widget.height!.toInt();
    final cacheSize = _calculateEffectiveCacheSize();
    return '${originalPath}_resized_${w}x${h}_cache$cacheSize';
  }
  
  /// 効果的なキャッシュサイズを計算
  int? _calculateEffectiveCacheSize() {
    // 明示的にcacheWidthが指定されている場合はそれを使用
    if (widget.cacheWidth != null) {
      return widget.cacheWidth;
    }
    
    // width/heightが指定されており、enableResizeが有効な場合は自動計算
    if (widget.enableResize && widget.width != null && widget.height != null &&
        widget.width!.isFinite && widget.height!.isFinite &&
        widget.width! > 0 && widget.height! > 0) {
      
      // デバイスピクセル比を考慮した適切なキャッシュサイズを計算
      double devicePixelRatio = 2.0; // デフォルト値
      try {
        devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      } catch (e) {
        // コンテキストが利用できない場合はデフォルト値を使用
      }
      
      // 表示サイズの2倍程度（高DPIディスプレイ対応）で、最大800pxに制限
      final targetSize = (widget.width! * devicePixelRatio * 1.2).round();
      return targetSize > 800 ? 800 : targetSize;
    }
    
    // その他の場合はキャッシュサイズ指定なし（元サイズでデコード）
    return null;
  }
  
  /// 完全なBoxFit.cover（スケール + 中央トリミング + JPEG圧縮）
  Future<Uint8List> _resizeImage(Uint8List imageBytes, int targetWidth, int targetHeight) async {
    try {
      // 高解像度画像のメモリ節約のため、デバイスの画素密度を考慮（安全に取得）
      double devicePixelRatio = 2.0; // デフォルト値
      try {
        devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      } catch (e) {
        debugPrint('Could not get device pixel ratio, using default: $e');
      }
      
      final adjustedWidth = (targetWidth * devicePixelRatio);
      final adjustedHeight = (targetHeight * devicePixelRatio);
      
      // リサイズ範囲を制限（最大500x500でメモリ節約）
      final maxDimension = 500.0;
      final finalTargetWidth = (adjustedWidth > maxDimension ? maxDimension : adjustedWidth).toInt();
      final finalTargetHeight = (adjustedHeight > maxDimension ? maxDimension : adjustedHeight).toInt();
      
      // image package を使用して完全なBoxFit.cover処理
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return imageBytes;
      }
      
      final originalWidth = originalImage.width;
      final originalHeight = originalImage.height;
      
      // BoxFit.cover: スケールファクターを計算
      final scaleX = finalTargetWidth / originalWidth;
      final scaleY = finalTargetHeight / originalHeight;
      final scale = scaleX > scaleY ? scaleX : scaleY; // 大きい方を採用して全体をカバー
      
      // スケール後のサイズ
      final scaledWidth = (originalWidth * scale).round();
      final scaledHeight = (originalHeight * scale).round();
      
      // まずスケール
      var processedImage = img.copyResize(originalImage, 
        width: scaledWidth, 
        height: scaledHeight,
        interpolation: img.Interpolation.linear
      );
      
      // 中央トリミング
      final cropX = ((scaledWidth - finalTargetWidth) / 2).round();
      final cropY = ((scaledHeight - finalTargetHeight) / 2).round();
      
      processedImage = img.copyCrop(processedImage,
        x: cropX,
        y: cropY, 
        width: finalTargetWidth,
        height: finalTargetHeight
      );
      
      // JPEG圧縮（品質75%）
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(processedImage, quality: 75)
      );
      
      debugPrint('🖼️ BoxFit.cover完了: ${originalWidth}x$originalHeight '
          '→ scale×${scale.toStringAsFixed(2)} → crop to ${finalTargetWidth}x$finalTargetHeight '
          '(${imageBytes.length} bytes → ${compressedBytes.length} bytes, '
          '圧縮率: ${(compressedBytes.length / imageBytes.length * 100).toStringAsFixed(1)}%)');
      
      return compressedBytes;
    } catch (e) {
      debugPrint('Image resize error, using original: $e');
      return imageBytes; // リサイズ失敗時は元画像を使用
    }
  }

  void _createImageFromBytes(Uint8List imageBytes) async {
    try {
      // cacheWidth/cacheHeightを自動計算または指定値を使用
      final effectiveCacheWidth = _calculateEffectiveCacheSize();
      
      final image = Image.memory(
        imageBytes,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: effectiveCacheWidth, // Flutterエンジンレベルでの縮小デコード
        cacheHeight: effectiveCacheWidth, // 正方形でデコード（縦横比は表示時に調整）
        errorBuilder: (context, error, stackTrace) {
          _onImageError();
          return _buildErrorWidget();
        },
      );

      // 画像のプリロード
      final imageProvider = image.image;
      await precacheImage(imageProvider, context);

      if (mounted) {
        setState(() {
          _image = image;
          _isLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Image creation error: $e');
      _onImageError();
    }
  }

  void _onImageError() {
    if (mounted) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: widget.borderRadius,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: widget.borderRadius,
          ),
          child: Icon(
            Icons.broken_image,
            color: AppColors.onSurface.withOpacity(0.5),
            size: 32,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;
    
    if (_hasError) {
      child = _buildErrorWidget();
    } else if (_isLoaded && _image != null) {
      child = _image!;
    } else if (_isVisible) {
      child = _buildPlaceholder();
    } else {
      // まだ見えていない場合は空のコンテナ
      child = Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.3),
          borderRadius: widget.borderRadius,
        ),
      );
    }

    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    // NotificationListenerでスクロールイベントを監視
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (!_isVisible && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _checkVisibility();
          });
        }
        return false;
      },
      child: child,
    );
  }

  @override
  void dispose() {
    // メモリから画像を削除
    _image?.image.evict();
    
    // 必要に応じてキャッシュからも削除（通常は保持）
    // final cacheService = ImageCacheService.instance;
    // if (widget.imagePath != null) {
    //   cacheService.removeFromCache(widget.imagePath!);
    // }
    
    super.dispose();
  }
}