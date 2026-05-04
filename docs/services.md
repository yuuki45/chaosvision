# Services

`lib/core/services/` に集めたシングルトンサービスの責務一覧と公開 API。
すべて `Xxx.instance` でアクセス。

## StorageService

ローカル永続化。Hive ボックス + SharedPreferences のラッパー。

**初期化:** `main.dart` で `await StorageService.instance.initialize()` を呼ぶ。
これは Hive.initFlutter() + ScannedObjectAdapter 登録 + box open + prefs 取得。

**主要 API:**
```dart
// 保存系
Future<bool> saveScannedObject(ScannedObject obj);
Future<bool> deleteScannedObject(String id);
Future<bool> clearAllData();

// 読み出し
List<ScannedObject> getAllScannedObjects({int? limit, int? offset});
PaginatedResult getObjectsWithFilters({
  int limit = 10,
  int offset = 0,
  String? attributeFilter,   // 'すべて' or '炎' 等
  String? rarityFilter,      // 'すべて' or 'コモン' 等 (自動正規化)
  String? searchQuery,       // 部分一致検索 (現状未使用)
  SortMode sortMode = SortMode.newest,
});
ScannedObject? getScannedObjectById(String id);

// 統計
Map<String, int> get attributeStats;
Map<String, int> get rarityStats;  // 英語入力も正規化してカウント
int get totalScannedCount;

// 設定 (現状未使用)
bool get isSoundEnabled;
Future<void> setSoundEnabled(bool enabled);
```

**`SortMode` enum:**
- `newest` (default) — `scannedAt` 降順
- `oldest` — `scannedAt` 昇順
- `rarityDesc` — レア度 (神→常)、同点は新しい順
- `attribute` — 属性順 (`炎 氷 雷 風 地 水 光 闇 無`)、同点は新しい順

**正規化:** 英語レア度 (`Mythic` `MYTHIC` `mythical` 等) を `_normalizeRarity` で日本語に統一。
`_rarityRank`、`_attributeRank` がソート順を決める。

**画像パス:** `ScannedObject` には**相対パス** (`scanned_images/scanned_<ts>.jpg`) を保存。
読み出しは `ScannedObject.getFullImagePath()` が `getApplicationDocumentsDirectory()` と結合。

## AIService

中二異名を生成する。直接 OpenAI を叩かず、**Cloudflare Worker proxy 経由**。

**初期化:** 不要 (lazy)。コンストラクタで Dio クライアントを構築。

**主要 API:**
```dart
Future<Map<String, String>?> analyzeImageAndGenerate(String imagePath);
// 返り値:
// {
//   'objectCategory': '冷蔵庫',
//   'alternateName': '氷封の魔牢《フリージア・コア》',
//   'attribute': '氷',
//   'description': '...',
//   'rarity': 'レア',
// }
```

**通信先:** `${AppConstants.workerBaseUrl}/scan`
- `workerBaseUrl` = `String.fromEnvironment('CHAOS_WORKER_URL')`
- 認証ヘッダ: `Authorization: Bearer ${AppConstants.appSecret}`
  - `appSecret` = `String.fromEnvironment('CHAOS_APP_SECRET')`
- 両方 `--dart-define-from-file=secrets.json` で注入する (詳細は CLAUDE.md)

**Worker 仕様:** `worker/README.md` 参照。アプリ側からは
`{ "imageBase64": "..." }` を送るだけ。model / prompt / max_tokens / detail は
Worker 側で固定されている。

**ダミー動作:** `CHAOS_WORKER_URL` または `CHAOS_APP_SECRET` が未設定時は
`_generateDummyFromImage` がランダムなダミーを返す。オフライン開発・初期動作
確認に有用。

**画像処理:** `_resizeImageForAPI` で送信前に最大幅 512px に縮小 + JPEG 品質 85
で圧縮。OpenAI の `detail: 'low'` が 512×512 に内部リサイズするので、これ以上
大きく送っても帯域の無駄。

**SpecialEventService と連携:** Worker から返る生成結果に対し、
`_applySpecialEventEffects` でクライアント側で `rarityMultiplier` を適用。
特殊イベントは時刻ベースなので server-side でなく client-side で判定する設計。

## CameraService

`camera` パッケージのラッパー。

**主要 API:**
```dart
Future<bool> initialize();          // カメラ初期化 + 権限要求
Future<XFile?> takePicture();       // 撮影、保存パスを返す
CameraController? get controller;   // CameraPreview に渡す用
Future<void> dispose();             // ライフサイクル管理
```

