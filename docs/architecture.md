# Architecture

CHAOS VISION は Flutter 製の単一画面遷移型 (Navigator スタック) アプリです。
AI 推論は **自前の Cloudflare Worker proxy (`worker/`) を経由して** OpenAI Vision API
を叩く構成。配布バイナリには OpenAI のキーは含まれず、Worker と共有する
`CHAOS_APP_SECRET` (Bearer トークン) のみが入る。

## レイヤ構成

```
lib/
├── main.dart                 ProviderScope 配下、サービス初期化、HomeScreenV2 をマウント
│
├── core/                     アプリ全体で共有するインフラ層
│   ├── constants/
│   │   ├── app_colors.dart   レガシー色 + 「Forbidden Codex」拡張パレット
│   │   └── app_constants.dart アプリ名・URL・属性 / レア度リスト・SharedPrefs キー
│   ├── theme/app_theme.dart  ダークテーマ (Material3)
│   └── services/             シングルトン (`Xxx.instance` パターン)
│       ├── ai_service.dart           OpenAI gpt-4o-mini に画像 + system prompt を送って中二異名生成
│       ├── camera_service.dart       camera パッケージのラッパー
│       ├── image_cache_service.dart  リサイズ済画像のメモリキャッシュ
│       ├── memory_monitor_service.dart iOS メモリ圧迫検知 / 低メモリモード
│       ├── share_service.dart        ShareCard を off-screen レンダ → PNG → 共有
│       ├── special_event_service.dart 4:44 等の時刻条件で「超レア神器」判定
│       └── storage_service.dart      Hive (ScannedObject) + SharedPreferences
│
├── features/                 画面単位 (1 feature = 1 ディレクトリ)
│   ├── home/                 ホーム (`Forbidden Codex` v2)
│   ├── scanner/              スキャナー (`Rite of Observation` v2)
│   ├── scan_result/          スキャン直後 (`Seal Undone` v2)
│   ├── collection/           図鑑 + 詳細 (`Grimoire Index` / `Specimen Record` v2)
│   ├── about/                アプリ情報 (`Arcanum` v2)
│   ├── contact/              問い合わせ (`Dispatch` v2)
│   └── legal/                Privacy / Terms (`CodexLegalScaffold` ベース)
│
└── shared/                   features 間で共有するもの
    ├── models/scanned_object.dart    Hive @HiveType(typeId: 0)
    └── widgets/
        ├── lazy_image.dart           可視範囲で遅延読込 + リサイズキャッシュ
        ├── magic_circle_widget.dart  汎用魔法陣 (CustomPainter, アニメ可)
        └── codex/                    Forbidden Codex 用 widget 群 (詳細は design-system.md)
```

## 主要データフロー

```
[User]
  ↓ tap SCAN
[ScannerScreenV2] — CameraService.takePicture()
  ↓ image (resized to 512px max, JPEG q=85)
  ↓ AIService.analyzeImageAndGenerate(path)
  ↓   POST /scan  Authorization: Bearer <APP_SECRET>
  ↓                body: { imageBase64 }
[Cloudflare Worker (worker/)]
  ↓   ・APP_SECRET 検証
  ↓   ・SYSTEM_PROMPT / model="gpt-4o-mini" / max_tokens=300 / detail="low" を server-side で固定
  ↓   ・OPENAI_API_KEY を Bearer に入れて転送
  ↓   ── HTTPS ──▶ OpenAI gpt-4o-mini
  ↓ ◀── OpenAI Chat Completion JSON
  ↓
[ScannerScreenV2] AI 応答 (objectCategory / alternateName / attribute / description / rarity)
  ↓
[StorageService.saveScannedObject(obj)]  ── Hive box write ──▶ disk
  ↓
[Navigator.push(_revealRoute → ScanResultScreenV2)]
  ↓ (CircularRevealClipper で円形遷移)
[ScanResultScreenV2] — typewriter + ritual UI
```

