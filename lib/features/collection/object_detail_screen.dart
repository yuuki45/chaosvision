import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/attribute_badge.dart';
import '../../shared/widgets/rarity_badge.dart';
import '../../shared/widgets/magic_circle_widget.dart';

class ObjectDetailScreen extends StatefulWidget {
  final ScannedObject object;

  const ObjectDetailScreen({
    super.key,
    required this.object,
  });

  @override
  State<ObjectDetailScreen> createState() => _ObjectDetailScreenState();
}

class _ObjectDetailScreenState extends State<ObjectDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final StorageService _storageService = StorageService.instance;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _rotationController,
    );
    
    _scaleController.forward();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.background,
              (AppColors.attributeColors[widget.object.attribute] ?? AppColors.primary)
                  .withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: _showDeleteConfirmation,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share, color: AppColors.onBackground),
                      onPressed: _shareObject,
                    ),
                  ],
                ),
              ),

              // メインコンテンツ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // 魔法陣エフェクト付き画像
                      SizedBox(
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 背景の魔法陣
                            AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 6.28,
                                  child: MagicCircleWidget(
                                    size: 200,
                                    color: AppColors.attributeColors[widget.object.attribute] 
                                        ?? AppColors.primary,
                                    animate: true,
                                  ),
                                );
                              },
                            ),
                            
                            // オブジェクト画像
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.rarityColors[widget.object.rarity] 
                                        ?? AppColors.primary,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (AppColors.rarityColors[widget.object.rarity] 
                                          ?? AppColors.primary).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: widget.object.imageUrl != null
                                      ? Image.file(
                                          File(widget.object.imageUrl!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildPlaceholderImage();
                                          },
                                        )
                                      : _buildPlaceholderImage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // レア度と属性バッジ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RarityBadge(rarity: widget.object.rarity, size: 16),
                          const SizedBox(width: 12),
                          AttributeBadge(attribute: widget.object.attribute, size: 16),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 異名
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '真名',
                              style: TextStyle(
                                color: AppColors.onSurface.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.object.alternateName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 物体カテゴリ
                      _buildInfoCard(
                        '現世での名称',
                        widget.object.objectCategory,
                        Icons.category,
                      ),

                      const SizedBox(height: 16),

                      // 説明
                      _buildInfoCard(
                        '神秘なる設定',
                        widget.object.description,
                        Icons.auto_stories,
                        isExpandable: true,
                      ),

                      const SizedBox(height: 16),

                      // 詳細情報
                      _buildStatsCard(),

                      const SizedBox(height: 32),
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

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (AppColors.attributeColors[widget.object.attribute] ?? AppColors.primary)
                .withOpacity(0.4),
            (AppColors.attributeColors[widget.object.attribute] ?? AppColors.primary)
                .withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 60,
        color: AppColors.attributeColors[widget.object.attribute] ?? AppColors.primary,
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, {bool isExpandable = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.onSurface.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final scanDate = widget.object.scannedAt;
    final confidence = (widget.object.confidence * 100).toStringAsFixed(1);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '発見情報',
                style: TextStyle(
                  color: AppColors.onSurface.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('発見日時', 
                  '${scanDate.year}/${scanDate.month.toString().padLeft(2, '0')}/${scanDate.day.toString().padLeft(2, '0')}'),
              ),
              Expanded(
                child: _buildStatItem('信頼度', '$confidence%'),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('属性', widget.object.attribute),
              ),
              Expanded(
                child: _buildStatItem('レア度', widget.object.rarity),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _shareObject() async {
    try {
      // 説明文を短縮（50文字まで）
      final shortDescription = widget.object.description.length > 50 
          ? '${widget.object.description.substring(0, 50)}...'
          : widget.object.description;
      
      final text = '''
🔮 ${widget.object.alternateName}

【${widget.object.objectCategory}】
属性:${widget.object.attribute} レア度:${widget.object.rarity}

${shortDescription}

#CHAOSVISION #中二スキャナー
      ''';
      
      await Share.share(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('共有に失敗しました'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              '神器を削除',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'この神器を図鑑から完全に削除しますか？',
              style: TextStyle(
                color: AppColors.onSurface.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.attributeColors[widget.object.attribute] ?? AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.object.alternateName,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.object.objectCategory,
                          style: TextStyle(
                            color: AppColors.onSurface.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ この操作は取り消せません',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'キャンセル',
              style: TextStyle(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteObject();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteObject() async {
    try {
      // ローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      // 画像ファイルを削除
      if (widget.object.imageUrl != null) {
        final imageFile = File(widget.object.imageUrl!);
        if (await imageFile.exists()) {
          await imageFile.delete();
          debugPrint('画像ファイルを削除しました: ${widget.object.imageUrl}');
        }
      }

      // データベースから削除
      final success = await _storageService.deleteScannedObject(widget.object.id);
      
      if (mounted) {
        Navigator.of(context).pop(); // ローディングダイアログを閉じる
        
        if (success) {
          // 成功時は図鑑画面に戻る（削除メッセージは図鑑画面で表示）
          Navigator.of(context).pop({
            'deleted': true,
            'objectName': widget.object.alternateName,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('削除に失敗しました'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('削除エラー: $e');
      if (mounted) {
        Navigator.of(context).pop(); // ローディングダイアログを閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除エラー: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}