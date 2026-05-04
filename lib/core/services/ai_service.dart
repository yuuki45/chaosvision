import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';
import 'special_event_service.dart';

class AIService {
  final Dio _dio;
  final SpecialEventService _eventService = SpecialEventService.instance;
  static const String _workerUrl = AppConstants.workerBaseUrl;
  static const String _appSecret = AppConstants.appSecret;

  AIService()
      : _dio = Dio(BaseOptions(
          connectTimeout: AppConstants.apiTimeout,
          receiveTimeout: AppConstants.apiTimeout,
        ));

  /// Worker URL + APP_SECRET の両方が揃っているかチェック
  bool get _hasValidConfig => _workerUrl.isNotEmpty && _appSecret.isNotEmpty;

  /// 画像を解析して物体認識と中二病名前生成を同時に行う
  ///
  /// 通信先は OpenAI ではなく自前の Cloudflare Worker。
  /// Worker が APP_SECRET を検証してから OpenAI に転送する。
  Future<Map<String, String>?> analyzeImageAndGenerate(String imagePath) async {
    try {
      if (!_hasValidConfig) {
        debugPrint('Worker URL / APP_SECRET 未設定のためダミーを返します');
        return _generateDummyFromImage(imagePath);
      }

      debugPrint('Worker proxy で画像解析を開始...');

      // 画像をリサイズしてBase64エンコード（メモリ最適化）
      final imageBytes = await _resizeImageForAPI(imagePath);
      final base64Image = base64Encode(imageBytes);

      final response = await _dio.post(
        '$_workerUrl/scan',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_appSecret',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'imageBase64': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        debugPrint('Worker proxy 応答: $content');
        return _parseImageAnalysisResponse(content);
      } else {
        throw Exception('Worker request failed: ${response.statusCode}');
      }
    } catch (e) {
      // エラー時はダミーデータを返す
      debugPrint('AI Image Analysis error: $e');
      return _generateDummyFromImage(imagePath);
    }
  }

  // System prompt は Worker (worker/src/index.ts) 側に移動済み。
  // プロンプト改善時は Worker をデプロイしなおすだけでアプリ更新不要。

  Map<String, String> _parseImageAnalysisResponse(String content) {
    final lines = content.split('\n');
    final result = <String, String>{};
    
    for (final line in lines) {
      if (line.startsWith('物体カテゴリ:')) {
        result['objectCategory'] = line.replaceFirst('物体カテゴリ:', '').trim();
      } else if (line.startsWith('異名:')) {
        result['alternateName'] = line.replaceFirst('異名:', '').trim();
      } else if (line.startsWith('属性:')) {
        result['attribute'] = line.replaceFirst('属性:', '').trim();
      } else if (line.startsWith('説明:')) {
        result['description'] = line.replaceFirst('説明:', '').trim();
      } else if (line.startsWith('レア度:')) {
        final rawRarity = line.replaceFirst('レア度:', '').trim();
        result['rarity'] = _normalizeRarity(rawRarity);
      }
    }
    
    // デフォルト値を設定
    result['objectCategory'] ??= '未知の物体';
    result['alternateName'] ??= '謎の神器《アンノウン》';
    result['attribute'] ??= '無';
    result['description'] ??= '未知なる力を秘めた謎めいた神器。その真の力はまだ解明されていない。';
    result['rarity'] ??= 'コモン';
    
    // AIの判断を無視して、確率に基づいてレア度を再決定（画像解析時）
    final originalRarity = result['rarity']!;
    result['rarity'] = _selectRarityByProbability();
    
    if (originalRarity != result['rarity']) {
      debugPrint('画像解析レア度を確率ベースに変更: $originalRarity → ${result['rarity']}');
    }
    
    // 特殊イベントの効果を適用
    return _applySpecialEventEffects(result);
  }

  Map<String, String> _generateDummyFromImage(String imagePath) {
    final random = Random();
    final attributes = AppConstants.attributes;

    
    // 画像に基づいたダミーカテゴリをランダム選択
    final dummyCategories = [
      '冷蔵庫', 'スマートフォン', 'カップ', 'ノートパソコン', '本',
      'ボトル', '時計', 'キーボード', '植物', 'バッグ', '靴', '椅子'
    ];
    
    final category = dummyCategories[random.nextInt(dummyCategories.length)];
    
    final result = {
      'objectCategory': category,
      'alternateName': '未知の神器《${_generateRandomName()}》',
      'attribute': attributes[random.nextInt(attributes.length)],
      'description': '撮影された神秘的な力を秘めた神器。その真なる力は使い手によって開花する運命にある。',
      'rarity': _selectRarityByProbability(),
    };
    
    // 特殊イベントの効果を適用
    return _applySpecialEventEffects(result);
  }

  String _generateRandomName() {
    final prefixes = ['エターナル', 'カオス', 'ミスティック', 'フェイタル', 'セレスティアル'];
    final suffixes = ['ブレード', 'オーブ', 'コア', 'フォース', 'エッセンス'];
    final random = Random();
    
    return '${prefixes[random.nextInt(prefixes.length)]}・${suffixes[random.nextInt(suffixes.length)]}';
  }

