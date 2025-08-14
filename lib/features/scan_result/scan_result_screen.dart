import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/attribute_badge.dart';
import '../../shared/widgets/rarity_badge.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final ScannedObject scannedObject;

  const ScanResultScreen({
    super.key,
    required this.scannedObject,
  });

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _startAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }


  Future<void> _shareResult() async {
    try {
      // 説明文を短縮（50文字まで）
      final shortDescription = widget.scannedObject.description.length > 50 
          ? '${widget.scannedObject.description.substring(0, 50)}...'
          : widget.scannedObject.description;
      
      final shareText = '''
🔮 ${widget.scannedObject.alternateName}

【${widget.scannedObject.objectCategory}】
属性:${widget.scannedObject.attribute} レア度:${widget.scannedObject.rarity}

${shortDescription}

#CHAOSVISION #中二スキャナー
''';

      if (widget.scannedObject.imageUrl != null) {
        await Share.shareXFiles(
          [XFile(widget.scannedObject.imageUrl!)],
          text: shareText,
        );
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      _showError('共有エラー: $e');
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

  Color _getAttributeColor() {
    return AppColors.attributeColors[widget.scannedObject.attribute] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              _getAttributeColor().withOpacity(0.2),
              AppColors.background,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Spacer(),
                    const Text(
                      '封印解除完了',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _shareResult,
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 画像表示
                      if (widget.scannedObject.imageUrl != null)
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getAttributeColor().withOpacity(0.5 * _glowController.value),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(widget.scannedObject.imageUrl!),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // 異名表示
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _scaleController,
                          curve: Curves.elasticOut,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getAttributeColor(),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getAttributeColor().withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 元の名前
                              Text(
                                widget.scannedObject.objectCategory,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // 異名
                              Text(
                                widget.scannedObject.alternateName,
                                style: TextStyle(
                                  color: _getAttributeColor(),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // 属性とレア度
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AttributeBadge(attribute: widget.scannedObject.attribute),
                                  const SizedBox(width: 12),
                                  RarityBadge(rarity: widget.scannedObject.rarity),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 説明文
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '神器の詳細',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.scannedObject.description,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // メタ情報
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '発見日時',
                                        style: TextStyle(
                                          color: AppColors.onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${widget.scannedObject.scannedAt.year}年${widget.scannedObject.scannedAt.month}月${widget.scannedObject.scannedAt.day}日',
                                        style: const TextStyle(
                                          color: AppColors.onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        '認識精度',
                                        style: TextStyle(
                                          color: AppColors.onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${(widget.scannedObject.confidence * 100).toInt()}%',
                                        style: const TextStyle(
                                          color: AppColors.onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // アクションボタン
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: Column(
                          children: [
                            // 自動保存完了メッセージ
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      '神器図鑑に自動保存されました',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            GradientButton(
                              text: 'ホームに戻る',
                              onPressed: () => Navigator.of(context).pop(),
                              gradient: LinearGradient(
                                colors: [_getAttributeColor(), _getAttributeColor().withOpacity(0.7)]
                              ),
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}