```
[CollectionScreenV2 init]
  ↓
[StorageService.getObjectsWithFilters(...)]  ── Hive box read ──▶ filtered/sorted page
  ↓
[GrimoireCard grid]  + tap →  [ObjectDetailScreenV2]
                     + share → [ShareService.shareScannedObject()]
                                ↓ 1) read photo bytes
                                ↓ 2) precache MemoryImage
                                ↓ 3) overlay → render ShareCard off-screen
                                ↓ 4) RepaintBoundary.toImage(pr=3)
                                ↓ 5) write PNG to tmp
                                ↓ 6) Share.shareXFiles(...)
```

## State management

- `flutter_riverpod` を全体に流すが、現状は `ConsumerStatefulWidget` の使用にとどまり
  Provider/Notifier は未利用。将来 AI レスポンスのキャッシュや設定管理で導入余地あり。
- 各画面は素直な `setState` ベース。ビジネスロジックは Service 層シングルトン経由。
- `provider` パッケージも依存に残っているが現状は使われていない (legacy)。

## 永続化

- **Hive** (`scanned_objects` ボックス) — `ScannedObject` の保存。
  `typeId: 0` は固定。スキーマ変更時は `flutter pub run build_runner build --delete-conflicting-outputs`。
- **SharedPreferences** — `first_launch`, `sound_enabled` 等のフラグ用。現状ほぼ未使用。
- **写真本体** — `getApplicationDocumentsDirectory()/scanned_images/` に JPEG 保存。
  Hive には**相対パス**を持つ (`imageRelativePath`)。読み出し時に
  `ScannedObject.getFullImagePath()` がアプリの documents パスと結合する。
  → アプリ更新で documents パスが変わっても整合する設計。

## ナビゲーション

`Navigator.push` ベースのスタック。tab/route table は持たない。
特殊な遷移:

- スキャナー → 結果: `_CircularRevealClipper` を組み込んだ `PageRouteBuilder`
  (魔法陣中心から放射状に reveal)。
- ホーム ⇄ サブ画面: 画面下からのフェード+slide (`PageRouteBuilder`)。

## 技術スタック (主要のみ)

| カテゴリ | パッケージ | 用途 |
|---|---|---|
| AI | `dio` `http` | OpenAI Vision API リクエスト |
| 画像 | `camera` `image` `path_provider` | 撮影、リサイズ、保存 |
| 永続化 | `hive` `hive_flutter` `shared_preferences` `sqflite`(未使用) | ローカル保存 |
| 状態管理 | `flutter_riverpod` `provider`(legacy) | UI 状態 |
| アニメ | `flutter_animate` `lottie` `animated_text_kit` | 入場演出など |
| フォント | `google_fonts` | Bodoni Moda / Shippori Mincho / JetBrains Mono |
| 共有 | `share_plus` `url_launcher` | 共有シート、メーラ |
| 権限 | `permission_handler` | カメラ許可 |
| 音声 | `audioplayers` | （現状未配線） |

## ビルド成果物の取り扱い

- `ios/build/`、`ios/Pods/`、`android/build/` 等は `.gitignore` 済 (途中で混入していたものも整理済)
- `macOS` ビルドは Xcode 検証用に有効化されている (`flutter build macos --debug` で動く)
- 配布対象は iOS のみを想定: `flutter build ipa --dart-define-from-file=secrets.json`

## Worker proxy (worker/)

詳細は `worker/README.md` 参照。要点:

- **TypeScript / Cloudflare Workers Free Tier** で運用 (100k req/day で十分)
- 公開エンドポイント: `https://chaos-vision-proxy.clow-ff14.workers.dev`
  - `GET /` — ヘルスチェック
  - `POST /scan` — Bearer 認証 + 画像 → OpenAI 転送 → 応答そのまま返却
- `OPENAI_API_KEY` / `APP_SECRET` は Cloudflare の secret store に保管
  (`wrangler secret put`)
- Worker は **model / system prompt / max_tokens / detail を固定**しているので、
  仮に `APP_SECRET` が漏洩しても任意プロンプトで OpenAI を叩くことは不可能
