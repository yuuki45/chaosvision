class AppConstants {
  // アプリ情報
  static const String appName = 'CHAOS VISION';
  static const String appSubtitle = '中二スキャナー';
  static const String appVersion = '1.0.0';
  
  // API設定
  static const String openaiApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // OpenAI APIキー（ビルド時に --dart-define=OPENAI_API_KEY=... で渡す）
  static const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  
  // 物体検出設定
  static const double detectionConfidence = 0.5;
  static const int maxDetectionResults = 5;
  
  // アニメーション設定
  static const Duration scanAnimationDuration = Duration(seconds: 2);
  static const Duration magicCircleRotationDuration = Duration(seconds: 3);
  
  // 属性タイプ
  static const List<String> attributes = [
    '炎', '氷', '雷', '闇', '光', '風', '地', '水', '無'
  ];
  
  // レア度
  static const List<String> rarityLevels = [
    'コモン', 'レア', 'エピック', 'レジェンダリー', 'ミシック'
  ];
  
  // データベース設定
  static const String dbName = 'chaos_vision.db';
  static const int dbVersion = 1;
  
  // 共有設定
  static const String prefKeyFirstLaunch = 'first_launch';
  static const String prefKeySoundEnabled = 'sound_enabled';
  static const String prefKeyEffectsEnabled = 'effects_enabled';
  static const String prefKeyLanguage = 'language';
}
