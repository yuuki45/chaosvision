import 'dart:math' as math;
import 'package:flutter/foundation.dart';

enum SpecialEventType {
  none,
  ultraRareArtifact,  // 超レア神器
  dimensionDistortion, // 次元歪曲
}

enum UltraRareCondition {
  cursedHour,     // 呪われた時刻 (4:44, 13:13, 23:23)
  mysticalDay,    // 神秘的な日付 (13日の金曜日)
  specialDate,    // 特別な日付 (ハロウィン、クリスマスイブ等)
}

class SpecialEvent {
  final SpecialEventType type;
  final String name;
  final String description;
  final double rarityMultiplier;
  final Map<String, dynamic> config;

  SpecialEvent({
    required this.type,
    required this.name,
    required this.description,
    required this.rarityMultiplier,
    required this.config,
  });
}

class SpecialEventService {
  static final SpecialEventService _instance = SpecialEventService._internal();
  static SpecialEventService get instance => _instance;
  SpecialEventService._internal();

  SpecialEvent? _currentEvent;
  DateTime? _lastEventCheck;
  final math.Random _random = math.Random();
  
  // テスト用のオーバーライド
  bool _testModeEnabled = false;
  SpecialEventType? _forcedEventType;
  DateTime? _testDateTime;

  /// 現在のイベントを取得
  SpecialEvent? get currentEvent => _currentEvent;

  /// 超レア神器が出現する条件かチェック
  bool isUltraRareCondition(DateTime now) {
    // 呪われた時刻をチェック
    if (_isCursedHour(now)) return true;
    
    // 神秘的な日付をチェック
    if (_isMysticalDay(now)) return true;
    
    // 特別な日付をチェック
    if (_isSpecialDate(now)) return true;
    
    return false;
  }

  /// 次元歪曲モードが発生する条件かチェック
  bool isDimensionDistortionActive(DateTime now) {
    // 1時間ごとに5%の確率で発生
    final hoursSinceEpoch = now.millisecondsSinceEpoch ~/ (1000 * 60 * 60);
    final seed = hoursSinceEpoch;
    final random = math.Random(seed);
    return random.nextDouble() < 0.05;
  }

  /// テストモードを有効化
  void enableTestMode({
    SpecialEventType? forceEventType,
    DateTime? testDateTime,
  }) {
    _testModeEnabled = true;
    _forcedEventType = forceEventType;
    _testDateTime = testDateTime;
    debugPrint('テストモード有効化: イベント=$forceEventType, 時刻=$testDateTime');
  }

  /// テストモードを無効化
  void disableTestMode() {
    _testModeEnabled = false;
    _forcedEventType = null;
    _testDateTime = null;
    debugPrint('テストモード無効化');
  }

  /// 現在のイベント状態を更新
  void updateEventStatus() {
    final now = _testDateTime ?? DateTime.now();
    
    // テストモード中は常に更新、通常モードは1分ごとにチェック
    if (!_testModeEnabled && _lastEventCheck != null && 
        now.difference(_lastEventCheck!).inMinutes < 1) {
      return;
    }
    
    _lastEventCheck = now;
    
    // テストモードの場合は強制的にイベントを発生
    if (_testModeEnabled && _forcedEventType != null) {
      _currentEvent = _createTestEvent(_forcedEventType!, now);
      return;
    }
    
    // 次元歪曲モードのチェック（優先度高）
    if (isDimensionDistortionActive(now)) {
      _currentEvent = SpecialEvent(
        type: SpecialEventType.dimensionDistortion,
        name: '次元歪曲現象',
        description: '現実の境界が曖昧になっている...',
        rarityMultiplier: 1.5,
        config: {
          'distortionLevel': _random.nextDouble() * 0.5 + 0.3, // 0.3-0.8
          'colorShift': _random.nextDouble() * 0.4 + 0.1, // 0.1-0.5
          'effectIntensity': _random.nextDouble() * 0.6 + 0.4, // 0.4-1.0
        },
      );
      debugPrint('次元歪曲モード発生！');
      return;
    }
    
    // 超レア神器出現のチェック
    if (isUltraRareCondition(now)) {
      final condition = _getUltraRareCondition(now);
      _currentEvent = SpecialEvent(
        type: SpecialEventType.ultraRareArtifact,
        name: '超レア神器出現',
        description: _getUltraRareDescription(condition),
        rarityMultiplier: 3.0,
        config: {
          'condition': condition,
          'bonusRarity': 'Mythical',
          'guaranteedAttributes': ['闇', '時空', '封印'],
        },
      );
      debugPrint('超レア神器出現条件達成: $condition');
      return;
    }
    
    // イベントなし
    _currentEvent = null;
  }

  /// 呪われた時刻かチェック
  bool _isCursedHour(DateTime now) {
    final hour = now.hour;
    final minute = now.minute;
    
    // 4:44, 13:13, 23:23
    return (hour == 4 && minute == 44) ||
           (hour == 13 && minute == 13) ||
           (hour == 23 && minute == 23);
  }

  /// 神秘的な日付かチェック
  bool _isMysticalDay(DateTime now) {
    // 13日の金曜日
    if (now.day == 13 && now.weekday == DateTime.friday) {
      return true;
    }
    
    return false;
  }

  /// 特別な日付かチェック
  bool _isSpecialDate(DateTime now) {
    final month = now.month;
    final day = now.day;
    
    // ハロウィン
    if (month == 10 && day == 31) return true;
    
    // クリスマスイブ
    if (month == 12 && day == 24) return true;
    
    // 新年
    if (month == 1 && day == 1) return true;
    
    // エイプリルフール
    if (month == 4 && day == 1) return true;
    
    return false;
  }