シャッター後の画像はこのサービスが OS の一時パスに置く。
アプリ documents への永続保存は `ScannerScreenV2._persistImage()` が担う。

## ImageCacheService

リサイズ済み画像 bytes のメモリキャッシュ。`LazyImage` widget が使う。

**主要 API:**
```dart
Uint8List? getFromCache(String key);
void addToCache(String key, Uint8List bytes);
void removeFromCache(String key);
void clearCache();
```

キャッシュキーは `<path>_resized_<W>x<H>_cache<size>` 形式。
低メモリモード時は `addToCache` がスキップされる。

## MemoryMonitorService

iOS のメモリ圧迫検知 + 低メモリモード切替。

**主要 API:**
```dart
void initialize();                       // observer 登録
bool get isLowMemoryMode;                // 状態フラグ
void enableLowMemoryMode() / disable...  // 手動切替
void forceMemoryCleanup();               // ImageCache + キャッシュ排出
```

**現状:**
`main.dart` の `didHaveMemoryPressure` でクリーンアップは呼ぶが、
**自動的な低メモリモード切替・定期チェックは無効化**されている (コメントアウト済)。
過去に不安定だった経緯あり。むやみに有効化しないこと。

## SpecialEventService

時刻・日付ベースで「超レア神器」発生条件を判定する。

**主要 API:**
```dart
void updateEventStatus();
SpecialEvent? get currentEvent;
int? getEventRemainingMinutes();
bool isUltraRareCondition(DateTime now);
```

**条件:**
- `cursedHour` — 4:44 / 13:13 / 23:23
- `mysticalDay` — 13日の金曜日
- `specialDate` — ハロウィン (10/31) / クリスマスイブ (12/24) / 新年 (1/1) / エイプリルフール (4/1)

過去のコミット (`8879860`) で月相条件は削除済。

## ShareService

ScanResult / ObjectDetail からの共有用。テキストだけでなく**画像付き**で共有する。

**主要 API:**
```dart
static Future<void> shareScannedObject(BuildContext context, ScannedObject object);
```

**処理フロー:**
1. `ScaffoldMessenger` と `OverlayState` を context から取得 (await 前にキャプチャ)
2. `_ShareLoader` (codex モーダル) を overlay に挿入
3. `ScannedObject.getFullImagePath()` → `File.readAsBytes()` で写真 bytes 取得
4. `MemoryImage().resolve()` で precache (decode 完了待ち)
5. 別の overlay に `ShareCard` を `Positioned(left: -20000)` で配置 → 4 frames + paint flush 待ち
6. `RepaintBoundary.toImage(pixelRatio: 3.0)` で 1080×1080 PNG 取得
7. `<tmp>/share/chaos_vision_<id>.png` に書き出し
8. ローダーを除去 → `Share.shareXFiles(...)` 呼び出し

**注意点:**
- iOS の UIActivityViewController は iPhone でも `sharePositionOrigin` の
  非ゼロ Rect を要求する (バリデーションエラー回避のため `_shareOrigin(context)` 必須)
- 画像 + テキスト両方を渡す
- エラー時は `_toast` で詳細を SnackBar 表示 + `debugPrint` で stack 出力

## 起動時のサービス初期化

`main.dart`:
```dart
WidgetsFlutterBinding.ensureInitialized();
await StorageService.instance.initialize();
ImageCacheService.instance.initialize();
MemoryMonitorService.instance.initialize();
runApp(const ProviderScope(child: ChaosVisionApp()));
```

`AIService` `CameraService` `SpecialEventService` `ShareService` は遅延 (lazy)、
最初に使われる時点でセットアップされる。

## サーバー側コンポーネント (`worker/`)

`AIService` が叩く Cloudflare Worker proxy。Flutter プロジェクトと同じリポジトリ
の `worker/` 直下に独立した Node プロジェクトとして存在する。

**役割:**
- OpenAI API キーの保管 (アプリバイナリから完全に分離)
- 認証チェック (`Authorization: Bearer ${APP_SECRET}`)
- リクエストの形式固定 (model / prompt / max_tokens / detail を server-side で固定)
- OpenAI への転送 + レスポンス透過

**運用フロー:**
- プロンプト改善: `worker/src/index.ts` の `SYSTEM_PROMPT` を編集 →
  `npm run deploy` (アプリ更新不要)
- 鍵ローテーション: `npm run secret:openai` で再登録 → 即時反映
- レート制限実装余地: `wrangler.toml` に KV namespace 追加 + `src/index.ts` で
  IP 別カウンタ管理 (現状未実装)

詳細は `worker/README.md`。
