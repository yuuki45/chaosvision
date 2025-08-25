import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/memory_monitor_service.dart';
import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/attribute_badge.dart';
import '../../shared/widgets/rarity_badge.dart';
import '../../shared/widgets/lazy_image.dart';
import 'object_detail_screen.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ScannedObject> _objects = [];
  String _selectedAttribute = 'すべて';
  String _selectedRarity = 'すべて';
  String _searchQuery = '';
  
  // ページネーション関連（メモリ削減のため大幅に削減）
  static const int _pageSize = 10; // 20 → 10に削減
  int _currentOffset = 0;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    // スクロールリスナーを追加
    _scrollController.addListener(_onScroll);
    
    _loadObjects();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    
    // 80%スクロールしたら次のページを読み込み
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreObjects();
    }
  }

  Future<void> _loadObjects() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _objects.clear();
    });

    try {
      final result = _storageService.getObjectsWithFilters(
        limit: _pageSize,
        offset: 0,
        attributeFilter: _selectedAttribute,
        rarityFilter: _selectedRarity,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _objects = result.objects;
        _totalCount = result.totalCount;
        _hasMore = result.hasMore;
        _currentOffset = _pageSize;
        _isLoading = false;
      });
      
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('神器図鑑の読み込みエラー: $e');
    }
  }

  Future<void> _loadMoreObjects() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = _storageService.getObjectsWithFilters(
        limit: _pageSize,
        offset: _currentOffset,
        attributeFilter: _selectedAttribute,
        rarityFilter: _selectedRarity,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _objects.addAll(result.objects);
        _hasMore = result.hasMore;
        _currentOffset += _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      debugPrint('追加読み込みエラー: $e');
    }
  }

  void _resetAndReload() {
    _fadeController.reset();
    _loadObjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.background,
              Color(0xFF000000),
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
                    const SizedBox(width: 8),
                    Text(
                      '神器図鑑',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // 全削除ボタン
                    if (_totalCount > 0)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                        onPressed: () => _showDeleteAllConfirmation(),
                        tooltip: '全て削除',
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _totalCount == _objects.length 
                              ? '$_totalCount件'
                              : '${_objects.length}/$_totalCount',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 検索バー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      hintText: '神器を検索...',
                      hintStyle: TextStyle(color: AppColors.onSurface),
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      // デバウンス処理（500ms後に検索実行）
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchQuery == value) {
                          _resetAndReload();
                        }
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // フィルター
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // 属性フィルター
                    _buildFilterChip(
                      '属性: $_selectedAttribute',
                      () => _showAttributeFilter(),
                    ),
                    const SizedBox(width: 8),
                    // レア度フィルター
                    _buildFilterChip(
                      'レア度: $_selectedRarity',
                      () => _showRarityFilter(),
                    ),
                    const SizedBox(width: 8),
                    // リセットボタン
                    if (_selectedAttribute != 'すべて' || _selectedRarity != 'すべて')
                      _buildFilterChip(
                        'リセット',
                        () {
                          setState(() {
                            _selectedAttribute = 'すべて';
                            _selectedRarity = 'すべて';
                          });
                          _resetAndReload();
                        },
                        isReset: true,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 低メモリモードの警告表示
              if (MemoryMonitorService.instance.isLowMemoryMode)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.memory, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'メモリ節約モード: メモリに余裕ができると自動で通常モードに戻ります',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 神器リスト
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: _objects.isEmpty
                            ? _buildEmptyState()
                            : _buildObjectGrid(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, {bool isReset = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isReset ? AppColors.error.withValues(alpha: 0.2) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReset ? AppColors.error : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isReset ? AppColors.error : AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: AppColors.onBackground.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _totalCount == 0 ? '神器がありません' : '条件に一致する神器がありません',
                style: TextStyle(
                  color: AppColors.onBackground.withValues(alpha: 0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _totalCount == 0 
                      ? 'スキャンして神器を発見しましょう！'
                      : 'フィルターを変更してみてください',
                  style: TextStyle(
                    color: AppColors.onBackground.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectGrid() {
    return GridView.builder(
      key: ValueKey('${_selectedAttribute}_${_selectedRarity}_$_searchQuery'),
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _objects.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _objects.length) {
          // ローディングインジケーター
          return Container(
            margin: const EdgeInsets.all(8),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        
        final object = _objects[index];
        return _buildObjectCard(object);
      },
    );
  }

  Widget _buildObjectCard(ScannedObject object) {
    return GestureDetector(
      key: ValueKey(object.id),
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ObjectDetailScreen(object: object),
          ),
        );
        
        // 削除された場合はリストを更新してメッセージを表示
        if (result != null && result is Map) {
          if (result['deleted'] == true) {
            _resetAndReload();
            
            // 削除成功メッセージを表示
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${result['objectName']} を削除しました',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.rarityColors[object.rarity] ?? AppColors.surfaceVariant,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (AppColors.rarityColors[object.rarity] ?? AppColors.primary)
                  .withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 画像エリア
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: LazyImage(
                  key: ValueKey('${object.id}_${object.imageUrl}'),
                  imagePath: object.imageUrl,
                  width: 200, // 固定サイズでリサイズを有効化
                  height: 150,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  errorWidget: _buildPlaceholderImage(object),
                  placeholder: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 情報エリア
            Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // レア度と属性
                  Row(
                    children: [
                      RarityBadge(rarity: object.rarity, size: 12),
                      const SizedBox(width: 4),
                      AttributeBadge(attribute: object.attribute, size: 12),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 異名（固定高さで2行確保）
                  SizedBox(
                    height: 36,
                    child: Text(
                      object.alternateName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // 物体カテゴリ（固定高さ）
                  SizedBox(
                    width: double.infinity,
                    height: 16,
                    child: Text(
                      object.objectCategory,
                      style: TextStyle(
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ScannedObject object) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (AppColors.attributeColors[object.attribute] ?? AppColors.primary)
                .withValues(alpha: 0.3),
            (AppColors.attributeColors[object.attribute] ?? AppColors.primary)
                .withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 40,
        color: AppColors.attributeColors[object.attribute] ?? AppColors.primary,
      ),
    );
  }

  void _showAttributeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '属性で絞り込み',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['すべて', ...AppConstants.attributes].map((attribute) {
                  final isSelected = _selectedAttribute == attribute;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAttribute = attribute;
                      });
                      Navigator.pop(context);
                      _resetAndReload();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        attribute,
                        style: TextStyle(
                          color: isSelected ? Colors.black : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRarityFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'レア度で絞り込み',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['すべて', ...AppConstants.rarityLevels].map((rarity) {
                  final isSelected = _selectedRarity == rarity;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRarity = rarity;
                      });
                      Navigator.pop(context);
                      _resetAndReload();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.rarityColors[rarity] ?? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rarity,
                        style: TextStyle(
                          color: isSelected ? Colors.black : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// 全削除確認ダイアログを表示
  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '全神器削除の確認',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '保存されている全ての神器を削除しますか？',
              style: TextStyle(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_totalCount件の神器が完全に削除されます。この操作は取り消せません。',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: AppColors.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAllObjects();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('全て削除'),
          ),
        ],
      ),
    );
  }

  /// 全神器を削除
  Future<void> _deleteAllObjects() async {
    try {
      final deleteCount = _totalCount;
      
      // 削除処理のローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      // 全神器を削除
      await _storageService.clearAllData();
      
      // ローディング閉じる
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // リストを更新
      _resetAndReload();
      
      // 成功メッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('全ての神器を削除しました ($deleteCount件)'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // ローディングが表示されている場合は閉じる
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // エラーメッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('削除に失敗しました'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      debugPrint('全神器削除エラー: $e');
    }
  }
}