  /// 超レア条件を取得
  UltraRareCondition _getUltraRareCondition(DateTime now) {
    if (_isCursedHour(now)) return UltraRareCondition.cursedHour;
    if (_isSpecialDate(now)) return UltraRareCondition.specialDate;
    return UltraRareCondition.mysticalDay;
  }

  /// 超レア神器の説明を取得
  String _getUltraRareDescription(UltraRareCondition condition) {
    switch (condition) {
      case UltraRareCondition.cursedHour:
        return '呪われた時刻に封印が弱まっている...';
      case UltraRareCondition.mysticalDay:
        return '月の力が最も強い時、古の神器が目覚める...';
      case UltraRareCondition.specialDate:
        return '特別な日に現れる幻の神器...';
    }
  }

  /// イベントの残り時間を取得（分）
  int? getEventRemainingMinutes() {
    if (_currentEvent == null) return null;
    
    final now = DateTime.now();
    
    switch (_currentEvent!.type) {
      case SpecialEventType.ultraRareArtifact:
        // 超レア神器は条件が満たされている間継続
        if (isUltraRareCondition(now)) {
          return _calculateUltraRareRemainingTime(now);
        }
        return 0;
        
      case SpecialEventType.dimensionDistortion:
        // 次元歪曲は1時間継続
        final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
        return nextHour.difference(now).inMinutes;
        
      case SpecialEventType.none:
        return null;
    }
  }

  /// 超レア神器の残り時間を計算
  int _calculateUltraRareRemainingTime(DateTime now) {
    if (_isCursedHour(now)) {
      // 呪われた時刻は1分間のみ
      return 60 - now.second;
    }
    
    if (_isSpecialDate(now)) {
      // 特別な日は1日中
      final nextDay = DateTime(now.year, now.month, now.day + 1);
      return nextDay.difference(now).inMinutes;
    }
    
    // 神秘的な日（13日の金曜日）は1日中
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    return nextDay.difference(now).inMinutes;
  }

  /// レア度乗数を適用
  String applyRarityMultiplier(String baseRarity) {
    if (_currentEvent == null) return baseRarity;
    
    switch (_currentEvent!.type) {
      case SpecialEventType.ultraRareArtifact:
        // 超レア神器イベント中は最高レア度保証
        return 'Mythical';
        
      case SpecialEventType.dimensionDistortion:
        // 次元歪曲中は1ランク上昇
        switch (baseRarity) {
          case 'Common': return 'Rare';
          case 'Rare': return 'Epic';
          case 'Epic': return 'Legendary';
          case 'Legendary': return 'Mythical';
          default: return baseRarity;
        }
        
      case SpecialEventType.none:
        return baseRarity;
    }
  }

  /// 属性に特殊効果を適用
  String applySpecialAttributes(String baseAttribute) {
    if (_currentEvent == null) return baseAttribute;
    
    switch (_currentEvent!.type) {
      case SpecialEventType.ultraRareArtifact:
        // 超レア神器は特殊属性保証
        final specialAttrs = _currentEvent!.config['guaranteedAttributes'] as List<String>;
        return specialAttrs[_random.nextInt(specialAttrs.length)];
        
      case SpecialEventType.dimensionDistortion:
        // 次元歪曲中は30%で特殊属性
        if (_random.nextDouble() < 0.3) {
          return ['時空', '虚無', '混沌'][_random.nextInt(3)];
        }
        return baseAttribute;
        
      case SpecialEventType.none:
        return baseAttribute;
    }
  }

  /// テスト用イベントを作成
  SpecialEvent _createTestEvent(SpecialEventType type, DateTime now) {
    switch (type) {
      case SpecialEventType.ultraRareArtifact:
        return SpecialEvent(
          type: SpecialEventType.ultraRareArtifact,
          name: '[テスト] 超レア神器出現',
          description: 'テスト用の超レア神器が出現中...',
          rarityMultiplier: 3.0,
          config: {
            'condition': UltraRareCondition.cursedHour,
            'bonusRarity': 'Mythical',
            'guaranteedAttributes': ['闇', '時空', '封印'],
          },
        );
        
      case SpecialEventType.dimensionDistortion:
        return SpecialEvent(
          type: SpecialEventType.dimensionDistortion,
          name: '[テスト] 次元歪曲現象',
          description: 'テスト用の次元歪曲が発生中...',
          rarityMultiplier: 1.5,
          config: {
            'distortionLevel': 0.7,
            'colorShift': 0.3,
            'effectIntensity': 0.8,
          },
        );
        
      case SpecialEventType.none:
        return SpecialEvent(
          type: SpecialEventType.none,
          name: 'イベントなし',
          description: '',
          rarityMultiplier: 1.0,
          config: {},
        );
    }
  }

  /// デバッグ用：全ての時間条件をチェック
  Map<String, bool> debugTimeConditions() {
    final now = _testDateTime ?? DateTime.now();
    return {
      'cursedHour_4_44': now.hour == 4 && now.minute == 44,
      'cursedHour_13_13': now.hour == 13 && now.minute == 13,
      'cursedHour_23_23': now.hour == 23 && now.minute == 23,
      'friday13th': now.day == 13 && now.weekday == DateTime.friday,
      'halloween': now.month == 10 && now.day == 31,
      'christmas': now.month == 12 && now.day == 24,
      'newYear': now.month == 1 && now.day == 1,
      'aprilFools': now.month == 4 && now.day == 1,

      'dimensionDistortion': isDimensionDistortionActive(now),
    };
  }
}