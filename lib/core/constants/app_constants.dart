class AppConstants {
  // アプリ情報
  static const String appName = 'CHAOS VISION';
  static const String appSubtitle = '中二スキャナー';
  static const String appVersion = '1.0.0';
  
  // API設定
  static const Duration apiTimeout = Duration(seconds: 30);

  // Cloudflare Worker proxy 設定
  // OpenAI への転送はすべて Worker 経由で行う。アプリバイナリには
  // 本物の OpenAI キーは焼き込まれない。
  //   --dart-define=CHAOS_WORKER_URL=https://chaos-vision-proxy.<sub>.workers.dev
  //   --dart-define=CHAOS_APP_SECRET=<wrangler secret put APP_SECRET の値>
  static const String workerBaseUrl =
      String.fromEnvironment('CHAOS_WORKER_URL', defaultValue: '');
  static const String appSecret =
      String.fromEnvironment('CHAOS_APP_SECRET', defaultValue: '');
  
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