  /// レア度を日本語に正規化
  String _normalizeRarity(String rarity) {
    // 英語のレア度を日本語にマッピング
    final rarityMap = {
      'Common': 'コモン',
      'common': 'コモン',
      'COMMON': 'コモン',
      'Rare': 'レア',
      'rare': 'レア',
      'RARE': 'レア',
      'Epic': 'エピック',
      'epic': 'エピック',
      'EPIC': 'エピック',
      'Legendary': 'レジェンダリー',
      'legendary': 'レジェンダリー',
      'LEGENDARY': 'レジェンダリー',
      'Mythic': 'ミシック',
      'mythic': 'ミシック',
      'MYTHIC': 'ミシック',
      'Mythical': 'ミシック',
      'mythical': 'ミシック',
      'MYTHICAL': 'ミシック',
    };

    // まず英語マッピングをチェック
    if (rarityMap.containsKey(rarity)) {
      debugPrint('レア度を英語から日本語に正規化: $rarity → ${rarityMap[rarity]}');
      return rarityMap[rarity]!;
    }

    // 日本語のレア度が正しいかチェック
    if (AppConstants.rarityLevels.contains(rarity)) {
      return rarity;
    }

    // 無効な場合はデフォルト
    debugPrint('無効なレア度「$rarity」をコモンに変更');
    return 'コモン';
  }

  /// レア度を確率に基づいて選択
  String _selectRarityByProbability() {
    final random = Random();
    final roll = random.nextDouble() * 100; // 0-100の確率
    
    // 確率分布（累積）:
    // コモン: 50% (0-50)
    // レア: 30% (50-80)  
    // エピック: 15% (80-95)
    // レジェンダリー: 4% (95-99)
    // ミシック: 1% (99-100)
    
    String rarity;
    if (roll < 50) {
      rarity = 'コモン';
    } else if (roll < 80) {
      rarity = 'レア';
    } else if (roll < 95) {
      rarity = 'エピック';
    } else if (roll < 99) {
      rarity = 'レジェンダリー';
    } else {
      rarity = 'ミシック';
    }
    
    debugPrint('レア度抽選: ${roll.toStringAsFixed(1)}% → $rarity');
    return rarity;
  }

  /// レア度の確率分布を取得
  static Map<String, double> getRarityProbabilities() {
    return {
      'コモン': 50.0,
      'レア': 30.0,
      'エピック': 15.0,
      'レジェンダリー': 4.0,
      'ミシック': 1.0,
    };
  }

  /// デバッグ用：確率テストを実行
  static Map<String, int> testRarityProbability(int iterations) {
    final results = <String, int>{};
    final testService = AIService();
    
    for (int i = 0; i < iterations; i++) {
      final rarity = testService._selectRarityByProbability();
      results[rarity] = (results[rarity] ?? 0) + 1;
    }
    
    debugPrint('=== レア度確率テスト結果 ($iterations回) ===');
    for (final entry in results.entries) {
      final percentage = (entry.value / iterations * 100).toStringAsFixed(1);
      debugPrint('${entry.key}: ${entry.value}回 ($percentage%)');
    }
    
    return results;
  }

  /// 画像をAPIに送信する前にリサイズしてメモリ使用量を最適化
  Future<Uint8List> _resizeImageForAPI(String imagePath) async {
    try {
      // 画像ファイルを読み込み
      final originalBytes = await File(imagePath).readAsBytes();
      
      // 画像をデコード
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        throw Exception('画像のデコードに失敗しました');
      }

      // 画像サイズを制限（detail: 'low' で OpenAI 側が 512×512 に自動縮小するので、
      // それ以上送信しても帯域の無駄。512px 上限にして転送量も節約する）
      const maxWidth = 512;
      img.Image resizedImage;
      
      if (originalImage.width > maxWidth) {
        // アスペクト比を維持してリサイズ
        final aspectRatio = originalImage.height / originalImage.width;
        final newHeight = (maxWidth * aspectRatio).round();
        resizedImage = img.copyResize(originalImage, width: maxWidth, height: newHeight);
        debugPrint('画像をリサイズしました: ${originalImage.width}x${originalImage.height} → ${resizedImage.width}x${resizedImage.height}');
      } else {
        resizedImage = originalImage;
        debugPrint('画像サイズは適切です: ${originalImage.width}x${originalImage.height}');
      }

      // JPEGとして圧縮してエンコード（品質85%で軽量化）
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      debugPrint('画像サイズ: ${originalBytes.length} bytes → ${compressedBytes.length} bytes');
      
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('画像リサイズエラー: $e');
      // エラー時は元の画像をそのまま返す
      return await File(imagePath).readAsBytes();
    }
  }
  
  /// 特殊イベント効果を適用するヘルパー関数
  Map<String, String> _applySpecialEventEffects(Map<String, String> result) {
    if (_eventService.currentEvent == null) return result;
    
    final originalRarity = result['rarity']!;
    final originalAttribute = result['attribute']!;
    
    result['rarity'] = _eventService.applyRarityMultiplier(result['rarity']!);
    result['attribute'] = _eventService.applySpecialAttributes(result['attribute']!);
    
    // 特殊イベント効果のログ出力
    debugPrint('特殊イベント効果適用: ${_eventService.currentEvent!.name}');
    if (originalRarity != result['rarity']) {
      debugPrint('レア度変更: $originalRarity → ${result['rarity']}');
    }
    if (originalAttribute != result['attribute']) {
      debugPrint('属性変更: $originalAttribute → ${result['attribute']}');
    }
    
    return result;
  }
}