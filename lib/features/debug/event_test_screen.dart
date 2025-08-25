import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/special_event_service.dart';
import '../../core/services/ai_service.dart';
import '../../shared/widgets/special_event_banner.dart';

class EventTestScreen extends StatefulWidget {
  const EventTestScreen({super.key});

  @override
  State<EventTestScreen> createState() => _EventTestScreenState();
}

class _EventTestScreenState extends State<EventTestScreen> {
  final SpecialEventService _eventService = SpecialEventService.instance;
  DateTime _testDateTime = DateTime.now();
  SpecialEventType? _forcedEventType;
  Map<String, bool> _timeConditions = {};
  bool _isTestModeActive = false;

  @override
  void initState() {
    super.initState();
    _updateTimeConditions();
  }

  void _updateTimeConditions() {
    setState(() {
      _timeConditions = _eventService.debugTimeConditions();
    });
  }

  void _setTestTime(DateTime newTime) {
    setState(() {
      _testDateTime = newTime;
    });
    _eventService.enableTestMode(
      testDateTime: _testDateTime,
      forceEventType: _forcedEventType,
    );
    _eventService.updateEventStatus();
    _updateTimeConditions();
  }

  void _setForcedEvent(SpecialEventType? eventType) {
    setState(() {
      _forcedEventType = eventType;
      _isTestModeActive = true;
    });
    _eventService.enableTestMode(
      testDateTime: _testDateTime,
      forceEventType: _forcedEventType,
    );
    _eventService.updateEventStatus();
    setState(() {}); // UIを更新
  }

  void _resetToNormal() {
    setState(() {
      _testDateTime = DateTime.now();
      _forcedEventType = null;
      _isTestModeActive = false;
    });
    _eventService.disableTestMode();
    _eventService.updateEventStatus();
    _updateTimeConditions();
    setState(() {}); // UIを更新
  }

  void _testRarityProbability() async {
    // テスト中ダイアログ表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    // レア度を1000回生成してテスト
    final results = AIService.testRarityProbability(1000);
    
    if (mounted) {
      Navigator.of(context).pop(); // ローディング閉じる
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'レア度確率テスト結果 (1000回)',
            style: TextStyle(color: AppColors.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '期待値 vs 実測値',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...results.entries.map((e) {
                final expected = AIService.getRarityProbabilities()[e.key] ?? 0;
                final actual = (e.value / 1000 * 100);
                final diff = (actual - expected).abs();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getRarityColor(e.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${e.key}: ${e.value}回',
                          style: const TextStyle(color: AppColors.onSurface),
                        ),
                      ),
                      Text(
                        '${actual.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: diff < 3 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (${expected.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    }
  }

  void _setPresetTime(String preset) {
    DateTime newTime;
    switch (preset) {
      case 'cursed_4_44':
        newTime = DateTime(2024, 1, 15, 4, 44);
        break;
      case 'cursed_13_13':
        newTime = DateTime(2024, 1, 15, 13, 13);
        break;
      case 'cursed_23_23':
        newTime = DateTime(2024, 1, 15, 23, 23);
        break;
      case 'friday_13th':
        newTime = DateTime(2024, 9, 13, 15, 0); // 2024年9月13日は金曜日
        break;
      case 'halloween':
        newTime = DateTime(2024, 10, 31, 20, 0);
        break;
      case 'christmas':
        newTime = DateTime(2024, 12, 24, 18, 0);
        break;
      case 'new_year':
        newTime = DateTime(2024, 1, 1, 0, 0);
        break;
      default:
        newTime = DateTime.now();
    }
    _setTestTime(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('特殊イベントテスト'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // テストモード状態表示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isTestModeActive 
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isTestModeActive 
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isTestModeActive 
                          ? Icons.bug_report 
                          : Icons.schedule,
                      color: _isTestModeActive 
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isTestModeActive 
                          ? 'テストモード有効' 
                          : '通常モード',
                      style: TextStyle(
                        color: _isTestModeActive 
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 現在のイベント表示
              const Text(
                '現在のイベント',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SpecialEventBanner(
                event: _eventService.currentEvent,
                remainingMinutes: _eventService.getEventRemainingMinutes(),
              ),
              
              const SizedBox(height: 32),
              
              // テスト時刻設定
              const Text(
                'テスト時刻設定',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '現在の設定時刻: ${_testDateTime.toString().substring(0, 19)}',
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 16),
                    
                    // プリセット時刻ボタン
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetButton('4:44 呪われた時刻', 'cursed_4_44'),
                        _buildPresetButton('13:13 呪われた時刻', 'cursed_13_13'),
                        _buildPresetButton('23:23 呪われた時刻', 'cursed_23_23'),
                        _buildPresetButton('13日の金曜日', 'friday_13th'),
                        _buildPresetButton('ハロウィン', 'halloween'),
                        _buildPresetButton('クリスマスイブ', 'christmas'),
                        _buildPresetButton('新年', 'new_year'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 使い方説明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '使い方',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. 「強制イベント設定」でイベントを発生させる\n'
                      '2. 「プリセット時刻」で特定の日時にジャンプ\n'
                      '3. 上部にイベントバナーが表示される\n'
                      '4. 「通常モードに戻す」でリセット',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 強制イベント設定
              const Text(
                '強制イベント設定',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ボタンを押すとすぐにイベントが発生します',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _setForcedEvent(SpecialEventType.ultraRareArtifact),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('超レア神器出現'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _setForcedEvent(SpecialEventType.dimensionDistortion),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('次元歪曲'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _setForcedEvent(null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.onSurface,
                        ),
                        child: const Text('イベントなし'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 時間条件デバッグ情報
              const Text(
                '時間条件チェック',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _timeConditions.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  entry.value ? Icons.check_circle : Icons.cancel,
                                  color: entry.value ? AppColors.success : AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // レア度確率表示
              const Text(
                'レア度出現確率',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AIService.getRarityProbabilities().entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: AppColors.surface,
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: entry.value / 50, // 最大50%でスケール
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: _getRarityColor(entry.key),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.value}%',
                                      style: TextStyle(
                                        color: _getRarityColor(entry.key),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 確率テストボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _testRarityProbability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('レア度確率テスト (1000回)'),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // リセットボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetToNormal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('通常モードに戻す'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 更新ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _eventService.updateEventStatus();
                    _updateTimeConditions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('イベント状態を更新'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, String preset) {
    return ElevatedButton(
      onPressed: () => _setPresetTime(preset),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'コモン':
        return Colors.grey;
      case 'レア':
        return Colors.blue;
      case 'エピック':
        return Colors.purple;
      case 'レジェンダリー':
        return Colors.orange;
      case 'ミシック':
        return const Color(0xFFFFD700); // ゴールド
      default:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    // 画面を離れるときにテストモードを無効化
    _eventService.disableTestMode();
    _eventService.updateEventStatus();
    super.dispose();
  }
}