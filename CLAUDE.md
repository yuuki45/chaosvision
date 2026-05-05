# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CHAOS VISION (中二スキャナー) — Flutter製のARカメラアプリ。現実の物体をカメラで撮影し、OpenAI gpt-4o-mini で「中二病的な異名・属性・裏設定・レア度」を生成、Hive にコレクションとして保存する。

- 現バージョン: `1.0.2+1` (pubspec.yaml)
- ステータス: **MVP実装済み**（仕様フェーズではない）。物体検出は ML Kit ではなく **OpenAI Vision APIで画像→分類＋生成を一括実行**する設計。

## Architecture

### Layer 構成
```
lib/
├── main.dart                         # ProviderScope, StorageService/ImageCacheService/MemoryMonitorService 初期化
├── core/
│   ├── constants/                    # AppConstants(APIキー含む⚠️), AppColors
│   ├── theme/app_theme.dart          # ダークテーマ
│   └── services/
│       ├── ai_service.dart           # OpenAI gpt-4o-mini で画像解析＋中二異名生成 (464行)
│       ├── camera_service.dart       # camera パッケージのラッパー
│       ├── storage_service.dart      # Hive (ScannedObject) + SharedPreferences
│       ├── image_cache_service.dart  # 画像キャッシュ
│       ├── memory_monitor_service.dart # iOSメモリ圧迫対策
│       └── special_event_service.dart # レアタイミング(4:44, 13日金曜, ハロウィン等)
├── features/
│   ├── home/, scanner/, scan_result/, collection/
│   ├── about/, contact/, legal/(privacy/terms), debug/(event_test)
└── shared/
    ├── models/scanned_object.dart    # @HiveType(typeId: 0) — `.g.dart` は build_runner 生成
    └── widgets/                      # magic_circle, rarity_badge, attribute_badge, *_button 群
```

### State management
- `flutter_riverpod` を主に使用（`ProviderScope` 配下）。`provider` も依存に入っているがレガシー。
- 多くのサービスは `XxxService.instance` のシングルトンパターン。

### 永続化
- **Hive** (`scanned_object.dart`): スキャン履歴。typeId 0。
- **SharedPreferences**: 設定フラグ (`first_launch`, `sound_enabled`, etc.)
- 画像は `getApplicationDocumentsDirectory()` 配下に保存し、Hive には**相対パス**を保持（`getFullImagePath()` で動的解決）。
- Hive モデルを変更したら `flutter pub run build_runner build --delete-conflicting-outputs` で `.g.dart` 再生成。

## Development Commands

```bash
flutter pub get

# Makefile が --dart-define-from-file 含む典型コマンドをラップしている。
# 一覧は `make help`。代表的なもの:
make run                      # iPhone (or DEVICE=...) に転送 + dart-define
make build-ipa                # 配布用 IPA
make build-ios-debug          # Xcode で ▶ する前に Generated.xcconfig 更新
make analyze                  # dart analyze lib/  (flutter analyze は環境依存でクラッシュ)
make test                     # flutter test
make worker-deploy            # Cloudflare Worker 再デプロイ
make worker-tail              # Worker のリアルタイムログ

# 直叩きする場合:
flutter run -d <device> --dart-define-from-file=secrets.json
flutter build ipa --dart-define-from-file=secrets.json
```

AI 接続のキーはアプリに直に持たせず、`worker/` (Cloudflare Worker proxy) が
OpenAI キーを保持する。アプリは `CHAOS_WORKER_URL` (Worker の URL) と
`CHAOS_APP_SECRET` (Worker と共有する Bearer トークン) だけを持つ。
両者とも未設定時は `_generateDummyFromImage` でダミーが返るのでオフライン
開発もそのまま回る。

## Critical Notes

### ⚠️ セキュリティ: APIキーがハードコードされている
`lib/core/constants/app_constants.dart:12` の `openaiApiKey` に**実プロダクションのOpenAIキーがコミット済み**。`README_SETUP.md` の方針 (`--dart-define`) と矛盾。修正方針:
1. **当該キーをOpenAIダッシュボードで即座にrevoke**
2. `String.fromEnvironment('OPENAI_API_KEY', defaultValue: '')` に置換
3. `git filter-repo` 等で履歴から除去（または公開リポなら諦めてrevokeのみ）

### iOS ビルド成果物
`ios/build/` 以下に過去のXCBuildDataが35ファイル git追跡されていた。`.gitignore` に `ios/build/` を追加済。実体は既に削除済みなので `git rm --cached ios/build` で追跡解除する必要あり。

### メモリ管理 (iOS)
`MemoryMonitorService` が `didHaveMemoryPressure` でクリーンアップを実行。低メモリモード切替や定期チェックは現在コメントアウトされている (`main.dart:21-25`) — 不安定だった経緯がありそうなのでむやみに有効化しない。

### AI Service の挙動
- APIキー未設定時は `_generateDummyFromImage` でダミーを返す（`ai_service.dart:28-31`）。オフライン開発はそのままできる。
- 画像はAPI送信前に `_resizeImageForAPI` でリサイズ → Base64 エンコード（メモリ最適化）。
- `gpt-4o-mini` を使用（コスト最適）。

### 特殊イベント
`SpecialEventService` で時刻・日付ベースの「超レア神器」発生条件を判定。月相条件は過去のコミット (`8879860`) で削除済み。

## Project Conventions

- 言語: コメント・ログ・UIテキストは**日本語**。
- ログ: `debugPrint` を使う（`print` は lint で警告される想定）。
- リント: `package:flutter_lints/flutter.yaml` のデフォルト設定。
- Riverpod は `ConsumerStatefulWidget` を多用。
- 新画面追加は `lib/features/<name>/<name>_screen.dart` を作り `home_screen.dart` から導線を張る。

### テスト状態
`dart analyze` 結果（2026-05-03時点）: lib/ は健全 (info×2 のみ — `contact_screen.dart` の async gap 警告)。一方で **test/ 配下は実装と乖離** しており error 多数:
- `test/unit/storage_service_test.dart` — `getAllScannedObjects()` の戻り値が `Future<List<>>` でなく `List<>` に変わったが追従なし、`ScannedObject` の引数名(`alternateName` 等)も古い。
- `test/widget/common_widgets_test.dart` — const constructor に null callback を渡している。
- `test/unit/ai_service_test.dart` — 未使用変数 + mockito 未使用。
テストを触る前に**まず修正が必要**。

## Reference Files

詳しい仕様 / 設計の説明は `docs/` 以下の長文ドキュメントにある。
新しい話題に着手する前に該当ドキュメントを参照すること。

- `docs/README.md` — 索引と現在のスナップショット
- `docs/architecture.md` — レイヤ構成、データフロー、技術スタック
- `docs/design-system.md` — 「禁忌教典」ビジュアル言語仕様
- `docs/screens.md` — 9 画面の概要と遷移
- `docs/services.md` — Service 層の責務
- `docs/data-model.md` — Hive スキーマと正規化
- `docs/decisions.md` — D-001 〜 D-010 の設計決定ログ

その他:
- `PROJECT_SPEC.md` — 元仕様書（日本語、機能一覧・UI構造・マネタイズ案）
- `readme.md` — ユーザー向け feature 説明
- `README_SETUP.md` — APIキー設定手順
- `privacy_policy.md`, `terms_of_service.md` — リーガル文書（アプリ内画面と同期）
