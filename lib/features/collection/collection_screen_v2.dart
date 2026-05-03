import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/scanned_object.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/grimoire_card.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';

import 'object_detail_screen_v2.dart';

class CollectionScreenV2 extends ConsumerStatefulWidget {
  const CollectionScreenV2({super.key});

  @override
  ConsumerState<CollectionScreenV2> createState() => _CollectionScreenV2State();
}

class _CollectionScreenV2State extends ConsumerState<CollectionScreenV2>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService.instance;
  final ScrollController _scrollController = ScrollController();

  List<ScannedObject> _objects = [];
  String _selectedAttribute = 'すべて';
  String _selectedRarity = 'すべて';
  SortMode _sortMode = SortMode.newest;
  Map<String, int> _rarityStats = const {};
  int _grandTotal = 0;

  static const int _pageSize = 12;
  int _currentOffset = 0;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadObjects();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
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
      final stats = _storageService.rarityStats;
      final grand =
          stats.values.fold<int>(0, (sum, v) => sum + v);
      final result = _storageService.getObjectsWithFilters(
        limit: _pageSize,
        offset: 0,
        attributeFilter: _selectedAttribute,
        rarityFilter: _selectedRarity,
        sortMode: _sortMode,
      );
      setState(() {
        _objects = result.objects;
        _totalCount = result.totalCount;
        _hasMore = result.hasMore;
        _currentOffset = _pageSize;
        _rarityStats = stats;
        _grandTotal = grand;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('神器図鑑の読み込みエラー: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = _storageService.getObjectsWithFilters(
        limit: _pageSize,
        offset: _currentOffset,
        attributeFilter: _selectedAttribute,
        rarityFilter: _selectedRarity,
        sortMode: _sortMode,
      );
      setState(() {
        _objects.addAll(result.objects);
        _hasMore = result.hasMore;
        _currentOffset += _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _toggleRarity(String rarity) {
    setState(() {
      _selectedRarity = _selectedRarity == rarity ? 'すべて' : rarity;
    });
    _resetAndReload();
  }

  void _cycleSort() {
    setState(() {
      _sortMode = SortMode.values[(_sortMode.index + 1) % SortMode.values.length];
    });
    _resetAndReload();
  }

  void _resetAndReload() => _loadObjects();

  void _showFilterModal({
    required String title,
    required List<String> options,
    required String current,
    required void Function(String) onSelect,
    bool useRarityColors = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        title: title,
        options: options,
        current: current,
        onSelect: (v) {
          onSelect(v);
          Navigator.pop(context);
          _resetAndReload();
        },
        useRarityColors: useRarityColors,
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (_) => _DeleteAllDialog(
        count: _totalCount,
        onConfirm: () async {
          Navigator.pop(context);
          await _deleteAll();
        },
      ),
    );
  }

  Future<void> _deleteAll() async {
    final n = _totalCount;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Container(
        color: AppColors.inkDeeper.withValues(alpha: 0.85),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: AppColors.bloodBright,
        ),
      ),
    );
    try {
      await _storageService.clearAllData();
      if (mounted) Navigator.pop(context);
      _resetAndReload();
      if (mounted) {
        _toast('全ての封印を解いた  ($n 件)', success: true);
      }
    } catch (_) {
      if (mounted && Navigator.of(context).canPop()) Navigator.pop(context);
      if (mounted) _toast('削除に失敗しました', success: false);
    }
  }

  void _toast(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            success ? AppColors.violetDeep : AppColors.blood,
        content: Text(
          msg,
          style: GoogleFonts.shipporiMincho(
            color: AppColors.bone,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
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
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 1.3,
                  colors: [
                    Color(0xFF14110B),
                    AppColors.inkBlack,
                    AppColors.inkDeeper,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: KanjiBackdrop()),
          const Positioned.fill(child: ScanlineOverlay()),
          SafeArea(
            child: Column(
              children: [
                _Header(
                  count: _totalCount,
                  shown: _objects.length,
                  onBack: () => Navigator.of(context).pop(),
                  onDeleteAll: _totalCount > 0 ? _showDeleteAllDialog : null,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, duration: 500.ms),
                const SizedBox(height: 10),
                _StatusPanel(
                  rarityStats: _rarityStats,
                  total: _grandTotal,
                  selected: _selectedRarity,
                  onTap: _toggleRarity,
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 8),
                _SecondaryFilters(
                  attribute: _selectedAttribute,
                  sortMode: _sortMode,
                  onAttribute: () => _showFilterModal(
                    title: '属  性  で  絞  る',
                    options: ['すべて', ...AppConstants.attributes],
                    current: _selectedAttribute,
                    onSelect: (v) =>
                        setState(() => _selectedAttribute = v),
                  ),
                  onSort: _cycleSort,
                  onReset: (_selectedAttribute != 'すべて' ||
                          _selectedRarity != 'すべて' ||
                          _sortMode != SortMode.newest)
                      ? () {
                          setState(() {
                            _selectedAttribute = 'すべて';
                            _selectedRarity = 'すべて';
                            _sortMode = SortMode.newest;
                          });
                          _resetAndReload();
                        }
                      : null,
                ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.goldLeaf,
                            strokeWidth: 2,
                          ),
                        )
                      : _objects.isEmpty
                          ? _EmptyState(hasFilters: _totalCount > 0)
                          : _Grid(
                              controller: _scrollController,
                              objects: _objects,
                              hasMore: _hasMore,
                              onTapItem: (obj) async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ObjectDetailScreenV2(object: obj),
                                  ),
                                );
                                if (result is Map &&
                                    result['deleted'] == true) {
                                  _resetAndReload();
                                  if (mounted) {
                                    _toast(
                                      '${result['objectName']} の封を解いた',
                                      success: true,
                                    );
                                  }
                                }
                              },
                            ),
                ),
                const _Footer(),
              ],
            ),
          ),
          const Positioned.fill(
            child: GrainOverlay(opacity: 0.06, density: 1800),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final int shown;
  final VoidCallback onBack;
  final VoidCallback? onDeleteAll;

  const _Header({
    required this.count,
    required this.shown,
    required this.onBack,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final showRange = shown > 0 && shown < count;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.inkBlack.withValues(alpha: 0.7),
                border: Border.all(
                  color: AppColors.goldTarnish.withValues(alpha: 0.7),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.bone,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    '神 器 図 鑑',
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 16,
                      color: AppColors.bone,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 16, height: 1, color: AppColors.goldLeaf),
                  const SizedBox(width: 12),
                  Text(
                    'GRIMOIRE  INDEX',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: AppColors.goldLeaf,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.goldTarnish.withValues(alpha: 0.6),
                width: 0.7,
              ),
            ),
            child: Text(
              showRange ? '$shown／$count' : '$count',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.bone,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onDeleteAll != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDeleteAll,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inkBlack.withValues(alpha: 0.7),
                  border: Border.all(
                    color: AppColors.bloodBright.withValues(alpha: 0.7),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.bloodBright,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _kRarityOrder = ['コモン', 'レア', 'エピック', 'レジェンダリー', 'ミシック'];

const _kRarityKanji = {
  'コモン': '常',
  'レア': '稀',
  'エピック': '叙',
  'レジェンダリー': '伝',
  'ミシック': '神',
};

class _StatusPanel extends StatelessWidget {
  final Map<String, int> rarityStats;
  final int total;
  final String selected;
  final ValueChanged<String> onTap;

  const _StatusPanel({
    required this.rarityStats,
    required this.total,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _RarityPill(
            kanji: '全',
            count: total,
            isSelected: selected == 'すべて',
            color: AppColors.goldLeaf,
            onTap: () => onTap('すべて'),
          ),
          const SizedBox(width: 6),
          for (final rarity in _kRarityOrder) ...[
            _RarityPill(
              kanji: _kRarityKanji[rarity] ?? '？',
              count: rarityStats[rarity] ?? 0,
              isSelected: selected == rarity,
              color: AppColors.rarityColors[rarity] ?? AppColors.goldLeaf,
              onTap: () => onTap(rarity),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _RarityPill extends StatelessWidget {
  final String kanji;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RarityPill({
    required this.kanji,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dim = count == 0 && kanji != '全';
    final accentColor = isSelected
        ? color
        : (dim ? AppColors.boneDim : color);
    return GestureDetector(
      onTap: dim ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : AppColors.inkBlack.withValues(alpha: 0.7),
          border: Border.all(
            color: isSelected
                ? color
                : (dim
                    ? AppColors.goldTarnish.withValues(alpha: 0.25)
                    : AppColors.goldTarnish.withValues(alpha: 0.55)),
            width: isSelected ? 1.0 : 0.7,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 14,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kanji,
              style: GoogleFonts.shipporiMincho(
                fontSize: 14,
                color: accentColor,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 12,
              color: AppColors.goldTarnish.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: dim ? AppColors.boneDim : AppColors.bone,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryFilters extends StatelessWidget {
  final String attribute;
  final SortMode sortMode;
  final VoidCallback onAttribute;
  final VoidCallback onSort;
  final VoidCallback? onReset;

  const _SecondaryFilters({
    required this.attribute,
    required this.sortMode,
    required this.onAttribute,
    required this.onSort,
    required this.onReset,
  });

  String get _sortKanji {
    switch (sortMode) {
      case SortMode.newest:
        return '新';
      case SortMode.oldest:
        return '古';
      case SortMode.rarityDesc:
        return '級';
      case SortMode.attribute:
        return '属';
    }
  }

  String get _sortRomaji {
    switch (sortMode) {
      case SortMode.newest:
        return 'NEWEST';
      case SortMode.oldest:
        return 'OLDEST';
      case SortMode.rarityDesc:
        return 'RARITY';
      case SortMode.attribute:
        return 'ATTRIBUTE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final attrActive = attribute != 'すべて';
    final attrAccent =
        AppColors.attributeColors[attribute] ?? AppColors.goldLeaf;
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _PillButton(
            label: '属性',
            value: attribute,
            active: attrActive,
            accent: attrAccent,
            onTap: onAttribute,
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: '並',
            value: '$_sortKanji  ─  $_sortRomaji',
            active: sortMode != SortMode.newest,
            accent: AppColors.frost,
            onTap: onSort,
            trailing: const Icon(
              Icons.sync,
              color: AppColors.frost,
              size: 12,
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onReset,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.blood.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.bloodBright.withValues(alpha: 0.7),
                    width: 0.7,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.close,
                      color: AppColors.bloodBright,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'RESET',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppColors.bloodBright,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  final Color accent;
  final VoidCallback onTap;
  final Widget? trailing;

  const _PillButton({
    required this.label,
    required this.value,
    required this.active,
    required this.accent,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.18)
              : AppColors.inkBlack.withValues(alpha: 0.7),
          border: Border.all(
            color: active
                ? accent
                : AppColors.goldTarnish.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.shipporiMincho(
                fontSize: 11,
                color: AppColors.boneDim,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 14,
              color: AppColors.goldTarnish.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.shipporiMincho(
                fontSize: 12,
                color: active ? accent : AppColors.bone,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(120, 120),
              painter: _EmptyHexPainter(),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? '該 当 す る 神 器 な し' : '未 だ 何 も 封 じ て は お ら ぬ',
              textAlign: TextAlign.center,
              style: GoogleFonts.shipporiMincho(
                fontSize: 16,
                color: AppColors.bone,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasFilters
                  ? 'ALTER  THE  CONDITIONS'
                  : 'PERFORM  THE  RITE  OF  OBSERVATION',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.goldTarnish,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;

    for (int ring = 0; ring < 3; ring++) {
      final radius = r * (1 - ring * 0.18);
      final paint = Paint()
        ..color =
            AppColors.goldTarnish.withValues(alpha: 0.5 - ring * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      final path = Path();
      for (int i = 0; i <= 6; i++) {
        final a =
            (i / 6) * 2 * 3.141592653589793 - 3.141592653589793 / 2;
        final pt = Offset(
          center.dx + radius * _cos(a),
          center.dy + radius * _sin(a),
        );
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    final dot = Paint()..color = AppColors.bloodBright.withValues(alpha: 0.8);
    canvas.drawCircle(center, 3, dot);
  }

  double _cos(double a) {
    double c = 1, term = 1;
    for (int i = 1; i < 12; i++) {
      term *= -a * a / ((2 * i - 1) * (2 * i));
      c += term;
    }
    return c;
  }

  double _sin(double a) {
    double s = a, term = a;
    for (int i = 1; i < 12; i++) {
      term *= -a * a / ((2 * i) * (2 * i + 1));
      s += term;
    }
    return s;
  }

  @override
  bool shouldRepaint(covariant _EmptyHexPainter oldDelegate) => false;
}

class _Grid extends StatelessWidget {
  final ScrollController controller;
  final List<ScannedObject> objects;
  final bool hasMore;
  final ValueChanged<ScannedObject> onTapItem;

  const _Grid({
    required this.controller,
    required this.objects,
    required this.hasMore,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: objects.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= objects.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.goldLeaf,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }
        return GrimoireCard(
          object: objects[index],
          index: index,
          onTap: () => onTapItem(objects[index]),
        )
            .animate()
            .fadeIn(
              duration: 350.ms,
              delay: ((index % 8) * 40).ms,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.goldTarnish.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '― Ⅳ ―',
                style: GoogleFonts.bodoniModa(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.boneDim,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              Text(
                'GRIMOIRE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.boneDim,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String current;
  final ValueChanged<String> onSelect;
  final bool useRarityColors;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
    required this.useRarityColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inkBlack,
          border: Border.all(
            color: AppColors.goldTarnish.withValues(alpha: 0.5),
            width: 0.7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.shipporiMincho(
                      fontSize: 14,
                      color: AppColors.bone,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.goldTarnish.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  final selected = current == option;
                  Color accent;
                  if (option == 'すべて') {
                    accent = AppColors.goldLeaf;
                  } else if (useRarityColors) {
                    accent = AppColors.rarityColors[option] ??
                        AppColors.goldLeaf;
                  } else {
                    accent = AppColors.attributeColors[option] ??
                        AppColors.goldLeaf;
                  }
                  return GestureDetector(
                    onTap: () => onSelect(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: 0.22)
                            : AppColors.inkDeeper,
                        border: Border.all(
                          color: selected
                              ? accent
                              : AppColors.goldTarnish
                                  .withValues(alpha: 0.45),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        option,
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 13,
                          color: selected ? accent : AppColors.bone,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteAllDialog extends StatelessWidget {
  final int count;
  final VoidCallback onConfirm;

  const _DeleteAllDialog({required this.count, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inkBlack,
          border: Border.all(
            color: AppColors.bloodBright.withValues(alpha: 0.7),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blood.withValues(alpha: 0.3),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.bloodBright,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '完  全  消  去',
                  style: GoogleFonts.shipporiMincho(
                    fontSize: 15,
                    color: AppColors.bone,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.bloodBright.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '全ての神器の封を解き、灰塵に帰す',
              style: GoogleFonts.shipporiMincho(
                fontSize: 13,
                color: AppColors.bone.withValues(alpha: 0.9),
                letterSpacing: 1.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.blood.withValues(alpha: 0.2),
                border: Border.all(
                  color: AppColors.bloodBright.withValues(alpha: 0.6),
                  width: 0.7,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppColors.bloodBright,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$count 件 が消える。 此の業は還らぬ。',
                      style: GoogleFonts.shipporiMincho(
                        fontSize: 11,
                        color: AppColors.bloodBright,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.goldTarnish
                              .withValues(alpha: 0.6),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        '止     む',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 13,
                          color: AppColors.bone,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.blood.withValues(alpha: 0.4),
                        border: Border.all(
                          color: AppColors.bloodBright,
                          width: 0.9,
                        ),
                      ),
                      child: Text(
                        '断     つ',
                        style: GoogleFonts.shipporiMincho(
                          fontSize: 13,
                          color: AppColors.bone,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
